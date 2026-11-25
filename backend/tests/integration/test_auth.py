import pytest
from httpx import AsyncClient

pytestmark = pytest.mark.asyncio


async def test_dev_token_and_exchange(async_client: AsyncClient):
    # 1. Get dev token
    token_req = {"sub": "test_alice_sub", "email": "alice@example.com"}
    dev_res = await async_client.post("/v1/auth/dev-token", json=token_req)
    assert dev_res.status_code == 200
    id_token = dev_res.json()["id_token"]

    # 2. Exchange for app session
    exchange_req = {
        "provider": "dev_mock",
        "id_token": id_token,
        "device_name": "Alice iPhone",
        "device_platform": "ios",
    }
    ex_res = await async_client.post("/v1/auth/exchange", json=exchange_req)
    assert ex_res.status_code == 200
    data = ex_res.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert "device_id" in data
    assert "user_id" in data

    access_token = data["access_token"]
    refresh_token = data["refresh_token"]
    device_id = data["device_id"]

    # 3. Access authenticated endpoint
    headers = {"Authorization": f"Bearer {access_token}"}
    me_res = await async_client.get("/v1/me", headers=headers)
    assert me_res.status_code == 200
    assert me_res.json()["id"] == data["user_id"]

    # 4. Refresh token rotation
    ref_res = await async_client.post(
        "/v1/auth/refresh", json={"refresh_token": refresh_token, "device_id": device_id}
    )
    assert ref_res.status_code == 200
    new_data = ref_res.json()
    assert "access_token" in new_data
    assert "refresh_token" in new_data
    assert new_data["refresh_token"] != refresh_token  # rotation happens

    # 5. Reuse detection: using the OLD refresh token must fail
    reuse_res = await async_client.post(
        "/v1/auth/refresh", json={"refresh_token": refresh_token, "device_id": device_id}
    )
    assert reuse_res.status_code in [401, 400]

    # 6. Device revocation
    dev_revoke = await async_client.delete(
        f"/v1/devices/{device_id}", headers={"Authorization": f"Bearer {new_data['access_token']}"}
    )
    assert dev_revoke.status_code == 200
