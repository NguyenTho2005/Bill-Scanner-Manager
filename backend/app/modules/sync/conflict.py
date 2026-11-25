from typing import Any

from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.sync.entity_serializer import get_entity
from app.modules.sync.schemas import SyncOperation


class ConflictResult:
    def __init__(
        self, is_conflict: bool, conflict_type: str | None = None, server_entity: Any | None = None
    ):
        self.is_conflict = is_conflict
        self.conflict_type = conflict_type
        self.server_entity = server_entity


async def check_and_resolve(
    db: AsyncSession,
    operation: SyncOperation,
    user_id: str,
) -> ConflictResult:
    entity = await get_entity(
        db,
        operation.entity_type,
        operation.entity_id,
        user_id,
        for_read=(operation.entity_type == "budget"),
    )

    if not entity:
        return ConflictResult(is_conflict=False)

    server_revision = getattr(entity, "revision", 0)
    deleted_at = getattr(entity, "deleted_at", None)

    if operation.operation == "upsert":
        if deleted_at is not None and operation.base_revision <= server_revision:
            return ConflictResult(
                is_conflict=True, conflict_type="tombstone_wins", server_entity=entity
            )
        elif server_revision > operation.base_revision and deleted_at is None:
            return ConflictResult(
                is_conflict=True, conflict_type="revision_mismatch", server_entity=entity
            )
    elif operation.operation == "delete":
        if deleted_at is not None:
            # idempotent
            return ConflictResult(is_conflict=False)
        elif server_revision > operation.base_revision:
            return ConflictResult(
                is_conflict=True, conflict_type="revision_mismatch", server_entity=entity
            )

    return ConflictResult(is_conflict=False)
