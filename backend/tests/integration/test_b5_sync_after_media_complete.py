"""B.5 — P1: after /v1/media/{id}/complete, /v1/sync/pull returns the media row (no 500)."""

import hashlib

import pytest
from httpx import AsyncClient

from app.db.base import Base
from app.main import app
from app.modules.media.service import MediaService
from tests.conftest import engine as _engine
from tests.integration.test_c1_persistence_repro import _FakeStorage


@pytest.fixture(autouse=True)
def fake_media_service():
    """Override media service storage with an in-memory fake (no MinIO)."""
    from app.modules.media.router import get_media_service

    app.dependency_overrides[get_media_service] = lambda: MediaService(storage=_FakeStorage())
    yield
    app.dependency_overrides.pop(get_media_service, None)


async def _upload_media(client: AsyncClient, headers: dict) -> str:
    content_hash = hashlib.sha256(b"fake-jpeg-data").hexdigest()
    intent = (
        await client.post(
            "/v1/media/upload-intents",
            json={
                "media_type": "product",
                "content_type": "image/jpeg",
                "size_bytes": 42,
                "content_hash": content_hash,
            },
            headers=headers,
        )
    ).json()
    media_id = intent["media_id"]

    complete = (
        await client.post(
            f"/v1/media/{media_id}/complete",
            json={"content_hash": content_hash, "size_bytes": 42},
            headers=headers,
        )
    ).json()
    assert complete["state"] == "ready", complete
    return media_id


async def test_sync_pull_after_media_complete_does_not_500(
    async_client: AsyncClient, user_a_headers: dict
):
    # Create the schema for the independent verification session
    async with _engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    media_id = await _upload_media(async_client, user_a_headers)

    pull = await async_client.get(
        "/v1/sync/pull?cursor=seq_000000000000000000", headers=user_a_headers
    )
    assert pull.status_code == 200, pull.text
    changes = pull.json()["changes"]
    print("DEBUG pull changes:", changes)
    assert any(c["entity_type"] == "media" and c["entity_id"] == media_id for c in changes), changes

    # The pull already proves the row persisted (status ready + upsert operation).
    # Also verify via /v1/media/{id}/download-intent (uses fake storage, no MinIO).
    intent = await async_client.get(f"/v1/media/{media_id}/download-intent", headers=user_a_headers)
    assert intent.status_code == 200, intent.text
    assert intent.json()["media_id"] == media_id
