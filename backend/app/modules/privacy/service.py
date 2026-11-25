import json
import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import NotFoundError
from app.db.models.account import ExportJob
from app.db.models.budget import Budget
from app.db.models.category import Category
from app.db.models.media import Media
from app.db.models.transaction import Transaction
from app.db.models.user import Device, RefreshToken, User
from app.modules.media.storage import StorageClient

from .schemas import DeleteAccountResponse, ExportJobResponse


class PrivacyService:
    def __init__(self, storage: StorageClient):
        self.storage = storage

    async def request_export(
        self,
        db: AsyncSession,
        user_id: str,
    ) -> ExportJobResponse:
        job_id = str(uuid.uuid4())
        now = datetime.now(UTC)
        expires_at = now + timedelta(days=1)

        # Track the job from the start (§4.6 #12) so clients can poll status.
        job = ExportJob(
            id=job_id,
            user_id=user_id,
            status="processing",
            created_at=now,
        )
        db.add(job)
        await db.commit()

        # P1 synchronous export (job row keeps the result queryable).
        transactions = await db.execute(
            select(Transaction).where(
                Transaction.user_id == user_id, Transaction.deleted_at.is_(None)
            )
        )
        categories = await db.execute(
            select(Category).where(Category.user_id == user_id, Category.deleted_at.is_(None))
        )
        budgets = await db.execute(
            select(Budget).where(Budget.user_id == user_id, Budget.deleted_at.is_(None))
        )
        media = await db.execute(
            select(Media).where(Media.user_id == user_id, Media.deleted_at.is_(None))
        )

        export_data = {
            "transactions": [
                {
                    "id": t.id,
                    "amount": float(t.amount) if t.amount else 0.0,
                    "type": t.type,
                    "currency": t.currency,
                    "occurred_at": t.occurred_at.isoformat() if t.occurred_at else None,
                    "note": t.note,
                    "merchant": t.merchant,
                    "category_id": t.category_id,
                    "status": t.status,
                }
                for t in transactions.scalars().all()
            ],
            "categories": [
                {
                    "id": c.id,
                    "name": c.name,
                    "icon": c.icon,
                    "color_value": c.color_value,
                }
                for c in categories.scalars().all()
            ],
            "budgets": [
                {
                    "id": b.id,
                    "category_id": b.category_id,
                    "amount_limit": float(b.amount_limit) if b.amount_limit else 0.0,
                    "period": b.period,
                }
                for b in budgets.scalars().all()
            ],
            "media": [
                {
                    "id": m.id,
                    "media_type": m.media_type,
                    "size_bytes": m.size_bytes,
                    "captured_at": m.captured_at.isoformat() if m.captured_at else None,
                }
                for m in media.scalars().all()
            ],
        }

        json_content = json.dumps(export_data).encode("utf-8")
        object_key = f"exports/{user_id}/{job_id}.json"

        try:
            # Use storage client
            async with self.storage._client() as client:
                await client.put_object(
                    Bucket=self.storage.bucket,
                    Key=object_key,
                    Body=json_content,
                    ContentType="application/json",
                )

            download_url = await self.storage.generate_download_url(
                object_key=object_key,
                expires=86400,  # 24h
            )
        except Exception:
            job.status = "failed"
            await db.commit()
            raise

        # Mark the job ready with its downloadable key (§4.6 #12).
        completed_at = datetime.now(UTC)
        job.status = "ready"
        job.download_key = object_key
        job.ready_at = completed_at
        job.expires_at = expires_at
        await db.commit()

        return ExportJobResponse(
            job_id=job_id,
            status="ready",
            download_url=download_url,
            expires_at=expires_at,
            created_at=now,
        )

    async def get_export_job(
        self,
        db: AsyncSession,
        user_id: str,
        job_id: str,
    ) -> ExportJobResponse:
        """Fetch a previously created export job for status polling (§4.6 #12)."""
        stmt = select(ExportJob).where(
            ExportJob.id == job_id,
            ExportJob.user_id == user_id,
        )
        job = (await db.execute(stmt)).scalar_one_or_none()
        if not job:
            raise NotFoundError("Export job not found")

        now = datetime.now(UTC)
        status = job.status
        expires_at = job.expires_at
        if expires_at is not None and expires_at.tzinfo is None:
            # SQLite (tests) returns naive datetimes; treat stored values as UTC.
            expires_at = expires_at.replace(tzinfo=UTC)
        if status == "ready" and expires_at is not None and expires_at < now:
            status = "expired"

        download_url: str | None = None
        if status == "ready" and job.download_key:
            download_url = await self.storage.generate_download_url(
                object_key=job.download_key,
                expires=86400,
            )

        return ExportJobResponse(
            job_id=job.id,
            status=status,
            download_url=download_url,
            expires_at=job.expires_at,
            created_at=job.created_at,
        )

    async def request_account_deletion(
        self,
        db: AsyncSession,
        user_id: str,
    ) -> DeleteAccountResponse:
        now = datetime.now(UTC)
        scheduled_delete_at = now + timedelta(days=30)

        # 3. IMMEDIATELY: Revoke ALL refresh_tokens
        await db.execute(
            update(RefreshToken).where(RefreshToken.user_id == user_id).values(revoked_at=now)
        )

        # 4. IMMEDIATELY: Set all devices.revoked_at
        await db.execute(update(Device).where(Device.user_id == user_id).values(revoked_at=now))

        # 5. IMMEDIATELY: Set user.deleted_at
        await db.execute(
            update(User)
            .where(User.id == user_id)
            .values(deleted_at=now, deletion_scheduled_at=scheduled_delete_at)
        )

        await db.commit()

        # Background cleanup in P1 async task
        # We would delete media and other rows here or via a scheduled cron job
        import asyncio

        asyncio.create_task(self._cleanup_user_data(db, user_id))

        return DeleteAccountResponse(
            message="Account scheduled for deletion", scheduled_delete_at=scheduled_delete_at
        )

    async def _cleanup_user_data(self, db: AsyncSession, user_id: str):
        # Implementation for background cleanup
        pass
