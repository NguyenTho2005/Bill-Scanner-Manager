from datetime import UTC, datetime, timedelta

import structlog
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from ulid import ULID

from app.config import get_settings
from app.core.errors import MediaValidationError, NotFoundError, QuotaExceededError
from app.db.models.media import Media
from app.db.models.sync import ChangeLog

from .schemas import (
    CompleteUploadRequest,
    CompleteUploadResponse,
    DownloadIntentResponse,
    UploadIntentRequest,
    UploadIntentResponse,
)
from .storage import StorageClient

logger = structlog.get_logger()


class MediaService:
    def __init__(self, storage: StorageClient):
        self.storage = storage
        settings = get_settings()
        # Quota is configuration-driven (§4.6 #9), never hardcoded.
        self.MAX_QUOTA_BYTES = settings.MEDIA_QUOTA_PER_USER_BYTES
        self.upload_url_ttl = settings.S3_UPLOAD_URL_TTL
        self.download_url_ttl = settings.S3_DOWNLOAD_URL_TTL

    async def create_upload_intent(
        self,
        db: AsyncSession,
        user_id: str,
        request: UploadIntentRequest,
    ) -> UploadIntentResponse:
        # Check user quota
        stmt = select(func.coalesce(func.sum(Media.size_bytes), 0)).where(
            Media.user_id == user_id, Media.state == "ready"
        )
        result = await db.execute(stmt)
        current_usage = result.scalar() or 0

        if current_usage + request.size_bytes > self.MAX_QUOTA_BYTES:
            raise QuotaExceededError()

        media_id = str(ULID())
        suffix = request.content_type.split("/")[-1]
        object_key = self.storage.generate_object_key(user_id, media_id, suffix)
        now = datetime.now(UTC)

        media = Media(
            id=media_id,
            user_id=user_id,
            transaction_id=request.transaction_id,
            object_key=object_key,
            content_hash=request.content_hash,
            size_bytes=request.size_bytes,
            mime_type=request.content_type,
            media_type=request.media_type,
            state="pending_upload",
            width=request.width,
            height=request.height,
            captured_at=request.captured_at,
            revision=1,
            created_at=now,
            updated_at=now,
        )
        db.add(media)

        await db.commit()

        upload_url = await self.storage.generate_upload_url(
            object_key=object_key,
            content_type=request.content_type,
            expires=self.upload_url_ttl,
        )

        # NEVER log upload_url
        logger.info("upload_intent_created", user_id=user_id, media_id=media_id)

        return UploadIntentResponse(
            media_id=media_id,
            upload_url=upload_url,
            expires_at=now + timedelta(seconds=self.upload_url_ttl),
        )

    async def complete_upload(
        self,
        db: AsyncSession,
        user_id: str,
        media_id: str,
        request: CompleteUploadRequest,
        device_id: str,
    ) -> CompleteUploadResponse:
        stmt = select(Media).where(Media.id == media_id, Media.user_id == user_id)
        result = await db.execute(stmt)
        media = result.scalar_one_or_none()

        if not media:
            raise NotFoundError("Media not found")

        if media.state != "pending_upload":
            raise MediaValidationError("Media is not pending upload")

        metadata = await self.storage.get_object_metadata(media.object_key)
        if not metadata:
            raise MediaValidationError("Object not found in storage")

        first_bytes = await self.storage.read_first_bytes(media.object_key)
        if not self.storage.validate_mime_from_magic_bytes(first_bytes, media.mime_type):
            raise MediaValidationError("Invalid file signature")

        actual_size = metadata.get("ContentLength", 0)
        if actual_size != request.size_bytes or actual_size != media.size_bytes:
            raise MediaValidationError("Size mismatch")

        if request.content_hash != media.content_hash:
            raise MediaValidationError("Hash mismatch")

        now = datetime.now(UTC)
        media.state = "ready"
        media.revision += 1
        media.updated_at = now
        media_state = media.state
        media_revision = media.revision

        log_entry = ChangeLog(
            user_id=user_id,
            entity_type="media",
            entity_id=media_id,
            operation="upsert",
            revision=media_revision,
            device_id=device_id,
            changed_at=now,
        )
        db.add(log_entry)

        # C.2 — ensure a sequence exists even on SQLite (no auto-increment)
        if log_entry.sequence is None:
            with db.no_autoflush:
                mx = (
                    await db.execute(select(func.coalesce(func.max(ChangeLog.sequence), 0)))
                ).scalar_one()
            log_entry.sequence = int(mx) + 1

        await db.commit()

        logger.info("upload_completed", user_id=user_id, media_id=media_id)

        return CompleteUploadResponse(media_id=media_id, state=media_state, revision=media_revision)

    async def get_download_intent(
        self,
        db: AsyncSession,
        user_id: str,
        media_id: str,
    ) -> DownloadIntentResponse:
        stmt = select(Media).where(
            Media.id == media_id,
            Media.user_id == user_id,
            Media.state == "ready",
            Media.deleted_at.is_(None),
        )
        result = await db.execute(stmt)
        media = result.scalar_one_or_none()

        if not media:
            raise NotFoundError("Media not found")

        download_url = await self.storage.generate_download_url(
            media.object_key, expires=self.download_url_ttl
        )
        now = datetime.now(UTC)

        return DownloadIntentResponse(
            media_id=media_id,
            download_url=download_url,
            expires_at=now + timedelta(seconds=self.download_url_ttl),
        )

    async def delete_media(
        self,
        db: AsyncSession,
        user_id: str,
        media_id: str,
        device_id: str,
    ) -> None:
        stmt = select(Media).where(Media.id == media_id, Media.user_id == user_id)
        result = await db.execute(stmt)
        media = result.scalar_one_or_none()

        if not media or media.deleted_at:
            raise NotFoundError("Media not found")

        now = datetime.now(UTC)
        media.deleted_at = now
        media.state = "deleted"
        media.revision += 1
        media.updated_at = now
        object_key = media.object_key

        log_entry = ChangeLog(
            user_id=user_id,
            entity_type="media",
            entity_id=media_id,
            operation="delete",
            revision=media.revision,
            device_id=device_id,
            changed_at=now,
        )
        db.add(log_entry)

        # C.2 — ensure a sequence exists even on SQLite (no auto-increment)
        if log_entry.sequence is None:
            with db.no_autoflush:
                mx = (
                    await db.execute(select(func.coalesce(func.max(ChangeLog.sequence), 0)))
                ).scalar_one()
            log_entry.sequence = int(mx) + 1

        await db.commit()

        import asyncio

        asyncio.create_task(self.storage.delete_object(object_key))
