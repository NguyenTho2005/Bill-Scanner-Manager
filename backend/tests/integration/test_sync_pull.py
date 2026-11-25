from datetime import UTC, datetime

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_pull_without_cursor_raises_422(async_client: AsyncClient, user_a_headers):
    # Missing cursor query param
    res = await async_client.get("/v1/sync/pull", headers=user_a_headers)
    assert res.status_code == 422


@pytest.mark.asyncio
async def test_pull_with_valid_cursor_returns_changes(
    async_client: AsyncClient, user_a_headers, device_a
):
    now_iso = datetime.now(UTC).isoformat()
    # 1. Push a transaction
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_pull_1",
                    "entity_type": "transaction",
                    "entity_id": "tx_pull_1",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 30000,
                        "currency": "VND",
                        "category_id": "food_drinks",
                        "occurred_at": now_iso,
                        "status": "confirmed",
                        "source": "manual",
                    },
                }
            ],
        },
        headers=user_a_headers,
    )

    # 2. Pull from sequence 0
    res = await async_client.get(
        "/v1/sync/pull?cursor=seq_000000000000000000", headers=user_a_headers
    )
    assert res.status_code == 200
    data = res.json()
    assert len(data["changes"]) >= 1
    item = next(c for c in data["changes"] if c["entity_id"] == "tx_pull_1")
    assert item["entity_type"] == "transaction"
    assert item["operation"] == "upsert"
    assert item["payload"]["amount"] == 30000
    assert data["next_cursor"].startswith("seq_")


@pytest.mark.asyncio
async def test_pull_tombstone_included_in_changes(
    async_client: AsyncClient, user_a_headers, device_a
):
    now_iso = datetime.now(UTC).isoformat()
    # Create then delete
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_pull_tomb_init",
                    "entity_type": "transaction",
                    "entity_id": "tx_pull_tomb",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 1000,
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

    del_res = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_pull_tomb_del",
                    "entity_type": "transaction",
                    "entity_id": "tx_pull_tomb",
                    "operation": "delete",
                    "base_revision": 1,
                    "occurred_at": now_iso,
                }
            ],
        },
        headers=user_a_headers,
    )
    del_seq = del_res.json()["acknowledged"][0]["sequence"]

    # Pull from just before the delete sequence
    res = await async_client.get(
        f"/v1/sync/pull?cursor=seq_{del_seq - 1:018d}", headers=user_a_headers
    )
    assert res.status_code == 200
    data = res.json()
    tomb_change = next(c for c in data["changes"] if c["entity_id"] == "tx_pull_tomb")
    assert tomb_change["operation"] == "delete"
    assert tomb_change["payload"] is None


@pytest.mark.asyncio
async def test_pull_only_own_data(
    async_client: AsyncClient, user_a_headers, user_b_headers, device_a
):
    now_iso = datetime.now(UTC).isoformat()
    # User A pushes a private transaction
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_private_a",
                    "entity_type": "transaction",
                    "entity_id": "tx_secret_user_a",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 999999,
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

    # User B pulls from cursor 0
    res_b = await async_client.get(
        "/v1/sync/pull?cursor=seq_000000000000000000", headers=user_b_headers
    )
    assert res_b.status_code == 200
    user_b_changes = res_b.json()["changes"]
    # User B MUST NOT see User A's transaction
    assert not any(c["entity_id"] == "tx_secret_user_a" for c in user_b_changes)
