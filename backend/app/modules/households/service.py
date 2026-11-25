import secrets
from datetime import UTC, datetime, timedelta
from typing import Literal, cast

from sqlalchemy import and_, delete, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import ForbiddenError, NotFoundError
from app.core.security import generate_ulid
from app.db.models.budget import Budget
from app.db.models.household import Household, HouseholdInvite, HouseholdMember
from app.db.models.sync import ChangeLog
from app.db.models.transaction import Transaction
from app.modules.households.schemas import (
    AcceptInviteRequest,
    BudgetResponse,
    CreateBudgetRequest,
    CreateHouseholdRequest,
    CreateInviteRequest,
    HouseholdInviteResponse,
    HouseholdMemberResponse,
    HouseholdResponse,
    SharedTransactionResponse,
)


def _as_utc(dt: datetime) -> datetime:
    if dt.tzinfo is None:
        return dt.replace(tzinfo=UTC)
    return dt


async def get_user_household_ids(db: AsyncSession, user_id: str) -> list[str]:
    result = await db.execute(
        select(HouseholdMember.household_id).where(HouseholdMember.user_id == user_id)
    )
    return list(result.scalars().all())


async def require_household_membership(
    db: AsyncSession,
    household_id: str,
    user_id: str,
    *,
    require_owner: bool = False,
) -> HouseholdMember:
    hh_result = await db.execute(
        select(Household).where(
            Household.id == household_id,
            Household.deleted_at.is_(None),
        )
    )
    household = hh_result.scalar_one_or_none()
    if household is None:
        raise NotFoundError("Household not found")

    member_result = await db.execute(
        select(HouseholdMember).where(
            HouseholdMember.household_id == household_id,
            HouseholdMember.user_id == user_id,
        )
    )
    member = member_result.scalar_one_or_none()
    if member is None:
        raise ForbiddenError("You are not a member of this household")

    if require_owner and member.role != "owner":
        raise ForbiddenError("Only household owner can perform this action")

    return member


async def _append_changelog(
    db: AsyncSession,
    *,
    user_id: str,
    household_id: str | None,
    entity_type: str,
    entity_id: str,
    operation: str,
    revision: int,
    changed_at: datetime,
) -> None:
    cl = ChangeLog(
        user_id=user_id,
        household_id=household_id,
        entity_type=entity_type,
        entity_id=entity_id,
        operation=operation,
        revision=revision,
        device_id="api",
        changed_at=changed_at,
    )
    db.add(cl)
    if cl.sequence is None:
        with db.no_autoflush:
            mx = (
                await db.execute(select(func.coalesce(func.max(ChangeLog.sequence), 0)))
            ).scalar_one()
        cl.sequence = int(mx) + 1


class HouseholdService:
    async def create_household(
        self,
        db: AsyncSession,
        user_id: str,
        request: CreateHouseholdRequest,
    ) -> HouseholdResponse:
        now = datetime.now(UTC)
        household_id = generate_ulid()
        household = Household(
            id=household_id,
            name=request.name.strip(),
            created_by=user_id,
            created_at=now,
            updated_at=now,
        )
        member = HouseholdMember(
            household_id=household_id,
            user_id=user_id,
            role="owner",
            display_name=request.display_name,
            joined_at=now,
        )
        db.add(household)
        db.add(member)
        await db.commit()
        return await self.get_household(db, user_id, household_id)

    async def list_households(
        self,
        db: AsyncSession,
        user_id: str,
    ) -> list[HouseholdResponse]:
        hh_ids = await get_user_household_ids(db, user_id)
        if not hh_ids:
            return []

        res = await db.execute(
            select(Household)
            .where(Household.id.in_(hh_ids), Household.deleted_at.is_(None))
            .order_by(Household.created_at.desc())
        )
        households = res.scalars().all()
        return [await self._build_household_response(db, hh) for hh in households]

    async def get_household(
        self,
        db: AsyncSession,
        user_id: str,
        household_id: str,
    ) -> HouseholdResponse:
        await require_household_membership(db, household_id, user_id)
        res = await db.execute(
            select(Household).where(
                Household.id == household_id,
                Household.deleted_at.is_(None),
            )
        )
        hh = res.scalar_one_or_none()
        if hh is None:
            raise NotFoundError("Household not found")
        return await self._build_household_response(db, hh)

    async def _build_household_response(
        self,
        db: AsyncSession,
        household: Household,
    ) -> HouseholdResponse:
        members_res = await db.execute(
            select(HouseholdMember)
            .where(HouseholdMember.household_id == household.id)
            .order_by(HouseholdMember.joined_at.asc())
        )
        members = [
            HouseholdMemberResponse(
                household_id=m.household_id,
                user_id=m.user_id,
                role=cast(Literal["owner", "member"], m.role),
                display_name=m.display_name,
                joined_at=m.joined_at,
            )
            for m in members_res.scalars().all()
        ]
        return HouseholdResponse(
            id=household.id,
            name=household.name,
            created_by=household.created_by,
            created_at=household.created_at,
            members=members,
        )

    async def create_invite(
        self,
        db: AsyncSession,
        user_id: str,
        household_id: str,
        request: CreateInviteRequest,
    ) -> HouseholdInviteResponse:
        await require_household_membership(db, household_id, user_id, require_owner=True)
        now = datetime.now(UTC)
        invite_id = generate_ulid()
        code = f"BT-{secrets.token_urlsafe(6).upper()}"
        expires_at = now + timedelta(hours=request.expires_in_hours)
        invite = HouseholdInvite(
            id=invite_id,
            household_id=household_id,
            code=code,
            created_by=user_id,
            expires_at=expires_at,
            created_at=now,
        )
        db.add(invite)
        await db.commit()
        return HouseholdInviteResponse(
            id=invite_id,
            household_id=household_id,
            code=code,
            invite_link=f"billtracker://household/join?code={code}",
            expires_at=expires_at,
            created_at=now,
        )

    async def accept_invite(
        self,
        db: AsyncSession,
        user_id: str,
        request: AcceptInviteRequest,
    ) -> HouseholdResponse:
        now = datetime.now(UTC)
        res = await db.execute(
            select(HouseholdInvite).where(HouseholdInvite.code == request.code.strip())
        )
        invite = res.scalar_one_or_none()
        if invite is None:
            raise NotFoundError("Invite not found")
        if invite.revoked_at is not None:
            raise ForbiddenError("Invite has been revoked")
        if _as_utc(invite.expires_at) < now:
            raise ForbiddenError("Invite has expired")

        hh_res = await db.execute(
            select(Household).where(
                Household.id == invite.household_id,
                Household.deleted_at.is_(None),
            )
        )
        household = hh_res.scalar_one_or_none()
        if household is None:
            raise NotFoundError("Household not found")

        existing_res = await db.execute(
            select(HouseholdMember).where(
                HouseholdMember.household_id == invite.household_id,
                HouseholdMember.user_id == user_id,
            )
        )
        existing_member = existing_res.scalar_one_or_none()
        if existing_member is not None:
            return await self._build_household_response(db, household)

        if invite.accepted_by is not None and invite.accepted_by != user_id:
            raise ForbiddenError("Invite has already been used")

        member = HouseholdMember(
            household_id=invite.household_id,
            user_id=user_id,
            role="member",
            display_name=request.display_name,
            joined_at=now,
        )
        db.add(member)
        invite.accepted_by = user_id
        invite.accepted_at = now
        target_hh_id = invite.household_id
        await db.commit()
        return await self.get_household(db, user_id, target_hh_id)

    async def remove_member(
        self,
        db: AsyncSession,
        user_id: str,
        household_id: str,
        target_user_id: str,
    ) -> None:
        caller = await require_household_membership(db, household_id, user_id)
        if target_user_id != user_id and caller.role != "owner":
            raise ForbiddenError("Only household owner can remove other members")

        target_res = await db.execute(
            select(HouseholdMember).where(
                HouseholdMember.household_id == household_id,
                HouseholdMember.user_id == target_user_id,
            )
        )
        target = target_res.scalar_one_or_none()
        if target is None:
            raise NotFoundError("Household member not found")

        if target.role == "owner":
            all_members_res = await db.execute(
                select(HouseholdMember).where(HouseholdMember.household_id == household_id)
            )
            all_members = list(all_members_res.scalars().all())
            other_owners = [
                m for m in all_members if m.role == "owner" and m.user_id != target_user_id
            ]
            if not other_owners and len(all_members) > 1:
                raise ForbiddenError("Transfer ownership before leaving household")

        await db.execute(
            delete(HouseholdMember).where(
                HouseholdMember.household_id == household_id,
                HouseholdMember.user_id == target_user_id,
            )
        )
        await db.commit()

    async def list_budgets(
        self,
        db: AsyncSession,
        user_id: str,
        household_id: str | None = None,
    ) -> list[BudgetResponse]:
        if household_id is not None:
            await require_household_membership(db, household_id, user_id)
            stmt = select(Budget).where(
                Budget.household_id == household_id,
                Budget.deleted_at.is_(None),
            )
        else:
            hh_ids = await get_user_household_ids(db, user_id)
            if hh_ids:
                access_filter = or_(
                    and_(Budget.household_id.is_(None), Budget.user_id == user_id),
                    Budget.household_id.in_(hh_ids),
                )
            else:
                access_filter = and_(Budget.household_id.is_(None), Budget.user_id == user_id)
            stmt = select(Budget).where(Budget.deleted_at.is_(None), access_filter)

        res = await db.execute(stmt.order_by(Budget.updated_at.desc()))
        budgets = res.scalars().all()
        return [await self._build_budget_response(db, user_id, b) for b in budgets]

    async def get_budget(
        self,
        db: AsyncSession,
        user_id: str,
        budget_id: str,
    ) -> BudgetResponse:
        res = await db.execute(
            select(Budget).where(Budget.id == budget_id, Budget.deleted_at.is_(None))
        )
        budget = res.scalar_one_or_none()
        if budget is None:
            raise NotFoundError("Budget not found")

        if budget.household_id is not None:
            await require_household_membership(db, budget.household_id, user_id)
        elif budget.user_id != user_id:
            raise ForbiddenError("Access forbidden")

        return await self._build_budget_response(db, user_id, budget)

    async def create_budget(
        self,
        db: AsyncSession,
        user_id: str,
        request: CreateBudgetRequest,
        *,
        forced_household_id: str | None = None,
    ) -> BudgetResponse:
        household_id = (
            forced_household_id if forced_household_id is not None else request.household_id
        )
        if household_id is not None:
            await require_household_membership(db, household_id, user_id)

        now = datetime.now(UTC)
        budget_id = request.id or generate_ulid()

        existing_res = await db.execute(select(Budget).where(Budget.id == budget_id))
        existing = existing_res.scalar_one_or_none()
        if existing is not None:
            if existing.household_id is not None:
                await require_household_membership(db, existing.household_id, user_id)
            elif existing.user_id != user_id:
                raise ForbiddenError("Access forbidden")

            existing.household_id = household_id
            existing.category_id = request.category_id
            existing.period = request.period
            existing.amount_limit = request.amount_limit
            existing.alert_thresholds = request.alert_thresholds
            existing.period_start = request.period_start
            existing.period_end = request.period_end
            existing.deleted_at = None
            existing.revision = existing.revision + 1
            existing.updated_at = now
            budget = existing
        else:
            budget = Budget(
                id=budget_id,
                user_id=user_id,
                household_id=household_id,
                category_id=request.category_id,
                period=request.period,
                amount_limit=request.amount_limit,
                alert_thresholds=request.alert_thresholds,
                period_start=request.period_start,
                period_end=request.period_end,
                revision=1,
                updated_at=now,
                created_at=now,
            )
            db.add(budget)

        await _append_changelog(
            db,
            user_id=user_id,
            household_id=household_id,
            entity_type="budget",
            entity_id=budget.id,
            operation="upsert",
            revision=budget.revision,
            changed_at=now,
        )
        await db.commit()
        await db.refresh(budget)
        return await self._build_budget_response(db, user_id, budget)

    async def delete_budget(
        self,
        db: AsyncSession,
        user_id: str,
        budget_id: str,
    ) -> None:
        res = await db.execute(
            select(Budget).where(Budget.id == budget_id, Budget.deleted_at.is_(None))
        )
        budget = res.scalar_one_or_none()
        if budget is None:
            raise NotFoundError("Budget not found")

        if budget.household_id is not None:
            await require_household_membership(db, budget.household_id, user_id)
        elif budget.user_id != user_id:
            raise ForbiddenError("Access forbidden")

        now = datetime.now(UTC)
        budget.deleted_at = now
        budget.revision = budget.revision + 1
        budget.updated_at = now
        await _append_changelog(
            db,
            user_id=user_id,
            household_id=budget.household_id,
            entity_type="budget",
            entity_id=budget.id,
            operation="delete",
            revision=budget.revision,
            changed_at=now,
        )
        await db.commit()

    async def list_household_transactions(
        self,
        db: AsyncSession,
        user_id: str,
        household_id: str,
    ) -> list[SharedTransactionResponse]:
        await require_household_membership(db, household_id, user_id)
        member_names = await self._member_display_names(db, household_id)

        tx_res = await db.execute(
            select(Transaction)
            .where(
                Transaction.household_id == household_id,
                Transaction.is_shared.is_(True),
                Transaction.deleted_at.is_(None),
            )
            .order_by(Transaction.occurred_at.desc())
        )
        return [self._to_shared_tx_response(tx, member_names) for tx in tx_res.scalars().all()]

    async def _member_display_names(
        self,
        db: AsyncSession,
        household_id: str,
    ) -> dict[str, str]:
        res = await db.execute(
            select(HouseholdMember).where(HouseholdMember.household_id == household_id)
        )
        return {
            m.user_id: (m.display_name.strip() if m.display_name else m.user_id)
            for m in res.scalars().all()
        }

    def _to_shared_tx_response(
        self,
        tx: Transaction,
        member_names: dict[str, str],
    ) -> SharedTransactionResponse:
        return SharedTransactionResponse(
            id=tx.id,
            household_id=tx.household_id or "",
            category_id=tx.category_id,
            type=tx.type,
            amount=float(tx.amount),
            currency=tx.currency,
            merchant=tx.merchant,
            note=tx.note,
            occurred_at=tx.occurred_at,
            is_shared=tx.is_shared,
            created_by_user_id=tx.user_id,
            created_by_name=member_names.get(tx.user_id, tx.user_id),
        )

    async def _build_budget_response(
        self,
        db: AsyncSession,
        user_id: str,
        budget: Budget,
    ) -> BudgetResponse:
        if budget.household_id is not None:
            member_names = await self._member_display_names(db, budget.household_id)
            tx_stmt = (
                select(Transaction)
                .where(
                    Transaction.household_id == budget.household_id,
                    Transaction.is_shared.is_(True),
                    Transaction.category_id == budget.category_id,
                    Transaction.type == "expense",
                    Transaction.status == "confirmed",
                    Transaction.deleted_at.is_(None),
                    Transaction.occurred_at >= budget.period_start,
                    Transaction.occurred_at <= budget.period_end,
                )
                .order_by(Transaction.occurred_at.desc())
            )
            txs = list((await db.execute(tx_stmt)).scalars().all())
            recent = [self._to_shared_tx_response(tx, member_names) for tx in txs[:10]]
            spent = sum(float(tx.amount) for tx in txs)
        else:
            sum_stmt = select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                Transaction.user_id == user_id,
                Transaction.category_id == budget.category_id,
                Transaction.type == "expense",
                Transaction.status == "confirmed",
                Transaction.deleted_at.is_(None),
                Transaction.occurred_at >= budget.period_start,
                Transaction.occurred_at <= budget.period_end,
            )
            spent_val = (await db.execute(sum_stmt)).scalar_one()
            spent = float(spent_val or 0.0)
            recent = []

        limit = float(budget.amount_limit)
        progress = spent / limit if limit > 0 else 0.0
        return BudgetResponse(
            id=budget.id,
            household_id=budget.household_id,
            created_by_user_id=budget.user_id,
            category_id=budget.category_id,
            period=budget.period,
            amount_limit=limit,
            spent_amount=spent,
            progress_ratio=progress,
            alert_thresholds=budget.alert_thresholds,
            period_start=budget.period_start,
            period_end=budget.period_end,
            updated_at=budget.updated_at,
            recent_transactions=recent,
        )
