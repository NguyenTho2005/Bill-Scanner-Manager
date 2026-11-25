"""C.1 — Writes from sync/media/privacy must PERSIST to the database.

Uses an in-memory SQLite database and *two separate connections/sessions*
(not the shared session used by conftest.py, which masked this bug).
"""

from datetime import UTC, datetime
from decimal import Decimal
from pathlib import Path
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.db.base import Base
from app.db.models.media import Media
from app.db.models.sync import ChangeLog
from app.db.models.transaction import Transaction
from app.db.models.user import Device, User
from app.modules.media.schemas import CompleteUploadRequest, UploadIntentRequest
from app.modules.media.service import MediaService
from app.modules.privacy.service import PrivacyService
from app.modules.sync.schemas import PushRequest, SyncOperation
from app.modules.sync.service import SyncService


class _FakeStorage:
    """In-memory stub for StorageClient used by media/privacy services."""

    bucket = "test-bucket"

    def generate_object_key(self, user_id: str, media_id: str, suffix: str = "jpeg") -> str:
        return f"objects/{user_id}/{media_id}.{suffix}"

    async def generate_download_url(self, object_key: str, expires: int = 300) -> str:
        return f"http://minio.test/dl/{object_key}"

    async def generate_upload_url(self, object_key: str, content_type: str) -> str:
        return f"http://minio.test/upload/{object_key}?t=123"

    async def get_object_metadata(self, object_key: str) -> dict:
        return {"ContentLength": 42}

    async def read_first_bytes(self, object_key: str) -> bytes:
        return b"\xff\xd8\xff\xe0fakejpgdata"

    def validate_mime_from_magic_bytes(self, first_bytes: bytes, declared: str) -> bool:
        return True

    async def delete_object(self, object_key: str) -> None:
        return None

    def _client(self):
        from contextlib import asynccontextmanager

        @asynccontextmanager
        async def _ctx():
            class _Client:
                async def put_object(self, **kwargs):
                    return None

            yield _Client()

        return _ctx()


def _new_db(path: Path):
    engine = create_async_engine(
        f"sqlite+aiosqlite:///{path}",
        connect_args={"check_same_thread": False},
    )
    factory = async_sessionmaker(engine, class_=AsyncSession)
    return engine, factory


async def _make_user(db, user_id: str = "u1") -> None:
    db.add(User(id=user_id, created_at=datetime.now(UTC)))
    db.add(
        Device(
            id=f"d_{user_id}",
            user_id=user_id,
            name="dev",
            platform="ios",
            created_at=datetime.now(UTC),
            last_seen_at=datetime.now(UTC),
        )
    )
    await db.flush()


def _tx_payload(tx_id: str, amount: float) -> dict[str, Any]:
    return {
        "id": tx_id,
        "type": "expense",
        "amount": Decimal(str(amount)),
        "currency": "VND",
        "category_id": "food",
        "merchant": "Kafe",
        "occurred_at": datetime.now(UTC).isoformat(),
        "status": "confirmed",
        "source": "sync_test",
    }


async def test_sync_push_persists_to_db(tmp_path):
    """E1: push() commits so ack + change_log + idempotency rows are durable."""
    engine, factory = _new_db(tmp_path / "sync.db")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with factory() as db:
        await _make_user(db)
        op = SyncOperation(
            operation_id="op-sync-1",
            entity_type="transaction",
            entity_id="tx1",
            operation="upsert",
            base_revision=0,
            occurred_at=datetime.now(UTC),
            payload=_tx_payload("tx1", 10.0),
        )
        resp = await SyncService().push(
            db, "u1", "d_u1", PushRequest(device_id="d_u1", operations=[op])
        )
        assert resp.acknowledged
        assert not resp.conflicts

    # Second session (independent connection) must SEE the data
    async with factory() as db:
        txs = (await db.execute(select(Transaction).where(Transaction.id == "tx1"))).scalars().all()
        assert txs, "transaction not persisted after push()"
        cls = (
            (await db.execute(select(ChangeLog).where(ChangeLog.entity_id == "tx1")))
            .scalars()
            .all()
        )
        assert cls, "change_log not persisted after push()"
    await engine.dispose()


async def test_media_complete_upload_persists_and_is_upsert(tmp_path):
    """E5: complete_upload() commits, state becomes ready, change_log is 'upsert'."""
    engine, factory = _new_db(tmp_path / "media.db")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with factory() as db:
        db.add(User(id="u1", created_at=datetime.now(UTC)))
        await db.flush()
        svc = MediaService(storage=_FakeStorage())
        intent = await svc.create_upload_intent(
            db,
            "u1",
            UploadIntentRequest(
                media_type="product",
                content_type="image/jpeg",
                size_bytes=42,
                content_hash="hash42",
            ),
        )
        media_id = intent.media_id
        resp = await svc.complete_upload(
            db,
            "u1",
            intent.media_id,
            CompleteUploadRequest(content_hash="hash42", size_bytes=42),
            device_id="d_u1",
        )
        assert resp.state == "ready"

    async with factory() as db:
        media = (await db.execute(select(Media).where(Media.id == media_id))).scalar_one_or_none()
        assert media is not None, "media row not persisted after complete_upload()"
        assert media.state == "ready"
        ops = (
            (await db.execute(select(ChangeLog).where(ChangeLog.entity_id == media_id)))
            .scalars()
            .all()
        )
        assert ops, "no change_log rows persisted"
        assert ops[-1].operation == "upsert", f"got {[o.operation for o in ops]}"
    await engine.dispose()


async def test_media_delete_and_privacy_writes_persist(tmp_path):
    """E1 (media.delete_media) + E1 (privacy.request_export/request_account_deletion)."""
    engine, factory = _new_db(tmp_path / "privacy.db")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with factory() as db:
        await _make_user(db)
        svc = MediaService(storage=_FakeStorage())
        intent = await svc.create_upload_intent(
            db,
            "u1",
            UploadIntentRequest(
                media_type="product", content_type="image/png", size_bytes=42, content_hash="h42"
            ),
        )
        await svc.complete_upload(
            db,
            "u1",
            intent.media_id,
            CompleteUploadRequest(content_hash="h42", size_bytes=42),
            device_id="d_u1",
        )
        await svc.delete_media(db, "u1", intent.media_id, "d_u1")
    async with factory() as db:
        media = (
            await db.execute(select(Media).where(Media.id == intent.media_id))
        ).scalar_one_or_none()
        assert media is not None
        assert media.deleted_at is not None
    await engine.dispose()

    # privacy export + deletion (persists updates + commits)
    engine2, factory2 = _new_db(tmp_path / "privacy2.db")
    async with engine2.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with factory2() as db:
        await _make_user(db)
        await PrivacyService(_FakeStorage()).request_export(db, "u1")
        resp = await PrivacyService(_FakeStorage()).request_account_deletion(db, "u1")
        assert resp.scheduled_delete_at > datetime.now(UTC)
    async with factory2() as db:
        user = (await db.execute(select(User).where(User.id == "u1"))).scalar_one_or_none()
        assert user is not None
        assert user.deleted_at is not None
        devs = (await db.execute(select(Device).where(Device.user_id == "u1"))).scalars().all()
        assert devs
        assert all(d.revoked_at for d in devs)
    await engine2.dispose()
