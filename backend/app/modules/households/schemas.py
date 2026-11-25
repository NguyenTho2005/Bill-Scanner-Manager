from datetime import datetime
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, Field


class CreateHouseholdRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    display_name: str | None = Field(default=None, max_length=80)


class HouseholdMemberResponse(BaseModel):
    household_id: str
    user_id: str
    role: Literal["owner", "member"]
    display_name: str | None = None
    joined_at: datetime


class HouseholdResponse(BaseModel):
    id: str
    name: str
    created_by: str
    created_at: datetime
    members: list[HouseholdMemberResponse]


class CreateInviteRequest(BaseModel):
    expires_in_hours: int = Field(default=72, ge=1, le=720)


class HouseholdInviteResponse(BaseModel):
    id: str
    household_id: str
    code: str
    invite_link: str
    expires_at: datetime
    created_at: datetime


class AcceptInviteRequest(BaseModel):
    code: str = Field(..., min_length=4, max_length=64)
    display_name: str | None = Field(default=None, max_length=80)


class SharedTransactionResponse(BaseModel):
    id: str
    household_id: str
    category_id: str
    type: str
    amount: float
    currency: str
    merchant: str | None = None
    note: str | None = None
    occurred_at: datetime
    is_shared: bool
    created_by_user_id: str
    created_by_name: str


class CreateBudgetRequest(BaseModel):
    id: str | None = Field(default=None, max_length=64)
    household_id: str | None = Field(default=None, max_length=64)
    category_id: str = Field(..., min_length=1, max_length=64)
    period: Literal["monthly", "weekly", "custom"] = "monthly"
    amount_limit: Decimal = Field(..., gt=0)
    alert_thresholds: str = "[0.8, 1.0, 1.2]"
    period_start: datetime
    period_end: datetime


class BudgetResponse(BaseModel):
    id: str
    household_id: str | None = None
    created_by_user_id: str
    category_id: str
    period: str
    amount_limit: float
    spent_amount: float
    progress_ratio: float
    alert_thresholds: str
    period_start: datetime
    period_end: datetime
    updated_at: datetime
    recent_transactions: list[SharedTransactionResponse] = Field(default_factory=list)
