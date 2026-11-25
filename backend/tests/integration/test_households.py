from datetime import UTC, datetime, timedelta

import pytest
from httpx import AsyncClient

pytestmark = pytest.mark.asyncio


@pytest.fixture
def user_c_headers() -> dict[str, str]:
    return {"Authorization": "Bearer dev_mock_token_user_c"}


async def test_household_invite_accept_and_roles(
    async_client: AsyncClient,
    user_a_headers: dict[str, str],
    user_b_headers: dict[str, str],
    user_c_headers: dict[str, str],
) -> None:
    # 1. User A creates a household
    create_res = await async_client.post(
        "/v1/households",
        json={"name": "Gia đình A-B", "display_name": "Minh"},
        headers=user_a_headers,
    )
    assert create_res.status_code == 201, create_res.text
    hh = create_res.json()
    hh_id = hh["id"]
    assert hh["name"] == "Gia đình A-B"
    assert hh["created_by"] == "user_a"
    assert len(hh["members"]) == 1
    assert hh["members"][0]["user_id"] == "user_a"
    assert hh["members"][0]["role"] == "owner"
    assert hh["members"][0]["display_name"] == "Minh"

    # 2. Owner A creates an invite code/link
    invite_res = await async_client.post(
        f"/v1/households/{hh_id}/invites",
        json={"expires_in_hours": 24},
        headers=user_a_headers,
    )
    assert invite_res.status_code == 201, invite_res.text
    invite = invite_res.json()
    assert invite["code"].startswith("BT-")
    assert invite["invite_link"] == f"billtracker://household/join?code={invite['code']}"

    # 3. User B accepts the invite
    accept_res = await async_client.post(
        "/v1/households/invites/accept",
        json={"code": invite["code"], "display_name": "Lan"},
        headers=user_b_headers,
    )
    assert accept_res.status_code == 200, accept_res.text
    joined_hh = accept_res.json()
    assert len(joined_hh["members"]) == 2
    member_b = next(m for m in joined_hh["members"] if m["user_id"] == "user_b")
    assert member_b["role"] == "member"
    assert member_b["display_name"] == "Lan"

    # 4. Re-using the single-use invite by User C is rejected
    reuse_res = await async_client.post(
        "/v1/households/invites/accept",
        json={"code": invite["code"], "display_name": "Stranger"},
        headers=user_c_headers,
    )
    assert reuse_res.status_code == 403

    # 5. Member B (non-owner) cannot create invites or remove owner
    forbidden_invite = await async_client.post(
        f"/v1/households/{hh_id}/invites",
        json={},
        headers=user_b_headers,
    )
    assert forbidden_invite.status_code == 403

    # 6. Outsider User C cannot view household
    outsider_get = await async_client.get(f"/v1/households/{hh_id}", headers=user_c_headers)
    assert outsider_get.status_code == 403


async def test_shared_budget_permissions_via_household_members(
    async_client: AsyncClient,
    user_a_headers: dict[str, str],
    user_b_headers: dict[str, str],
    user_c_headers: dict[str, str],
) -> None:
    # Setup household with A (owner) and B (member)
    hh_id = (
        await async_client.post(
            "/v1/households",
            json={"name": "Nhà chung", "display_name": "An"},
            headers=user_a_headers,
        )
    ).json()["id"]
    code = (
        await async_client.post(f"/v1/households/{hh_id}/invites", json={}, headers=user_a_headers)
    ).json()["code"]
    await async_client.post(
        "/v1/households/invites/accept",
        json={"code": code, "display_name": "Bình"},
        headers=user_b_headers,
    )

    now = datetime.now(UTC)
    period_start = (now - timedelta(days=5)).isoformat()
    period_end = (now + timedelta(days=25)).isoformat()

    # User A creates a shared budget
    b_res = await async_client.post(
        f"/v1/households/{hh_id}/budgets",
        json={
            "category_id": "food_drinks",
            "amount_limit": 5000000,
            "period_start": period_start,
            "period_end": period_end,
        },
        headers=user_a_headers,
    )
    assert b_res.status_code == 201, b_res.text
    budget_id = b_res.json()["id"]
    assert b_res.json()["household_id"] == hh_id
    assert b_res.json()["created_by_user_id"] == "user_a"

    # Member B can view it via /v1/households/{id}/budgets and /v1/budgets/{budget_id}
    hh_budgets = await async_client.get(f"/v1/households/{hh_id}/budgets", headers=user_b_headers)
    assert hh_budgets.status_code == 200
    assert any(b["id"] == budget_id for b in hh_budgets.json())

    single_b = await async_client.get(f"/v1/budgets/{budget_id}", headers=user_b_headers)
    assert single_b.status_code == 200
    assert single_b.json()["id"] == budget_id

    # Outsider User C is blocked from all budget endpoints
    assert (
        await async_client.get(f"/v1/households/{hh_id}/budgets", headers=user_c_headers)
    ).status_code == 403
    assert (
        await async_client.get(f"/v1/budgets/{budget_id}", headers=user_c_headers)
    ).status_code == 403
    assert (
        await async_client.delete(f"/v1/budgets/{budget_id}", headers=user_c_headers)
    ).status_code == 403

    # Owner A removes Member B -> B loses budget access immediately
    rem = await async_client.delete(
        f"/v1/households/{hh_id}/members/user_b", headers=user_a_headers
    )
    assert rem.status_code == 200
    assert (
        await async_client.get(f"/v1/budgets/{budget_id}", headers=user_b_headers)
    ).status_code == 403


async def test_transaction_privacy_is_shared_and_creator_attribution(
    async_client: AsyncClient,
    user_a_headers: dict[str, str],
    user_b_headers: dict[str, str],
    user_c_headers: dict[str, str],
    device_a: str,
    device_b: str,
) -> None:
    # Setup household with A ("Minh") and B ("Lan")
    hh_id = (
        await async_client.post(
            "/v1/households",
            json={"name": "Shared Home", "display_name": "Minh"},
            headers=user_a_headers,
        )
    ).json()["id"]
    code = (
        await async_client.post(f"/v1/households/{hh_id}/invites", json={}, headers=user_a_headers)
    ).json()["code"]
    await async_client.post(
        "/v1/households/invites/accept",
        json={"code": code, "display_name": "Lan"},
        headers=user_b_headers,
    )

    now = datetime.now(UTC)
    now_iso = now.isoformat()
    period_start = (now - timedelta(days=5)).isoformat()
    period_end = (now + timedelta(days=25)).isoformat()

    # Create shared food budget
    await async_client.post(
        f"/v1/households/{hh_id}/budgets",
        json={
            "category_id": "food_drinks",
            "amount_limit": 2000000,
            "period_start": period_start,
            "period_end": period_end,
        },
        headers=user_a_headers,
    )

    # User A pushes 1 private tx (is_shared=False) and 1 shared tx (is_shared=True),
    # intentionally attempting to spoof user_id in payload (must be ignored by §4.3).
    push_a = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_a,
            "operations": [
                {
                    "operation_id": "op_hh_priv_a",
                    "entity_type": "transaction",
                    "entity_id": "tx_priv_a",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "user_id": "spoofed_user",
                        "type": "expense",
                        "amount": 900000,
                        "currency": "VND",
                        "category_id": "food_drinks",
                        "merchant": "Private Gift",
                        "occurred_at": now_iso,
                        "status": "confirmed",
                        "source": "manual",
                        "is_shared": False,
                        "household_id": hh_id,
                    },
                },
                {
                    "operation_id": "op_hh_shared_a",
                    "entity_type": "transaction",
                    "entity_id": "tx_shared_a",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "user_id": "spoofed_user",
                        "type": "expense",
                        "amount": 150000,
                        "currency": "VND",
                        "category_id": "food_drinks",
                        "merchant": "Siêu thị Co.op",
                        "occurred_at": now_iso,
                        "status": "confirmed",
                        "source": "manual",
                        "is_shared": True,
                        "household_id": hh_id,
                    },
                },
            ],
        },
        headers=user_a_headers,
    )
    assert push_a.status_code == 200, push_a.text

    # User B pushes 1 shared tx
    push_b = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": device_b,
            "operations": [
                {
                    "operation_id": "op_hh_shared_b",
                    "entity_type": "transaction",
                    "entity_id": "tx_shared_b",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "type": "expense",
                        "amount": 50000,
                        "currency": "VND",
                        "category_id": "food_drinks",
                        "merchant": "Chợ Bến Thành",
                        "occurred_at": now_iso,
                        "status": "confirmed",
                        "source": "manual",
                        "is_shared": True,
                        "household_id": hh_id,
                    },
                },
            ],
        },
        headers=user_b_headers,
    )
    assert push_b.status_code == 200, push_b.text

    # Shared budget spent_amount must ONLY count shared txs (150k + 50k = 200k), NOT 900k private
    budgets_b = (
        await async_client.get(f"/v1/households/{hh_id}/budgets", headers=user_b_headers)
    ).json()
    assert len(budgets_b) == 1
    assert budgets_b[0]["spent_amount"] == 200000.0

    # Shared transactions list shows creator attribution and excludes private tx
    hh_txs = (
        await async_client.get(f"/v1/households/{hh_id}/transactions", headers=user_b_headers)
    ).json()
    tx_ids = {t["id"] for t in hh_txs}
    assert tx_ids == {"tx_shared_a", "tx_shared_b"}
    tx_a = next(t for t in hh_txs if t["id"] == "tx_shared_a")
    assert tx_a["created_by_user_id"] == "user_a"  # spoofed_user ignored
    assert tx_a["created_by_name"] == "Minh"
    tx_b = next(t for t in hh_txs if t["id"] == "tx_shared_b")
    assert tx_b["created_by_user_id"] == "user_b"
    assert tx_b["created_by_name"] == "Lan"

    # Sync pull for User B sees User A's shared tx + shared budget, NEVER tx_priv_a
    pull_b = (
        await async_client.get(
            "/v1/sync/pull?cursor=seq_000000000000000000", headers=user_b_headers
        )
    ).json()
    pulled_ids = {c["entity_id"] for c in pull_b["changes"]}
    assert "tx_shared_a" in pulled_ids
    assert "tx_priv_a" not in pulled_ids
    pulled_shared_a = next(c for c in pull_b["changes"] if c["entity_id"] == "tx_shared_a")
    assert pulled_shared_a["payload"]["created_by_name"] == "Minh"

    # Sync bootstrap for User B also excludes tx_priv_a
    boot_b = (await async_client.get("/v1/sync/bootstrap", headers=user_b_headers)).json()
    boot_ids = {e["entity_id"] for e in boot_b["entities"]}
    assert "tx_shared_a" in boot_ids
    assert "tx_priv_a" not in boot_ids

    # Outsider User C cannot push a budget targeting hh_id
    push_c = await async_client.post(
        "/v1/sync/push",
        json={
            "device_id": "dev_device_user_c",
            "operations": [
                {
                    "operation_id": "op_hack_hh",
                    "entity_type": "budget",
                    "entity_id": "bgt_hack",
                    "operation": "upsert",
                    "base_revision": 0,
                    "occurred_at": now_iso,
                    "payload": {
                        "household_id": hh_id,
                        "category_id": "food_drinks",
                        "amount_limit": 1,
                        "period_start": period_start,
                        "period_end": period_end,
                    },
                }
            ],
        },
        headers=user_c_headers,
    )
    assert push_c.status_code == 403
