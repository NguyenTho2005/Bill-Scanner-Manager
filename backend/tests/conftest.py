import os
from collections.abc import AsyncGenerator

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.dialects.sqlite import base as _sqlite_dialect
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool, StaticPool

from app.config import get_settings
from app.db.base import Base
from app.db.session import get_db
from app.main import app

# C.2 — SQLite test DB must be able to compile PostgreSQL-only JSONB columns
_sqlite_dialect.SQLiteTypeCompiler.visit_JSONB = lambda self, type_, **kwargs: "JSON"

# Force dev auth enabled in tests
settings = get_settings()
settings.DEV_AUTH_ENABLED = True

# Rate limiting is disabled for the general test suite (§4.6 #10): the
# in-memory limiter would otherwise accumulate calls across test functions
# and trip the /v1/auth/* limit. tests/integration/test_oidc_devices_ratelimit.py
# re-enables the limiter, resets storage and disables it again afterwards.
from app.core.rate_limit import limiter as _rate_limiter  # noqa: E402

_rate_limiter.enabled = False

# In-memory SQLite by default; set TEST_DATABASE_URL to run against PostgreSQL (§4.6 #22).
TEST_DB_URL = os.environ.get("TEST_DATABASE_URL", "sqlite+aiosqlite:///:memory:")

if TEST_DB_URL.startswith("sqlite"):
    engine = create_async_engine(
        TEST_DB_URL, connect_args={"check_same_thread": False}, poolclass=StaticPool, echo=False
    )
else:
    engine = create_async_engine(TEST_DB_URL, poolclass=NullPool, echo=False)
TestingSessionLocal = async_sessionmaker(
    autocommit=False, autoflush=False, bind=engine, class_=AsyncSession
)


@pytest_asyncio.fixture(scope="function")
async def test_db() -> AsyncGenerator[AsyncSession, None]:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with TestingSessionLocal() as session:
        yield session
        await session.rollback()

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest_asyncio.fixture(scope="function")
async def async_client() -> AsyncGenerator[AsyncClient, None]:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    # C.6 — a NEW session per dependency call so concurrent requests no longer
    # share one async session (fixes "another operation is in progress").
    async def override_get_db():
        async with TestingSessionLocal() as session:
            yield session

    app.dependency_overrides[get_db] = override_get_db
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()

    if not TEST_DB_URL.startswith("sqlite"):
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.drop_all)


@pytest.fixture
def user_a_headers():
    return {"Authorization": "Bearer dev_mock_token_user_a"}


@pytest.fixture
def user_b_headers():
    return {"Authorization": "Bearer dev_mock_token_user_b"}


@pytest.fixture
def device_a():
    return "dev_device_user_a"


@pytest.fixture
def device_b():
    return "dev_device_user_b"
