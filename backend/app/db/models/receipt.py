from datetime import datetime
from decimal import Decimal

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class ReceiptExtraction(Base):
    __tablename__ = "receipt_extractions"
    transaction_id: Mapped[str] = mapped_column(
        String, ForeignKey("transactions.id"), primary_key=True
    )
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False)
    merchant: Mapped[str | None] = mapped_column(String, nullable=True)
    merchant_confidence: Mapped[float | None] = mapped_column(Float, nullable=True)
    merchant_user_edited: Mapped[bool] = mapped_column(Boolean, default=False)
    transaction_date: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    date_confidence: Mapped[float | None] = mapped_column(Float, nullable=True)
    total: Mapped[Decimal | None] = mapped_column(Numeric(18, 4), nullable=True)
    total_confidence: Mapped[float | None] = mapped_column(Float, nullable=True)
    subtotal: Mapped[Decimal | None] = mapped_column(Numeric(18, 4), nullable=True)
    tax: Mapped[Decimal | None] = mapped_column(Numeric(18, 4), nullable=True)
    payment_method: Mapped[str | None] = mapped_column(String, nullable=True)
    overall_confidence: Mapped[float] = mapped_column(Float)
    requires_review: Mapped[bool] = mapped_column(Boolean, default=False)

    revision: Mapped[int] = mapped_column(default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class ReceiptLineItem(Base):
    __tablename__ = "receipt_line_items"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    transaction_id: Mapped[str] = mapped_column(String, ForeignKey("transactions.id"))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False)
    name: Mapped[str] = mapped_column(String)
    quantity: Mapped[float | None] = mapped_column(Float, nullable=True)
    unit_price: Mapped[Decimal | None] = mapped_column(Numeric(18, 4), nullable=True)
    total: Mapped[Decimal] = mapped_column(Numeric(18, 4))
    category_suggestion: Mapped[str | None] = mapped_column(String, nullable=True)
    confidence: Mapped[float] = mapped_column(Float, default=1.0)

    revision: Mapped[int] = mapped_column(default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
