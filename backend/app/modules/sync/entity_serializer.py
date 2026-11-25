from datetime import UTC, datetime
from typing import Any

from sqlalchemy import and_, insert, or_, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import ForbiddenError
from app.db.models.ai import AIInference
from app.db.models.budget import Budget
from app.db.models.category import Category
from app.db.models.household import HouseholdMember
from app.db.models.media import Media
from app.db.models.receipt import ReceiptExtraction, ReceiptLineItem
from app.db.models.transaction import Transaction

ENTITY_TYPE_MAP: dict[str, type[Any]] = {
    "transaction": Transaction,
    "category": Category,
    "budget": Budget,
    "media": Media,
    "receipt_extraction": ReceiptExtraction,
    "receipt_line_item": ReceiptLineItem,
    "ai_inference": AIInference,
}


async def _user_household_ids(db: AsyncSession, user_id: str) -> list[str]:
    result = await db.execute(
        select(HouseholdMember.household_id).where(HouseholdMember.user_id == user_id)
    )
    return list(result.scalars().all())


async def _assert_household_member(
    db: AsyncSession,
    household_id: str | None,
    user_id: str,
) -> None:
    if not household_id:
        return
    res = await db.execute(
        select(HouseholdMember).where(
            HouseholdMember.household_id == household_id,
            HouseholdMember.user_id == user_id,
        )
    )
    if res.scalar_one_or_none() is None:
        raise ForbiddenError("User is not a member of the specified household")


async def get_household_member_names(
    db: AsyncSession,
    household_ids: list[str],
) -> dict[tuple[str, str], str]:
    if not household_ids:
        return {}
    res = await db.execute(
        select(HouseholdMember).where(HouseholdMember.household_id.in_(household_ids))
    )
    return {
        (m.household_id, m.user_id): (m.display_name.strip() if m.display_name else m.user_id)
        for m in res.scalars().all()
    }


def serialize_entity(
    entity_type: str,
    row: Any,
    member_names: dict[tuple[str, str], str] | None = None,
) -> dict[str, Any]:
    if not row:
        return {}

    columns = [c.name for c in row.__table__.columns]
    payload: dict[str, Any] = {}
    for col in columns:
        if col in ["user_id", "object_key", "thumbnail_key"]:
            continue
        val = getattr(row, col)
        if isinstance(val, datetime):
            payload[col] = val.isoformat()
        else:
            payload[col] = val

    if entity_type == "transaction" and getattr(row, "is_shared", False):
        hh_id = getattr(row, "household_id", None)
        owner_id = getattr(row, "user_id", None)
        if hh_id and owner_id:
            payload["created_by_user_id"] = owner_id
            payload["created_by_name"] = (member_names or {}).get((hh_id, owner_id), owner_id)

    return payload


def deserialize_upsert_payload(
    entity_type: str,
    payload: dict[str, Any],
    user_id: str,
    entity_id: str,
) -> dict[str, Any]:
    model_class = ENTITY_TYPE_MAP[entity_type]
    valid_columns = {c.name for c in model_class.__table__.columns}

    kwargs: dict[str, Any] = {"user_id": user_id}

    pk_col = "transaction_id" if entity_type == "receipt_extraction" else "id"
    kwargs[pk_col] = entity_id

    for key, value in payload.items():
        if key in valid_columns and key not in ["user_id", pk_col]:
            if isinstance(value, str):
                try:
                    kwargs[key] = datetime.fromisoformat(value)
                except ValueError:
                    kwargs[key] = value
            else:
                kwargs[key] = value

    return kwargs


async def get_entity(
    db: AsyncSession,
    entity_type: str,
    entity_id: str,
    user_id: str,
    *,
    for_read: bool = True,
) -> Any | None:
    model_class = ENTITY_TYPE_MAP[entity_type]
    pk_col = "transaction_id" if entity_type == "receipt_extraction" else "id"

    if entity_type == "budget":
        hh_ids = await _user_household_ids(db, user_id)
        if hh_ids:
            access_filter = or_(
                and_(Budget.household_id.is_(None), Budget.user_id == user_id),
                Budget.household_id.in_(hh_ids),
            )
        else:
            access_filter = and_(Budget.household_id.is_(None), Budget.user_id == user_id)
        stmt = select(Budget).where(Budget.id == entity_id, access_filter)
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    if entity_type == "transaction" and for_read:
        hh_ids = await _user_household_ids(db, user_id)
        if hh_ids:
            tx_filter = or_(
                Transaction.user_id == user_id,
                and_(
                    Transaction.household_id.in_(hh_ids),
                    Transaction.is_shared.is_(True),
                ),
            )
        else:
            tx_filter = Transaction.user_id == user_id
        stmt = select(Transaction).where(Transaction.id == entity_id, tx_filter)
        result = await db.execute(stmt)
        return result.scalar_one_or_none()

    stmt = select(model_class).where(
        getattr(model_class, pk_col) == entity_id, model_class.user_id == user_id
    )
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def upsert_entity(
    db: AsyncSession,
    entity_type: str,
    entity_id: str,
    user_id: str,
    payload: dict[str, Any],
    revision: int,
) -> tuple[int, str | None]:
    model_class = ENTITY_TYPE_MAP[entity_type]
    pk_col = "transaction_id" if entity_type == "receipt_extraction" else "id"

    if entity_type in ("budget", "transaction"):
        raw_hh = payload.get("household_id")
        if raw_hh is not None:
            await _assert_household_member(db, str(raw_hh), user_id)

    existing = await get_entity(
        db,
        entity_type,
        entity_id,
        user_id,
        for_read=(entity_type == "budget"),
    )
    kwargs = deserialize_upsert_payload(entity_type, payload, user_id, entity_id)
    kwargs["revision"] = revision
    now = datetime.now(UTC)
    kwargs["updated_at"] = now
    kwargs.setdefault("created_at", now)
    kwargs.setdefault("currency", "VND")
    kwargs.setdefault("status", "confirmed")
    kwargs.setdefault("source", entity_type)
    valid_columns = {c.name for c in model_class.__table__.columns}
    kwargs = {k: v for k, v in kwargs.items() if k in valid_columns}

    if existing:
        # Preserve original creator's user_id when another household member updates a shared budget
        update_kwargs = {k: v for k, v in kwargs.items() if k != "user_id"}
        if entity_type == "budget":
            stmt = update(model_class).where(Budget.id == entity_id).values(**update_kwargs)
        else:
            stmt = (
                update(model_class)
                .where(getattr(model_class, pk_col) == entity_id, model_class.user_id == user_id)
                .values(**update_kwargs)
            )
        await db.execute(stmt)
    else:
        ins_stmt = insert(model_class).values(**kwargs)
        await db.execute(ins_stmt)

    changelog_hh_id: str | None = None
    if entity_type == "budget":
        raw_hh = kwargs.get("household_id")
        changelog_hh_id = str(raw_hh) if raw_hh else None
    elif entity_type == "transaction":
        is_shared = bool(kwargs.get("is_shared", False))
        raw_hh = kwargs.get("household_id")
        changelog_hh_id = str(raw_hh) if (is_shared and raw_hh) else None

    return revision, changelog_hh_id


async def tombstone_entity(
    db: AsyncSession,
    entity_type: str,
    entity_id: str,
    user_id: str,
    revision: int,
) -> tuple[int, str | None]:
    model_class = ENTITY_TYPE_MAP[entity_type]
    pk_col = "transaction_id" if entity_type == "receipt_extraction" else "id"

    existing = await get_entity(
        db,
        entity_type,
        entity_id,
        user_id,
        for_read=(entity_type == "budget"),
    )
    if not existing:
        return revision, None

    if entity_type == "budget":
        stmt = (
            update(model_class)
            .where(Budget.id == entity_id)
            .values(deleted_at=datetime.now(UTC), revision=revision, updated_at=datetime.now(UTC))
        )
        changelog_hh_id = getattr(existing, "household_id", None)
    else:
        stmt = (
            update(model_class)
            .where(getattr(model_class, pk_col) == entity_id, model_class.user_id == user_id)
            .values(deleted_at=datetime.now(UTC), revision=revision, updated_at=datetime.now(UTC))
        )
        is_shared = bool(getattr(existing, "is_shared", False))
        changelog_hh_id = getattr(existing, "household_id", None) if is_shared else None

    await db.execute(stmt)
    return revision, changelog_hh_id
