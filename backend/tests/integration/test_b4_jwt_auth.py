"""B.1–B.3: JWT round-trip (dev login → exchange → refresh) must not crash."""

from datetime import UTC, datetime

import pytest
from httpx import AsyncClient

from app.core.security import (
    create_access_token,
    hash_token,
    verify_access_token,
)

pytestmark = pytest.mark.asyncio


async def test_dev_token_exchange_no_crash(async_client: AsyncClient):
    user_id = "baseline_user"
    dev_res = await async_client.post(
        "/v1/auth/dev-token", json={"sub": user_id, "email": f"{user_id}@example.com"}
    )
    assert dev_res.status_code == 200

    id_token_str = dev_res.json()["id_token"]  # raw JSON string per auth router
    assert id_token_str.startswith("{")

    ex_res = await async_client.post(
        "/v1/auth/exchange",
        json={
            "provider": "dev_mock",
            "id_token": id_token_str,
            "device_name": "Baseline CLI",
            "device_platform": "ios",
        },
    )
    assert ex_res.status_code == 200, ex_res.text
    data = ex_res.json()
    assert data["user_id"]  # exchange mints a fresh user id for dev_mock
    assert data["device_id"]
    assert data["access_token"]
    assert data["refresh_token"]

    # B.1: access token is a signed JWT; lifetime is 15 minutes
    claims = verify_access_token(data["access_token"])
    assert claims["sub"] == data["user_id"]
    assert claims["device_id"] == data["device_id"]
    assert set(claims) >= {"sub", "device_id", "auth_time", "exp"}
    delta = claims["exp"] - datetime.now(UTC).timestamp()
    assert 780 < delta <= 900

    # B.2: opaque refresh token is url-safe; stored value is sha256 hex
    assert len(data["refresh_token"]) >= 40
    assert hash_token(data["refresh_token"]) != data["refresh_token"]
    assert len(hash_token(data["refresh_token"])) == 64


async def test_create_access_token_claims():
    """B.1: verify_access_token round-trips the documented claims."""
    token = create_access_token("u9", "d9", 1234567890)
    claims = verify_access_token(token)
    assert claims["sub"] == "u9"
    assert claims["device_id"] == "d9"
    assert claims["auth_time"] == 1234567890


async def test_refresh_rotates_and_reuse_detects(async_client: AsyncClient):
    user_id = "baseline_refresh_user"
    dev_res = await async_client.post(
        "/v1/auth/dev-token", json={"sub": user_id, "email": f"{user_id}@example.com"}
    )
    assert dev_res.status_code == 200
    id_token_str = dev_res.json()["id_token"]
    ex_res = await async_client.post(
        "/v1/auth/exchange",
        json={
            "provider": "dev_mock",
            "id_token": id_token_str,
            "device_name": "cli",
            "device_platform": "android",
        },
    )
    assert ex_res.status_code == 200, ex_res.text
    refresh_token = ex_res.json()["refresh_token"]
    device_id = ex_res.json()["device_id"]

    r1 = await async_client.post(
        "/v1/auth/refresh", json={"refresh_token": refresh_token, "device_id": device_id}
    )
    assert r1.status_code == 200, r1.text
    new_refresh = r1.json()["refresh_token"]
    assert new_refresh != refresh_token

    # Reusing the OLD refresh token should trigger family revocation
    r2 = await async_client.post(
        "/v1/auth/refresh", json={"refresh_token": refresh_token, "device_id": device_id}
    )
    assert r2.status_code in (401, 403)
