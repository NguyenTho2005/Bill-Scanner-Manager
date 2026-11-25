from datetime import UTC, datetime

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_push_single_op_acknowledged(async_client: AsyncClient, user_a_headers, device_a):
    now_iso = datetime.now(UTC).isoformat()
    payload = {
        "device_id": device_a,
        "operations": [
            {
                "operation_id": "op_tx_001",
                "entity_type": "transaction",
                "entity_id": "tx_001",
                "operation": "upsert",
                "base_revision": 0,
                "occurred_at": now_iso,
                "payload": {
                    "type": "expense",
                    "amount": 45000,
                    "currency": "VND",
                    "category_id": "food_drinks",
                    "merchant": "Highlands Coffee",
                    "occurred_at": now_iso,
                    "status": "confirmed",
                    "source": "manual",
                },
            }
        ],
    }
    response = await async_client.post("/v1/sync/push", json=payload, headers=user_a_headers)
    assert response.status_code == 200, response.text
    data = response.json()
    assert len(data["acknowledged"]) == 1
    assert data["acknowledged"][0]["operation_id"] == "op_tx_001"
    assert data["acknowledged"][0]["entity_id"] == "tx_001"
    assert data["acknowledged"][0]["revision"] == 1
    assert len(data["conflicts"]) == 0
    assert data["server_cursor"].startswith("seq_")


@pytest.mark.asyncio
async def test_push_idempotent_retry(async_client: AsyncClient, user_a_headers, device_a):
    now_iso = datetime.now(UTC).isoformat()
    payload = {
        "device_id": device_a,
        "operations": [
            {
                "operation_id": "op_tx_idemp",
                "entity_type": "transaction",
                "entity_id": "tx_idemp",
                "operation": "upsert",
                "base_revision": 0,
                "occurred_at": now_iso,
                "payload": {
                    "type": "expense",
                    "amount": 20000,
                    "currency": "VND",
                    "category_id": "food_drinks",
                    "occurred_at": now_iso,
                    "status": "confirmed",
                    "source": "manual",
                },
            }
        ],
    }
    # First push
    res1 = await async_client.post("/v1/sync/push", json=payload, headers=user_a_headers)
    assert res1.status_code == 200
    ack1 = res1.json()["acknowledged"][0]

    # Retry same operation_id
    res2 = await async_client.post("/v1/sync/push", json=payload, headers=user_a_headers)
    assert res2.status_code == 200
    ack2 = res2.json()["acknowledged"][0]

    # Must return identical acknowledgment, no double revision bump
    assert ack1["operation_id"] == ack2["operation_id"]
    assert ack1["revision"] == ack2["revision"]
    assert ack1["sequence"] == ack2["sequence"]


@pytest.mark.asyncio
async def test_push_stale_revision_conflict(async_client: AsyncClient, user_a_headers, device_a):
    now_iso = datetime.now(UTC).isoformat()
    # 1. Create transaction to rev 1
    op1 = {
        "device_id": device_a,
        "operations": [
            {
                "operation_id": "op_rev_1",
                "entity_type": "transaction",
                "entity_id": "tx_conflict_test",
                "operation": "upsert",
                "base_revision": 0,
                "occurred_at": now_iso,
                "payload": {
                    "type": "expense",
                    "amount": 10000,
                    "currency": "VND",
                    "category_id": "food_drinks",
                    "occurred_at": now_iso,
                    "status": "confirmed",
                    "source": "manual",
                },
            }
        ],
    }
    res1 = await async_client.post("/v1/sync/push", json=op1, headers=user_a_headers)
    assert res1.status_code == 200

    # 2. Push with stale base_revision=0 when server is at rev 1
    op_stale = {
        "device_id": device_a,
        "operations": [
            {
                "operation_id": "op_rev_stale",
                "entity_type": "transaction",
                "entity_id": "tx_conflict_test",
                "operation": "upsert",
                "base_revision": 0,  # Stale! Server is at rev 1
                "occurred_at": now_iso,
                "payload": {
                    "type": "expense",
                    "amount": 15000,
                    "currency": "VND",
                    "category_id": "food_drinks",
                    "occurred_at": now_iso,
                    "status": "confirmed",
                    "source": "manual",
                },
            }
        ],
    }
    res_stale = await async_client.post("/v1/sync/push", json=op_stale, headers=user_a_headers)
    assert res_stale.status_code == 200
    data = res_stale.json()
    assert len(data["conflicts"]) == 1
    assert data["conflicts"][0]["conflict_type"] == "revision_mismatch"
    assert data["conflicts"][0]["server_revision"] == 1
    assert data["conflicts"][0]["hint"] == "server_wins"


@pytest.mark.asyncio
async def test_push_upsert_after_tombstone(async_client: AsyncClient, user_a_headers, device_a):
    now_iso = datetime.now(UTC).isoformat()
    # 1. Create then delete
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_tomb_init",
                    "entity_type": "transaction",
                    "entity_id": "tx_tomb_test",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 5000,
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

    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_tomb_del",
                    "entity_type": "transaction",
                    "entity_id": "tx_tomb_test",
                    "operation": "delete",
                    "base_revision": 1,
                    "occurred_at": now_iso,
                }
            ],
        },
        headers=user_a_headers,
    )

    # 2. Push upsert with stale base_revision=1 after tombstoned at rev 2
    res = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_tomb_resurrect",
                    "entity_type": "transaction",
                    "entity_id": "tx_tomb_test",
                    "operation": "upsert",
                    "base_revision": 1,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 6000,
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
    assert res.status_code == 200
    data = res.json()
    assert len(data["conflicts"]) == 1
    assert data["conflicts"][0]["conflict_type"] == "tombstone_wins"


@pytest.mark.asyncio
async def test_push_delete_creates_tombstone(async_client: AsyncClient, user_a_headers, device_a):
    now_iso = datetime.now(UTC).isoformat()
    # Create
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_del_1",
                    "entity_type": "category",
                    "entity_id": "cat_del_test",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {"name": "Tạm", "icon": "trash", "color_value": 0},
                }
            ],
        },
        headers=user_a_headers,
    )

    # Delete
    del_res = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_del_2",
                    "entity_type": "category",
                    "entity_id": "cat_del_test",
                    "operation": "delete",
                    "base_revision": 1,
                    "occurred_at": now_iso,
                }
            ],
        },
        headers=user_a_headers,
    )
    assert del_res.status_code == 200
    assert len(del_res.json()["acknowledged"]) == 1
    assert del_res.json()["acknowledged"][0]["revision"] == 2


@pytest.mark.asyncio
async def test_push_max_100_ops(async_client: AsyncClient, user_a_headers, device_a):
    now_iso = datetime.now(UTC).isoformat()
    ops = [
        {
            "operation_id": f"op_{i}",
            "entity_type": "transaction",
            "entity_id": f"tx_{i}",
            "operation": "upsert",
            "base_revision": 0,
            "occurred_at": now_iso,
            "payload": {"amount": i},
        }
        for i in range(101)
    ]
    res = await async_client.post(
        "/v1/sync/push", json={"device_id": device_a, "operations": ops}, headers=user_a_headers
    )
    assert res.status_code == 422  # Max 100 validation error


@pytest.mark.asyncio
async def test_push_wrong_device_id(async_client: AsyncClient, user_a_headers, device_b):
    now_iso = datetime.now(UTC).isoformat()
    res = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_b,  # Belongs to user B, not user A
            "operations": [
                {
                    "operation_id": "op_wrong_dev",
                    "entity_type": "transaction",
                    "entity_id": "tx_wrong",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {"amount": 100},
                }
            ],
        },
        headers=user_a_headers,
    )
    assert res.status_code in [403, 401]
