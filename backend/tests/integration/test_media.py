from unittest.mock import AsyncMock

import pytest
from httpx import AsyncClient

from app.main import app
from app.modules.media.router import get_media_service
from app.modules.media.service import MediaService

pytestmark = pytest.mark.asyncio


@pytest.fixture
def mock_storage():
    storage = AsyncMock()
    storage.bucket = "test-bucket"
    storage.generate_object_key = lambda u, m, s: f"{u}/{m}/random_{s}"
    storage.generate_upload_url = AsyncMock(return_value="http://s3.local/upload-presigned")
    storage.generate_download_url = AsyncMock(return_value="http://s3.local/download-presigned")
    storage.get_object_metadata = AsyncMock(
        return_value={"ContentLength": 1024, "ContentType": "image/jpeg"}
    )
    storage.read_first_bytes = AsyncMock(return_value=b"\xff\xd8\xff\xe0")
    storage.validate_mime_from_magic_bytes = lambda b, m: True
    storage.delete_object = AsyncMock()
    return storage


@pytest.fixture(autouse=True)
def override_media_service(mock_storage):
    service = MediaService(mock_storage)
    app.dependency_overrides[get_media_service] = lambda: service
    yield service
    app.dependency_overrides.pop(get_media_service, None)


async def test_upload_intent_returns_presigned_url(async_client: AsyncClient, user_a_headers):
    payload = {
        "media_type": "receipt",
        "content_type": "image/jpeg",
        "size_bytes": 1024,
        "content_hash": "a" * 64,
    }
    response = await async_client.post(
        "/v1/media/upload-intents", json=payload, headers=user_a_headers
    )
    assert response.status_code == 200
    data = response.json()
    assert data["upload_url"] == "http://s3.local/upload-presigned"
    assert "media_id" in data


async def test_complete_upload_validates_hash_mismatch(async_client: AsyncClient, user_a_headers):
    # 1. Setup intent
    intent = await async_client.post(
        "/v1/media/upload-intents",
        json={
            "media_type": "receipt",
            "content_type": "image/jpeg",
            "size_bytes": 1024,
            "content_hash": "correct_hash_123",
        },
        headers=user_a_headers,
    )
    media_id = intent.json()["media_id"]

    # 2. Complete with wrong hash
    response = await async_client.post(
        f"/v1/media/{media_id}/complete",
        json={"content_hash": "wrong_hash_456", "size_bytes": 1024},
        headers=user_a_headers,
    )
    assert response.status_code == 422
    assert "Hash mismatch" in response.json()["error"]["message"]


async def test_complete_upload_success_and_download(async_client: AsyncClient, user_a_headers):
    # 1. Setup intent
    intent = await async_client.post(
        "/v1/media/upload-intents",
        json={
            "media_type": "product",
            "content_type": "image/jpeg",
            "size_bytes": 1024,
            "content_hash": "valid_hash",
        },
        headers=user_a_headers,
    )
    media_id = intent.json()["media_id"]

    # 2. Complete upload
    comp = await async_client.post(
        f"/v1/media/{media_id}/complete",
        json={"content_hash": "valid_hash", "size_bytes": 1024},
        headers=user_a_headers,
    )
    assert comp.status_code == 200
    assert comp.json()["state"] == "ready"

    # 3. Get download intent
    dl = await async_client.get(f"/v1/media/{media_id}/download-intent", headers=user_a_headers)
    assert dl.status_code == 200
    assert dl.json()["download_url"] == "http://s3.local/download-presigned"


async def test_delete_media_soft_delete(async_client: AsyncClient, user_a_headers):
    intent = await async_client.post(
        "/v1/media/upload-intents",
        json={
            "media_type": "receipt",
            "content_type": "image/jpeg",
            "size_bytes": 1024,
            "content_hash": "del_hash",
        },
        headers=user_a_headers,
    )
    media_id = intent.json()["media_id"]

    # Delete media
    del_res = await async_client.delete(f"/v1/media/{media_id}", headers=user_a_headers)
    assert del_res.status_code == 204

    # Subsequent download intent should return 404
    dl = await async_client.get(f"/v1/media/{media_id}/download-intent", headers=user_a_headers)
    assert dl.status_code == 404


async def test_quota_limit_comes_from_settings(override_media_service):
    """§4.6 #9 — the quota is configuration-driven, never hardcoded."""
    from app.config import get_settings

    assert override_media_service.MAX_QUOTA_BYTES == get_settings().MEDIA_QUOTA_PER_USER_BYTES


async def test_intent_expiry_matches_configured_ttl(async_client: AsyncClient, user_a_headers):
    """§4.6 #9 — expires_at is a real future expiry, not `now()`."""
    from datetime import UTC, datetime

    from app.config import get_settings

    settings = get_settings()

    before = datetime.now(UTC)
    intent = await async_client.post(
        "/v1/media/upload-intents",
        json={
            "media_type": "receipt",
            "content_type": "image/jpeg",
            "size_bytes": 1024,
            "content_hash": "e" * 64,
        },
        headers=user_a_headers,
    )
    assert intent.status_code == 200
    upload_expires = datetime.fromisoformat(intent.json()["expires_at"])
    upload_delta = (upload_expires - before).total_seconds()
    assert settings.S3_UPLOAD_URL_TTL - 15 <= upload_delta <= settings.S3_UPLOAD_URL_TTL + 15

    # Complete the upload so a download intent is possible.
    media_id = intent.json()["media_id"]
    comp = await async_client.post(
        f"/v1/media/{media_id}/complete",
        json={"content_hash": "e" * 64, "size_bytes": 1024},
        headers=user_a_headers,
    )
    assert comp.status_code == 200

    dl_before = datetime.now(UTC)
    dl = await async_client.get(f"/v1/media/{media_id}/download-intent", headers=user_a_headers)
    assert dl.status_code == 200
    dl_expires = datetime.fromisoformat(dl.json()["expires_at"])
    dl_delta = (dl_expires - dl_before).total_seconds()
    assert settings.S3_DOWNLOAD_URL_TTL - 15 <= dl_delta <= settings.S3_DOWNLOAD_URL_TTL + 15
