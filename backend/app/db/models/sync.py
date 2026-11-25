from datetime import datetime

from sqlalchemy import BigInteger, DateTime, ForeignKey, Index, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class ChangeLog(Base):
    __tablename__ = "change_log"
    sequence: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"))
    household_id: Mapped[str | None] = mapped_column(String, nullable=True, index=True)
    entity_type: Mapped[str] = mapped_column(String)
    entity_id: Mapped[str] = mapped_column(String)
    operation: Mapped[str] = mapped_column(String)
    revision: Mapped[int] = mapped_column(Integer)
    device_id: Mapped[str] = mapped_column(String)
    changed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))

    __table_args__ = (Index("ix_changelog_user_seq", "user_id", "sequence"),)


class SyncIdempotency(Base):
    __tablename__ = "sync_idempotency"
    operation_id: Mapped[str] = mapped_column(String, primary_key=True)
    user_id: Mapped[str] = mapped_column(String)
    device_id: Mapped[str] = mapped_column(String)
    response_hash: Mapped[str] = mapped_column(String)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))

    __table_args__ = (
        UniqueConstraint("user_id", "device_id", "operation_id", name="uix_sync_idemp"),
    )
