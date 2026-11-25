from datetime import datetime

from sqlalchemy import DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class AIInference(Base):
    __tablename__ = "ai_inferences"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    media_id: Mapped[str] = mapped_column(String, ForeignKey("media.id"))
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False)
    model_version: Mapped[str] = mapped_column(String)
    labels_json: Mapped[dict] = mapped_column(JSONB)
    suggested_category_id: Mapped[str | None] = mapped_column(String, nullable=True)
    suggested_category_confidence: Mapped[float | None] = mapped_column(Float, nullable=True)
    extracted_amounts_json: Mapped[list] = mapped_column(JSONB)
    confidence: Mapped[float] = mapped_column(Float)
    latency_ms: Mapped[int] = mapped_column(Integer)
    source: Mapped[str] = mapped_column(String, default="on_device")

    revision: Mapped[int] = mapped_column(default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
