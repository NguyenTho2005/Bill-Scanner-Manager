from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, model_validator


class SyncOperation(BaseModel):
    operation_id: str
    entity_type: Literal[
        "transaction",
        "category",
        "budget",
        "media",
        "receipt_extraction",
        "receipt_line_item",
        "ai_inference",
    ]
    entity_id: str
    operation: Literal["upsert", "delete"]
    base_revision: int
    occurred_at: datetime
    payload: dict[str, Any] | None = None


class PushRequest(BaseModel):
    device_id: str
    operations: list[SyncOperation]

    @model_validator(mode="after")
    def validate_max_ops(self):
        if len(self.operations) > 100:
            raise ValueError("Maximum 100 operations allowed per push request")
        return self


class AcknowledgedOp(BaseModel):
    operation_id: str
    entity_id: str
    revision: int
    sequence: int


class ConflictEntry(BaseModel):
    operation_id: str
    entity_id: str
    entity_type: str
    conflict_type: Literal["revision_mismatch", "tombstone_wins"]
    server_revision: int
    server_payload: dict[str, Any] | None
    hint: str


class PushResponse(BaseModel):
    acknowledged: list[AcknowledgedOp]
    conflicts: list[ConflictEntry]
    server_cursor: str


class SyncChange(BaseModel):
    entity_type: str
    entity_id: str
    operation: Literal["upsert", "delete"]
    revision: int
    updated_at: datetime
    payload: dict[str, Any] | None
    sequence: int


class PullResponse(BaseModel):
    changes: list[SyncChange]
    next_cursor: str
    has_more: bool


class BootstrapEntity(BaseModel):
    entity_type: str
    entity_id: str
    revision: int
    updated_at: datetime
    payload: dict[str, Any]


class BootstrapResponse(BaseModel):
    entities: list[BootstrapEntity]
    page: int
    total_pages: int
    bootstrap_cursor: str
