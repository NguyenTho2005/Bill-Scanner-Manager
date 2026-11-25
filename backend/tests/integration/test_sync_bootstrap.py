from datetime import UTC, datetime

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_bootstrap_returns_all_entities_for_new_device(
    async_client: AsyncClient, user_a_headers, device_a
):
    now_iso = datetime.now(UTC).isoformat()
    # 1. User A creates a transaction and a budget
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_boot_tx",
                    "entity_type": "transaction",
                    "entity_id": "tx_boot_1",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 75000,
                        "currency": "VND",
                        "category_id": "food_drinks",
                        "occurred_at": now_iso,
                        "status": "confirmed",
                        "source": "manual",
                    },
                },
                {
                    "operation_id": "op_boot_bgt",
                    "entity_type": "budget",
                    "entity_id": "bgt_boot_1",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "category_id": "food_drinks",
                        "amount_limit": 2000000,
                        "period_start": now_iso,
                        "period_end": now_iso,
                    },
                },
            ],
        },
        headers=user_a_headers,
    )

    # 2. Call bootstrap
    res = await async_client.get("/v1/sync/bootstrap", headers=user_a_headers)
    assert res.status_code == 200
    data = res.json()
    assert "entities" in data
    assert "bootstrap_cursor" in data
    entity_ids = [e["entity_id"] for e in data["entities"]]
    assert "tx_boot_1" in entity_ids
    assert "bgt_boot_1" in entity_ids


@pytest.mark.asyncio
async def test_bootstrap_excludes_tombstones(async_client: AsyncClient, user_a_headers, device_a):
    now_iso = datetime.now(UTC).isoformat()
    # Create then delete an entity
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_boot_del_init",
                    "entity_type": "category",
                    "entity_id": "cat_boot_tomb",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {"name": "Deleted Cat", "icon": "x", "color_value": 0},
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
                    "operation_id": "op_boot_del_tomb",
                    "entity_type": "category",
                    "entity_id": "cat_boot_tomb",
                    "operation": "delete",
                    "base_revision": 1,
                    "occurred_at": now_iso,
                }
            ],
        },
        headers=user_a_headers,
    )

    res = await async_client.get("/v1/sync/bootstrap", headers=user_a_headers)
    assert res.status_code == 200
    entities = res.json()["entities"]
    entity_ids = [e["entity_id"] for e in entities]
    assert "cat_boot_tomb" not in entity_ids


@pytest.mark.asyncio
async def test_bootstrap_isolation(
    async_client: AsyncClient, user_a_headers, user_b_headers, device_a
):
    now_iso = datetime.now(UTC).isoformat()
    # User A creates transaction
    await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_iso_a",
                    "entity_type": "transaction",
                    "entity_id": "tx_only_user_a",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 12345,
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

    # User B bootstraps
    res_b = await async_client.get("/v1/sync/bootstrap", headers=user_b_headers)
    assert res_b.status_code == 200
    user_b_ids = [e["entity_id"] for e in res_b.json()["entities"]]
    assert "tx_only_user_a" not in user_b_ids


@pytest.mark.asyncio
async def test_bootstrap_paginates_in_sql(async_client: AsyncClient, user_a_headers, device_a):
    """§4.6 #13 — bootstrap returns only one page of rows per request."""
    now_iso = datetime.now(UTC).isoformat()
    ops = [
        {
            "operation_id": f"op_page_{i}",
            "entity_type": "transaction",
            "entity_id": f"tx_page_{i}",
            "operation": "upsert",
            "base_revision": 0,
            "occurred_at": now_iso,
            "payload": {
                "type": "expense",
                "amount": 1000 + i,
                "currency": "VND",
                "category_id": "other",
                "occurred_at": now_iso,
                "status": "confirmed",
                "source": "manual",
            },
        }
        for i in range(5)
    ]
    push = await async_client.post(
        "/v1/sync/push",
        json={"device_id": device_a, "operations": ops},
        headers=user_a_headers,
    )
    assert push.status_code == 200

    collected: list[str] = []
    seen: list[str] = []
    total_pages = None
    page = 0
    while total_pages is None or page < total_pages:
        res = await async_client.get(
            "/v1/sync/bootstrap",
            params={"page": page, "page_size": 2},
            headers=user_a_headers,
        )
        assert res.status_code == 200
        data = res.json()
        assert data["page"] == page
        assert len(data["entities"]) <= 2
        total_pages = data["total_pages"]
        ids = [e["entity_id"] for e in data["entities"]]
        # No row is returned twice across pages.
        assert not set(ids) & set(seen)
        seen.extend(ids)
        collected.extend(i for i in ids if i.startswith("tx_page_"))
        page += 1

    assert sorted(collected) == [f"tx_page_{i}" for i in range(5)]

    # Page past the end is empty rather than an error.
    res_empty = await async_client.get(
        "/v1/sync/bootstrap",
        params={"page": 9, "page_size": 2},
        headers=user_a_headers,
    )
    assert res_empty.status_code == 200
    assert res_empty.json()["entities"] == []
