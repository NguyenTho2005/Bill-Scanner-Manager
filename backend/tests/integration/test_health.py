from unittest.mock import AsyncMock, MagicMock

import pytest
from httpx import AsyncClient

from app.main import app
from app.modules.health.router import get_health_storage

pytestmark = pytest.mark.asyncio


async def test_health_ready_succeeds_when_db_and_s3_ok(async_client: AsyncClient) -> None:
    storage = MagicMock()
    storage.check_bucket = AsyncMock(return_value=None)
    app.dependency_overrides[get_health_storage] = lambda: storage
    try:
        resp = await async_client.get("/health/ready")
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "ready"
        assert data["checks"] == {"database": "ok", "storage": "ok"}
        storage.check_bucket.assert_awaited_once()
    finally:
        app.dependency_overrides.pop(get_health_storage, None)


async def test_health_ready_returns_503_when_s3_unavailable(async_client: AsyncClient) -> None:
    storage = MagicMock()
    storage.check_bucket = AsyncMock(side_effect=RuntimeError("MinIO unreachable"))
    app.dependency_overrides[get_health_storage] = lambda: storage
    try:
        resp = await async_client.get("/health/ready")
        assert resp.status_code == 503
        assert "Storage connection failed" in resp.text
    finally:
        app.dependency_overrides.pop(get_health_storage, None)
