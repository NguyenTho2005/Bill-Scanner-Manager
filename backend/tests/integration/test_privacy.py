from unittest.mock import AsyncMock, MagicMock

import pytest
from httpx import AsyncClient

from app.main import app
from app.modules.privacy.router import get_privacy_service
from app.modules.privacy.service import PrivacyService

pytestmark = pytest.mark.asyncio


@pytest.fixture
def mock_storage():
    storage = MagicMock()
    storage.bucket = "test-bucket"
    storage.generate_download_url = AsyncMock(return_value="http://s3.local/export-download")

    mock_client = AsyncMock()
    mock_client.put_object = AsyncMock()

    # Context manager for _client()
    class AsyncContextManager:
        async def __aenter__(self):
            return mock_client

        async def __aexit__(self, exc_type, exc_val, exc_tb):
            pass

    storage._client = MagicMock(return_value=AsyncContextManager())
    return storage


@pytest.fixture(autouse=True)
def override_privacy_service(mock_storage):
    service = PrivacyService(mock_storage)
    app.dependency_overrides[get_privacy_service] = lambda: service
    yield service
    app.dependency_overrides.pop(get_privacy_service, None)


async def test_get_me(async_client: AsyncClient, user_a_headers):
    response = await async_client.get("/v1/me", headers=user_a_headers)
    assert response.status_code == 200
    data = response.json()
    assert "id" in data
    assert data["deleted_at"] is None


async def test_export_returns_download_url(async_client: AsyncClient, user_a_headers):
    response = await async_client.get("/v1/me/export", headers=user_a_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ready"
    assert data["download_url"] == "http://s3.local/export-download"
    assert "expires_at" in data


async def test_delete_account_schedules_deletion(async_client: AsyncClient, user_a_headers):
    response = await async_client.delete("/v1/me", headers=user_a_headers)
    assert response.status_code == 200
    data = response.json()
    assert "scheduled_delete_at" in data


async def test_ocr_endpoints_return_501(async_client: AsyncClient, user_a_headers):
    res_post = await async_client.post("/v1/ocr/jobs", headers=user_a_headers)
    assert res_post.status_code == 501
    assert res_post.json()["error"]["code"] == "not_implemented"

    res_get = await async_client.get("/v1/ocr/jobs/job_123", headers=user_a_headers)
    assert res_get.status_code == 501


async def test_export_persists_export_job_row(test_db, override_privacy_service):
    """§4.6 #12 — an export_jobs row is created and completed by the service."""
    from sqlalchemy import select

    from app.db.models.account import ExportJob

    service = override_privacy_service
    result = await service.request_export(test_db, "user_privacy_test")
    assert result.status == "ready"

    row = (
        await test_db.execute(select(ExportJob).where(ExportJob.id == result.job_id))
    ).scalar_one()
    assert row.user_id == "user_privacy_test"
    assert row.status == "ready"
    assert row.download_key == f"exports/user_privacy_test/{result.job_id}.json"
    assert row.ready_at is not None
    assert row.expires_at is not None


async def test_export_status_can_be_polled(async_client: AsyncClient, user_a_headers):
    """§4.6 #12 — GET /v1/me/export/{job_id} reports job status."""
    created = await async_client.get("/v1/me/export", headers=user_a_headers)
    assert created.status_code == 200
    job_id = created.json()["job_id"]

    polled = await async_client.get(f"/v1/me/export/{job_id}", headers=user_a_headers)
    assert polled.status_code == 200
    data = polled.json()
    assert data["job_id"] == job_id
    assert data["status"] == "ready"
    assert data["download_url"] == "http://s3.local/export-download"
    assert data["expires_at"] is not None


async def test_export_status_is_user_scoped(
    async_client: AsyncClient, user_a_headers, user_b_headers
):
    """§4.6 #12 — another user cannot poll someone else's export job."""
    created = await async_client.get("/v1/me/export", headers=user_a_headers)
    job_id = created.json()["job_id"]

    other = await async_client.get(f"/v1/me/export/{job_id}", headers=user_b_headers)
    assert other.status_code == 404
