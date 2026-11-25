from datetime import UTC, datetime

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_device_a_push_device_b_pull_sees_change(
    async_client: AsyncClient, user_a_headers, device_a
):
    now_iso = datetime.now(UTC).isoformat()
    # Device A pushes
    push_res = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_multi_1",
                    "entity_type": "transaction",
                    "entity_id": "tx_multi_dev_1",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 55000,
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
    assert push_res.status_code == 200

    # Device B (same user) pulls from cursor 0
    pull_res = await async_client.get(
        "/v1/sync/pull?cursor=seq_000000000000000000", headers=user_a_headers
    )
    assert pull_res.status_code == 200
    changes = pull_res.json()["changes"]
    synced_tx = next(c for c in changes if c["entity_id"] == "tx_multi_dev_1")
    assert synced_tx["payload"]["amount"] == 55000


@pytest.mark.asyncio
async def test_tombstone_not_resurrected(async_client: AsyncClient, user_a_headers, device_a):
    now_iso = datetime.now(UTC).isoformat()
    # 1. Device A creates entity
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_tomb_res_1",
                    "entity_type": "transaction",
                    "entity_id": "tx_tomb_survive",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 100,
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

    # 2. Device A deletes entity -> tombstone rev 2
    del_res = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_tomb_res_del",
                    "entity_type": "transaction",
                    "entity_id": "tx_tomb_survive",
                    "operation": "delete",
                    "base_revision": 1,
                    "occurred_at": now_iso,
                }
            ],
        },
        headers=user_a_headers,
    )
    assert del_res.status_code == 200

    # 3. Device B was offline and tries to update entity with old base_revision=1
    offline_push = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_tomb_res_stale_update",
                    "entity_type": "transaction",
                    "entity_id": "tx_tomb_survive",
                    "operation": "upsert",
                    "base_revision": 1,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 200,
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
    assert offline_push.status_code == 200
    data = offline_push.json()
    assert len(data["conflicts"]) == 1
    assert data["conflicts"][0]["conflict_type"] == "tombstone_wins"
    assert data["conflicts"][0]["server_revision"] == 2
    # Ensure entity is still tombstoned when pulled
    pull_res = await async_client.get(
        "/v1/sync/pull?cursor=seq_000000000000000000", headers=user_a_headers
    )
    latest_op = [c for c in pull_res.json()["changes"] if c["entity_id"] == "tx_tomb_survive"][-1]
    assert latest_op["operation"] == "delete"


@pytest.mark.asyncio
async def test_conflict_payload_contains_server_state(
    async_client: AsyncClient, user_a_headers, device_a
):
    now_iso = datetime.now(UTC).isoformat()
    # 1. First push rev 1
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_cp_1",
                    "entity_type": "budget",
                    "entity_id": "bgt_cp_test",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {"category_id": "food_drinks", "amount_limit": 5000000},
                }
            ],
        },
        headers=user_a_headers,
    )

    # 2. Conflict push with base_revision=0
    res = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_cp_conflict",
                    "entity_type": "budget",
                    "entity_id": "bgt_cp_test",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {"category_id": "food_drinks", "amount_limit": 3000000},
                }
            ],
        },
        headers=user_a_headers,
    )
    conflict = res.json()["conflicts"][0]
    assert conflict["server_revision"] == 1
    assert conflict["server_payload"]["amount_limit"] == 5000000
    assert conflict["hint"] == "server_wins"
