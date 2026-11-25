from datetime import UTC, datetime

import pytest
from httpx import AsyncClient

pytestmark = pytest.mark.asyncio


async def test_transaction_idor(
    async_client: AsyncClient, user_a_headers, user_b_headers, device_a, device_b
):
    now_iso = datetime.now(UTC).isoformat()
    # User A creates a transaction
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_idor_tx_a",
                    "entity_type": "transaction",
                    "entity_id": "tx_idor_target",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 100000,
                        "currency": "VND",
                        "category_id": "other",
                        "occurred_at": now_iso,
                        "status": "confirmed",
                        "source": "manual",
                    },
                }
            ],
        },
        headers=user_a_headers,
    )

    # User B tries to update User A's transaction using their own device
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_b,
            "operations": [
                {
                    "operation_id": "op_idor_tx_attack",
                    "entity_type": "transaction",
                    "entity_id": "tx_idor_target",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 1,
                        "currency": "VND",
                        "category_id": "other",
                        "occurred_at": now_iso,
                        "status": "confirmed",
                        "source": "manual",
                    },
                }
            ],
        },
        headers=user_b_headers,
    )

    # Even if User B inserts with same entity_id, User A's data must remain unchanged
    pull_a = await async_client.get(
        "/v1/sync/pull?cursor=seq_000000000000000000", headers=user_a_headers
    )
    tx_a = next(c for c in pull_a.json()["changes"] if c["entity_id"] == "tx_idor_target")
    assert tx_a["payload"]["amount"] == 100000  # Intact!


async def test_media_idor(async_client: AsyncClient, user_a_headers, user_b_headers):
    # User A creates upload intent
    intent = await async_client.post(
        "/v1/media/upload-intents",
        json={
            "media_type": "receipt",
            "content_type": "image/jpeg",
            "size_bytes": 1024,
            "content_hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        },
        headers=user_a_headers,
    )
    assert intent.status_code == 200
    media_id = intent.json()["media_id"]

    # User B tries to download User A's media
    resp = await async_client.get(f"/v1/media/{media_id}/download-intent", headers=user_b_headers)
    assert resp.status_code == 404

    # User B tries to delete User A's media
    del_resp = await async_client.delete(f"/v1/media/{media_id}", headers=user_b_headers)
    assert del_resp.status_code in [404, 403]


async def test_device_idor(async_client: AsyncClient, user_a_headers, user_b_headers, device_a):
    # User B tries to revoke User A's device
    resp = await async_client.delete(f"/v1/devices/{device_a}", headers=user_b_headers)
    assert resp.status_code in [403, 404]

    # Check User A's device is still active
    list_resp = await async_client.get("/v1/devices", headers=user_a_headers)
    assert list_resp.status_code == 200
    device_ids = [d["id"] for d in list_resp.json()]
    assert device_a in device_ids
