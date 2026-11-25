import json
from datetime import UTC, datetime, timedelta
from typing import Any, Literal, cast

from fastapi import HTTPException
from pydantic import BaseModel
from sqlalchemy import and_, func, literal, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.budget import Budget
from app.db.models.household import HouseholdMember
from app.db.models.sync import ChangeLog, SyncIdempotency
from app.db.models.transaction import Transaction
from app.modules.sync.conflict import check_and_resolve
from app.modules.sync.entity_serializer import (
    ENTITY_TYPE_MAP,
    get_entity,
    get_household_member_names,
    serialize_entity,
    tombstone_entity,
    upsert_entity,
)
from app.modules.sync.schemas import (
    AcknowledgedOp,
    BootstrapEntity,
    BootstrapResponse,
    ConflictEntry,
    PullResponse,
    PushRequest,
    PushResponse,
    SyncChange,
)


def _json_default(o: Any) -> Any:
    """json.dumps default handler: BaseModel → dict (E4)."""
    if isinstance(o, BaseModel):
        return o.model_dump(mode="json")
    raise TypeError(f"Object of type {type(o).__name__} is not JSON serializable")


def _json_dump(obj: Any) -> str:
    """Serialize payloads containing Decimal/Pydantic values to JSON (E4)."""
    return json.dumps(obj, default=_json_default)


async def _user_household_ids(db: AsyncSession, user_id: str) -> list[str]:
    result = await db.execute(
        select(HouseholdMember.household_id).where(HouseholdMember.user_id == user_id)
    )
    return list(result.scalars().all())


class SyncService:
    async def push(
        self,
        db: AsyncSession,
        user_id: str,
        device_id: str,
        request: PushRequest,
    ) -> PushResponse:
        if request.device_id != device_id:
            raise HTTPException(status_code=403, detail="Device ID mismatch")

        acknowledged: list[AcknowledgedOp] = []
        conflicts: list[ConflictEntry] = []

        for op in request.operations:
            stmt = select(SyncIdempotency).where(
                SyncIdempotency.operation_id == op.operation_id,
                SyncIdempotency.user_id == user_id,
                SyncIdempotency.device_id == device_id,
            )
            result = await db.execute(stmt)
            idemp = result.scalar_one_or_none()

            if idemp:
                resp_data = json.loads(idemp.response_hash)
                if resp_data.get("type") == "ack":
                    acknowledged.append(AcknowledgedOp(**resp_data["data"]))
                else:
                    conflicts.append(ConflictEntry(**resp_data["data"]))
                continue

            async with db.begin_nested():
                conflict_res = await check_and_resolve(db, op, user_id)

                if conflict_res.is_conflict:
                    conflict_type = cast(
                        Literal["revision_mismatch", "tombstone_wins"],
                        conflict_res.conflict_type or "revision_mismatch",
                    )
                    conflict = ConflictEntry(
                        operation_id=op.operation_id,
                        entity_id=op.entity_id,
                        entity_type=op.entity_type,
                        conflict_type=conflict_type,
                        server_revision=getattr(conflict_res.server_entity, "revision", 0)
                        if conflict_res.server_entity
                        else 0,
                        server_payload=serialize_entity(op.entity_type, conflict_res.server_entity)
                        if conflict_res.server_entity
                        and getattr(conflict_res.server_entity, "deleted_at", None) is None
                        else None,
                        hint="server_wins",
                    )
                    conflicts.append(conflict)

                    idemp_rec = SyncIdempotency(
                        operation_id=op.operation_id,
                        user_id=user_id,
                        device_id=device_id,
                        response_hash=_json_dump({"type": "conflict", "data": conflict}),
                        created_at=datetime.now(UTC),
                        expires_at=datetime.now(UTC) + timedelta(days=30),
                    )
                    db.add(idemp_rec)

                else:
                    new_revision = op.base_revision + 1

                    if op.operation == "upsert":
                        _, changelog_hh_id = await upsert_entity(
                            db,
                            op.entity_type,
                            op.entity_id,
                            user_id,
                            op.payload or {},
                            new_revision,
                        )
                    else:
                        _, changelog_hh_id = await tombstone_entity(
                            db, op.entity_type, op.entity_id, user_id, new_revision
                        )

                    cl = ChangeLog(
                        user_id=user_id,
                        household_id=changelog_hh_id,
                        entity_type=op.entity_type,
                        entity_id=op.entity_id,
                        operation=op.operation,
                        revision=new_revision,
                        device_id=device_id,
                        changed_at=datetime.now(UTC),
                    )
                    db.add(cl)

                    if cl.sequence is None:
                        with db.no_autoflush:
                            mx = (
                                await db.execute(
                                    select(func.coalesce(func.max(ChangeLog.sequence), 0))
                                )
                            ).scalar_one()
                        cl.sequence = int(mx) + 1
                    await db.flush()

                    ack = AcknowledgedOp(
                        operation_id=op.operation_id,
                        entity_id=op.entity_id,
                        revision=new_revision,
                        sequence=cl.sequence,
                    )
                    acknowledged.append(ack)

                    idemp_rec = SyncIdempotency(
                        operation_id=op.operation_id,
                        user_id=user_id,
                        device_id=device_id,
                        response_hash=json.dumps({"type": "ack", "data": ack.model_dump()}),
                        created_at=datetime.now(UTC),
                        expires_at=datetime.now(UTC) + timedelta(days=30),
                    )
                    db.add(idemp_rec)

        await db.commit()

        hh_ids = await _user_household_ids(db, user_id)
        seq_filter = (
            or_(ChangeLog.user_id == user_id, ChangeLog.household_id.in_(hh_ids))
            if hh_ids
            else ChangeLog.user_id == user_id
        )
        max_seq_stmt = select(func.max(ChangeLog.sequence)).where(seq_filter)
        max_seq = (await db.execute(max_seq_stmt)).scalar_one_or_none() or 0

        return PushResponse(
            acknowledged=acknowledged, conflicts=conflicts, server_cursor=f"seq_{max_seq:018d}"
        )

    async def pull(
        self,
        db: AsyncSession,
        user_id: str,
        cursor: str,
        limit: int = 200,
    ) -> PullResponse:
        if not cursor:
            raise HTTPException(status_code=422, detail="Cursor is required")

        try:
            seq = int(cursor.replace("seq_", ""))
        except ValueError:
            raise HTTPException(status_code=422, detail="Invalid cursor format") from None

        hh_ids = await _user_household_ids(db, user_id)
        member_names = await get_household_member_names(db, hh_ids)

        owner_or_hh = (
            or_(ChangeLog.user_id == user_id, ChangeLog.household_id.in_(hh_ids))
            if hh_ids
            else ChangeLog.user_id == user_id
        )

        stmt = (
            select(ChangeLog)
            .where(owner_or_hh, ChangeLog.sequence > seq)
            .order_by(ChangeLog.sequence)
            .limit(limit + 1)
        )

        result = await db.execute(stmt)
        logs = list(result.scalars().all())

        has_more = len(logs) > limit
        if has_more:
            logs = logs[:limit]

        changes: list[SyncChange] = []
        for log in logs:
            entity = await get_entity(db, log.entity_type, log.entity_id, user_id, for_read=True)
            # Never expose private transactions (is_shared=False) to other household members
            if (
                log.user_id != user_id
                and log.entity_type == "transaction"
                and (entity is None or not getattr(entity, "is_shared", False))
            ):
                continue

            payload = (
                serialize_entity(log.entity_type, entity, member_names=member_names)
                if entity and getattr(entity, "deleted_at", None) is None
                else None
            )

            changes.append(
                SyncChange(
                    entity_type=log.entity_type,
                    entity_id=log.entity_id,
                    operation=cast(Literal["upsert", "delete"], log.operation),
                    revision=log.revision,
                    updated_at=log.changed_at,
                    payload=payload,
                    sequence=log.sequence,
                )
            )

        next_cursor = cursor
        if logs:
            next_cursor = f"seq_{logs[-1].sequence:018d}"

        return PullResponse(changes=changes, next_cursor=next_cursor, has_more=has_more)

    async def bootstrap(
        self,
        db: AsyncSession,
        user_id: str,
        page: int = 0,
        page_size: int = 100,
    ) -> BootstrapResponse:
        hh_ids = await _user_household_ids(db, user_id)
        member_names = await get_household_member_names(db, hh_ids)

        seq_filter = (
            or_(ChangeLog.user_id == user_id, ChangeLog.household_id.in_(hh_ids))
            if hh_ids
            else ChangeLog.user_id == user_id
        )
        max_seq = (
            await db.execute(select(func.max(ChangeLog.sequence)).where(seq_filter))
        ).scalar_one_or_none() or 0
        bootstrap_cursor = f"seq_{max_seq:018d}"

        entities: list[BootstrapEntity] = []
        offset = page * page_size
        end = offset + page_size

        global_start = 0
        total = 0
        for entity_type, model_class in ENTITY_TYPE_MAP.items():
            if entity_type == "budget" and hh_ids:
                scope_filter: Any = or_(
                    and_(Budget.household_id.is_(None), Budget.user_id == user_id),
                    Budget.household_id.in_(hh_ids),
                )
            elif entity_type == "transaction" and hh_ids:
                scope_filter = or_(
                    Transaction.user_id == user_id,
                    and_(
                        Transaction.household_id.in_(hh_ids),
                        Transaction.is_shared.is_(True),
                    ),
                )
            else:
                scope_filter = model_class.user_id == user_id

            table_total = (
                await db.execute(
                    select(func.count())
                    .select_from(model_class)
                    .where(
                        scope_filter,
                        model_class.deleted_at.is_(None),
                    )
                )
            ).scalar_one()
            table_start = global_start
            global_start += table_total
            total += table_total

            if table_start + table_total <= offset or table_start >= end:
                continue

            local_offset = max(offset - table_start, 0)
            local_limit = min(end - table_start, table_total) - local_offset
            if local_limit <= 0:
                continue

            pk_col = getattr(
                model_class, "transaction_id" if entity_type == "receipt_extraction" else "id"
            )
            q = (
                select(model_class, literal(entity_type).label("_entity_type"))
                .where(
                    scope_filter,
                    model_class.deleted_at.is_(None),
                )
                .order_by(pk_col)
                .offset(local_offset)
                .limit(local_limit)
            )
            res = await db.execute(q)
            for row in res.all():
                etype, entity = row[1], row[0]
                pk = getattr(entity, "transaction_id" if etype == "receipt_extraction" else "id")
                entities.append(
                    BootstrapEntity(
                        entity_type=etype,
                        entity_id=pk,
                        revision=getattr(entity, "revision", 0),
                        updated_at=getattr(entity, "updated_at", datetime.now(UTC)),
                        payload=serialize_entity(etype, entity, member_names=member_names),
                    )
                )

        total_pages = (total + page_size - 1) // page_size

        return BootstrapResponse(
            entities=entities, page=page, total_pages=total_pages, bootstrap_cursor=bootstrap_cursor
        )
