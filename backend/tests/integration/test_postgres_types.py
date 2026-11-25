from datetime import UTC, datetime
from decimal import Decimal

import pytest
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.ai import AIInference
from app.db.models.budget import Budget
from app.db.models.media import Media
from app.db.models.sync import ChangeLog
from app.db.models.transaction import Transaction
from app.db.models.user import User

pytestmark = pytest.mark.asyncio


async def test_numeric_jsonb_and_changelog_sequence_round_trip(test_db: AsyncSession) -> None:
    """Verify Numeric(18,4), JSONB, and ChangeLog sequence across SQLite & PostgreSQL (§4.6 #22)."""
    now = datetime.now(UTC)
    user = User(id="pg_user_1", created_at=now)
    test_db.add(user)
    await test_db.flush()

    tx = Transaction(
        id="pg_tx_1",
        user_id="pg_user_1",
        type="expense",
        amount=Decimal("12345678.9012"),
        currency="VND",
        category_id="food_drinks",
        occurred_at=now,
        source="manual",
        status="confirmed",
        created_at=now,
        updated_at=now,
    )
    budget = Budget(
        id="pg_bg_1",
        user_id="pg_user_1",
        category_id="food_drinks",
        amount_limit=Decimal("5000000.5000"),
        period_start=now,
        period_end=now,
        updated_at=now,
        created_at=now,
    )
    media = Media(
        id="pg_media_1",
        user_id="pg_user_1",
        object_key="u/pg_media_1.jpg",
        content_hash="abc",
        size_bytes=1024,
        mime_type="image/jpeg",
        media_type="receipt",
        state="ready",
        updated_at=now,
        created_at=now,
    )
    test_db.add_all([tx, budget, media])
    await test_db.flush()

    ai = AIInference(
        id="pg_ai_1",
        media_id="pg_media_1",
        user_id="pg_user_1",
        model_version="v1",
        labels_json={"food": 0.92, "coffee": 0.88},
        extracted_amounts_json=[{"value": 45000, "confidence": 0.91}],
        confidence=0.92,
        latency_ms=120,
        updated_at=now,
        created_at=now,
    )
    cl = ChangeLog(
        user_id="pg_user_1",
        entity_type="transaction",
        entity_id="pg_tx_1",
        operation="upsert",
        revision=1,
        device_id="dev_1",
        changed_at=now,
    )
    if test_db.get_bind().dialect.name == "sqlite":
        max_seq = (
            await test_db.execute(select(func.coalesce(func.max(ChangeLog.sequence), 0)))
        ).scalar_one()
        cl.sequence = int(max_seq) + 1
    test_db.add_all([ai, cl])
    await test_db.commit()

    saved_tx = (
        await test_db.execute(select(Transaction).where(Transaction.id == "pg_tx_1"))
    ).scalar_one()
    assert Decimal(str(saved_tx.amount)) == Decimal("12345678.9012")

    saved_ai = (
        await test_db.execute(select(AIInference).where(AIInference.id == "pg_ai_1"))
    ).scalar_one()
    assert saved_ai.labels_json == {"food": 0.92, "coffee": 0.88}
    assert saved_ai.extracted_amounts_json == [{"value": 45000, "confidence": 0.91}]

    saved_cl = (
        await test_db.execute(select(ChangeLog).where(ChangeLog.entity_id == "pg_tx_1"))
    ).scalar_one()
    assert isinstance(saved_cl.sequence, int)
    assert saved_cl.sequence >= 1
