#!/usr/bin/env python3
"""
BillTracker backend dev seed script.

Seeds safe, non-sensitive development data:
- 2 dev users with mock auth identities
- 1 device per user
- System categories (same as Flutter app default categories)
- Sample transactions and budgets per user

This script is IDEMPOTENT — safe to run multiple times.
It uses INSERT ... ON CONFLICT DO NOTHING for all records.

Usage:
    python scripts/seed_dev.py
    # OR
    make seed
"""

import asyncio
import sys
from datetime import UTC, datetime, timedelta
from pathlib import Path

# Add parent dir to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import AuthIdentity, Budget, Category, Device, Transaction, User
from app.db.session import async_session_maker, engine

# ── Seed data ─────────────────────────────────────────────────────────────────

NOW = datetime.now(UTC)

SYSTEM_CATEGORIES = [
    {
        "id": "food_drinks",
        "name": "Ăn uống",
        "icon": "restaurant",
        "color_value": 0xFFFF6B35,
        "is_system": True,
        "sort_order": 1,
    },
    {
        "id": "transport",
        "name": "Di chuyển",
        "icon": "directions_car",
        "color_value": 0xFF2196F3,
        "is_system": True,
        "sort_order": 2,
    },
    {
        "id": "shopping",
        "name": "Mua sắm",
        "icon": "shopping_bag",
        "color_value": 0xFF9C27B0,
        "is_system": True,
        "sort_order": 3,
    },
    {
        "id": "entertainment",
        "name": "Giải trí",
        "icon": "movie",
        "color_value": 0xFFE91E63,
        "is_system": True,
        "sort_order": 4,
    },
    {
        "id": "health",
        "name": "Sức khỏe",
        "icon": "medical_services",
        "color_value": 0xFF4CAF50,
        "is_system": True,
        "sort_order": 5,
    },
    {
        "id": "education",
        "name": "Giáo dục",
        "icon": "school",
        "color_value": 0xFF00BCD4,
        "is_system": True,
        "sort_order": 6,
    },
    {
        "id": "bills",
        "name": "Hóa đơn",
        "icon": "receipt",
        "color_value": 0xFFFF9800,
        "is_system": True,
        "sort_order": 7,
    },
    {
        "id": "work",
        "name": "Công việc",
        "icon": "work",
        "color_value": 0xFF607D8B,
        "is_system": True,
        "sort_order": 8,
    },
    {
        "id": "travel",
        "name": "Du lịch",
        "icon": "flight",
        "color_value": 0xFF009688,
        "is_system": True,
        "sort_order": 9,
    },
    {
        "id": "other",
        "name": "Khác",
        "icon": "more_horiz",
        "color_value": 0xFF9E9E9E,
        "is_system": True,
        "sort_order": 10,
    },
]

# Dev users — stable IDs for reproducible testing
USER_A_ID = "01JXDEVUSR000000000000000A"
USER_B_ID = "01JXDEVUSR000000000000000B"
DEVICE_A1_ID = "01JXDEVDEV000000000000000A"
DEVICE_B1_ID = "01JXDEVDEV000000000000000B"

DEV_USERS = [
    {
        "id": USER_A_ID,
        "created_at": NOW,
    },
    {
        "id": USER_B_ID,
        "created_at": NOW,
    },
]

DEV_AUTH_IDENTITIES = [
    {
        "id": "01JXDEVAID000000000000000A",
        "user_id": USER_A_ID,
        "provider": "dev_mock",
        "provider_subject": "dev_user_alice",
        "created_at": NOW,
        "last_used_at": NOW,
    },
    {
        "id": "01JXDEVAID000000000000000B",
        "user_id": USER_B_ID,
        "provider": "dev_mock",
        "provider_subject": "dev_user_bob",
        "created_at": NOW,
        "last_used_at": NOW,
    },
]

DEV_DEVICES = [
    {
        "id": DEVICE_A1_ID,
        "user_id": USER_A_ID,
        "name": "Alice's iPhone (dev)",
        "platform": "ios",
        "created_at": NOW,
        "last_seen_at": NOW,
    },
    {
        "id": DEVICE_B1_ID,
        "user_id": USER_B_ID,
        "name": "Bob's Android (dev)",
        "platform": "android",
        "created_at": NOW,
        "last_seen_at": NOW,
    },
]

# Sample transactions — use small, non-sensitive amounts
DEV_TRANSACTIONS_A = [
    {
        "id": "01JXDEVTXA000000000000001",
        "user_id": USER_A_ID,
        "type": "expense",
        "amount": 45000,
        "currency": "VND",
        "category_id": "food_drinks",
        "merchant": "Sample Cafe",
        "occurred_at": NOW - timedelta(days=1),
        "note": "Dev seed transaction",
        "payment_method": "cash",
        "source": "manual",
        "status": "confirmed",
        "revision": 1,
        "updated_at": NOW,
        "created_at": NOW - timedelta(days=1),
    },
    {
        "id": "01JXDEVTXA000000000000002",
        "user_id": USER_A_ID,
        "type": "expense",
        "amount": 120000,
        "currency": "VND",
        "category_id": "transport",
        "merchant": None,
        "occurred_at": NOW - timedelta(days=2),
        "note": None,
        "payment_method": "card",
        "source": "manual",
        "status": "confirmed",
        "revision": 1,
        "updated_at": NOW,
        "created_at": NOW - timedelta(days=2),
    },
]

DEV_BUDGETS_A = [
    {
        "id": "01JXDEVBGT000000000000001",
        "user_id": USER_A_ID,
        "category_id": "food_drinks",
        "period": "monthly",
        "amount_limit": 3000000,
        "alert_thresholds": "[0.8, 1.0, 1.2]",
        "alert_sent_at_80": False,
        "alert_sent_at_100": False,
        "period_start": NOW.replace(day=1, hour=0, minute=0, second=0, microsecond=0),
        "period_end": (
            NOW.replace(day=1, hour=0, minute=0, second=0, microsecond=0) + timedelta(days=31)
        ),
        "revision": 1,
        "updated_at": NOW,
        "created_at": NOW,
    },
]


async def seed_table(session: AsyncSession, table, rows: list[dict]) -> int:
    """Insert rows with ON CONFLICT DO NOTHING. Returns number of new rows."""
    if not rows:
        return 0
    stmt = pg_insert(table).values(rows).on_conflict_do_nothing()
    result = await session.execute(stmt)
    return result.rowcount


async def main() -> None:
    print("🌱 BillTracker dev seed starting...")

    async with async_session_maker() as session:
        async with session.begin():
            # 1. System categories (user_id=NULL)
            n = await seed_table(
                session,
                Category.__table__,
                [
                    {
                        **cat,
                        "user_id": None,
                        "parent_id": None,
                        "revision": 0,
                        "updated_at": NOW,
                        "created_at": NOW,
                    }
                    for cat in SYSTEM_CATEGORIES
                ],
            )
            print(f"  ✅ Categories: {n} new rows (skipped existing)")

            # 2. Dev users
            n = await seed_table(session, User.__table__, DEV_USERS)
            print(f"  ✅ Users: {n} new rows")

            # 3. Auth identities
            n = await seed_table(session, AuthIdentity.__table__, DEV_AUTH_IDENTITIES)
            print(f"  ✅ Auth identities: {n} new rows")

            # 4. Devices
            n = await seed_table(session, Device.__table__, DEV_DEVICES)
            print(f"  ✅ Devices: {n} new rows")

            # 5. Sample transactions (user A)
            n = await seed_table(session, Transaction.__table__, DEV_TRANSACTIONS_A)
            print(f"  ✅ Transactions (User A): {n} new rows")

            # 6. Sample budgets (user A)
            n = await seed_table(session, Budget.__table__, DEV_BUDGETS_A)
            print(f"  ✅ Budgets (User A): {n} new rows")

    await engine.dispose()
    print("\n🎉 Seed complete!")
    print(f"  Dev User A: id={USER_A_ID}, sub=dev_user_alice")
    print(f"  Dev User B: id={USER_B_ID}, sub=dev_user_bob")
    print("\n  Get a dev token:")
    print("  curl -X POST http://localhost:8000/v1/auth/dev-token \\")
    print("    -H 'Content-Type: application/json' \\")
    print(
        '    -d \'{"sub": "dev_user_alice", "device_name": "Test Device",'
        ' "device_platform": "ios"}\''
    )


if __name__ == "__main__":
    asyncio.run(main())
