from datetime import datetime
from decimal import Decimal

from sqlalchemy import Boolean, DateTime, ForeignKey, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Budget(Base):
    __tablename__ = "budgets"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False)
    household_id: Mapped[str | None] = mapped_column(
        String, ForeignKey("households.id"), nullable=True, index=True
    )
    category_id: Mapped[str] = mapped_column(String)
    period: Mapped[str] = mapped_column(String, default="monthly")
    amount_limit: Mapped[Decimal] = mapped_column(Numeric(18, 4))
    alert_thresholds: Mapped[str] = mapped_column(String, default="[0.8, 1.0, 1.2]")
    alert_sent_at_80: Mapped[bool] = mapped_column(Boolean, default=False)
    alert_sent_at_100: Mapped[bool] = mapped_column(Boolean, default=False)
    period_start: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    period_end: Mapped[datetime] = mapped_column(DateTime(timezone=True))

    revision: Mapped[int] = mapped_column(default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
