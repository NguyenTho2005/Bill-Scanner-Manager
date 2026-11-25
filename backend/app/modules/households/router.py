from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.user import User
from app.db.session import get_db
from app.dependencies import get_current_user
from app.modules.households.schemas import (
    AcceptInviteRequest,
    BudgetResponse,
    CreateBudgetRequest,
    CreateHouseholdRequest,
    CreateInviteRequest,
    HouseholdInviteResponse,
    HouseholdResponse,
    SharedTransactionResponse,
)
from app.modules.households.service import HouseholdService

router = APIRouter(prefix="/households", tags=["households"])
budgets_router = APIRouter(prefix="/budgets", tags=["budgets"])
household_service = HouseholdService()


@router.post("", response_model=HouseholdResponse, status_code=201)
async def create_household(
    body: CreateHouseholdRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> HouseholdResponse:
    return await household_service.create_household(db, current_user.id, body)


@router.get("", response_model=list[HouseholdResponse])
async def list_households(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[HouseholdResponse]:
    return await household_service.list_households(db, current_user.id)


@router.post("/invites/accept", response_model=HouseholdResponse)
async def accept_invite(
    body: AcceptInviteRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> HouseholdResponse:
    return await household_service.accept_invite(db, current_user.id, body)


@router.get("/{household_id}", response_model=HouseholdResponse)
async def get_household(
    household_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> HouseholdResponse:
    return await household_service.get_household(db, current_user.id, household_id)


@router.post("/{household_id}/invites", response_model=HouseholdInviteResponse, status_code=201)
async def create_invite(
    household_id: str,
    body: CreateInviteRequest | None = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> HouseholdInviteResponse:
    return await household_service.create_invite(
        db, current_user.id, household_id, body or CreateInviteRequest()
    )


@router.delete("/{household_id}/members/{member_user_id}")
async def remove_member(
    household_id: str,
    member_user_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, str]:
    await household_service.remove_member(db, current_user.id, household_id, member_user_id)
    return {"status": "removed"}


@router.get("/{household_id}/budgets", response_model=list[BudgetResponse])
async def list_household_budgets(
    household_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[BudgetResponse]:
    return await household_service.list_budgets(db, current_user.id, household_id=household_id)


@router.post("/{household_id}/budgets", response_model=BudgetResponse, status_code=201)
async def create_household_budget(
    household_id: str,
    body: CreateBudgetRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> BudgetResponse:
    return await household_service.create_budget(
        db, current_user.id, body, forced_household_id=household_id
    )


@router.get("/{household_id}/transactions", response_model=list[SharedTransactionResponse])
async def list_household_transactions(
    household_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[SharedTransactionResponse]:
    return await household_service.list_household_transactions(db, current_user.id, household_id)


@budgets_router.get("", response_model=list[BudgetResponse])
async def list_budgets(
    household_id: str | None = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> list[BudgetResponse]:
    return await household_service.list_budgets(db, current_user.id, household_id=household_id)


@budgets_router.post("", response_model=BudgetResponse, status_code=201)
async def create_budget(
    body: CreateBudgetRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> BudgetResponse:
    return await household_service.create_budget(db, current_user.id, body)


@budgets_router.get("/{budget_id}", response_model=BudgetResponse)
async def get_budget(
    budget_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> BudgetResponse:
    return await household_service.get_budget(db, current_user.id, budget_id)


@budgets_router.delete("/{budget_id}")
async def delete_budget(
    budget_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> dict[str, str]:
    await household_service.delete_budget(db, current_user.id, budget_id)
    return {"status": "deleted"}
