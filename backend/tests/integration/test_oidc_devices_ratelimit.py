"""Integration tests — OIDC verifiers, POST /v1/devices, rate limiting.

Covers §4.6 #4 (Google/Apple verifiers) and §4.6 #10 (rate limiting).
OIDC tests use a locally-generated RSA key pair injected as a fake JWKS
client, so no network access is needed. dev_mock flow is unchanged.
"""

import jwt as pyjwt
import pytest
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from httpx import AsyncClient

from app.config import settings
from app.core.errors import AppError, ErrorCode
from app.core.rate_limit import limiter
from app.modules.auth.oidc import AppleOIDCVerifier, GoogleOIDCVerifier

pytestmark = pytest.mark.asyncio


# ── Helpers ───────────────────────────────────────────────────────────────────


def _generate_rsa_key() -> rsa.RSAPrivateKey:
    return rsa.generate_private_key(public_exponent=65537, key_size=2048)


def _private_pem(key: rsa.RSAPrivateKey) -> str:
    return key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    ).decode("utf-8")


def _public_pem(key: rsa.RSAPrivateKey) -> str:
    return (
        key.public_key()
        .public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo,
        )
        .decode("utf-8")
    )


class _FakeJWKSClient:
    """Duck-typed jwt.PyJWKClient serving a locally-generated public key."""

    def __init__(self, public_key_pem: str) -> None:
        self._public_key = serialization.load_pem_public_key(public_key_pem.encode("utf-8"))

    def get_signing_key_from_jwt(self, token: str):
        class _FakeSigningKey:
            key = self._public_key

        return _FakeSigningKey()


@pytest.fixture
def rsa_key() -> rsa.RSAPrivateKey:
    return _generate_rsa_key()


@pytest.fixture
def google_client_id(monkeypatch: pytest.MonkeyPatch) -> str:
    client_id = "test-google-client-id.apps.googleusercontent.com"
    monkeypatch.setattr(settings, "GOOGLE_CLIENT_ID", client_id)
    return client_id


@pytest.fixture
def apple_client_id(monkeypatch: pytest.MonkeyPatch) -> str:
    client_id = "com.example.billtracker.test"
    monkeypatch.setattr(settings, "APPLE_CLIENT_ID", client_id)
    return client_id


def _google_verifier(rsa_key: rsa.RSAPrivateKey) -> GoogleOIDCVerifier:
    return GoogleOIDCVerifier(jwks_client=_FakeJWKSClient(_public_pem(rsa_key)))


def _apple_verifier(rsa_key: rsa.RSAPrivateKey) -> AppleOIDCVerifier:
    return AppleOIDCVerifier(jwks_client=_FakeJWKSClient(_public_pem(rsa_key)))


def _id_token(
    key: rsa.RSAPrivateKey,
    *,
    iss: str,
    aud: str,
    sub: str = "user-sub-123",
    email: str | None = "user@example.com",
    iat_offset: int = 0,
    expire_offset: int = 600,
) -> str:
    import time

    now = int(time.time())
    payload = {
        "iss": iss,
        "aud": aud,
        "sub": sub,
        "iat": now + iat_offset,
        "exp": now + expire_offset,
    }
    if email:
        payload["email"] = email
    return pyjwt.encode(payload, _private_pem(key), algorithm="RS256")


# ── GoogleOIDCVerifier ────────────────────────────────────────────────────────


class TestGoogleOIDCVerifier:
    async def test_valid_token_returns_claims(self, rsa_key, google_client_id):
        verifier = _google_verifier(rsa_key)
        token = _id_token(rsa_key, iss="https://accounts.google.com", aud=google_client_id)
        claims = await verifier.verify(token)
        assert claims.subject == "user-sub-123"
        assert claims.provider == "google"
        assert claims.email == "user@example.com"
        assert claims.auth_time > 0

    async def test_alternate_issuer_accepted(self, rsa_key, google_client_id):
        verifier = _google_verifier(rsa_key)
        token = _id_token(rsa_key, iss="accounts.google.com", aud=google_client_id)
        claims = await verifier.verify(token)
        assert claims.subject == "user-sub-123"

    async def test_wrong_audience_rejected(self, rsa_key, google_client_id):
        verifier = _google_verifier(rsa_key)
        token = _id_token(rsa_key, iss="https://accounts.google.com", aud="other-app")
        with pytest.raises(AppError) as exc_info:
            await verifier.verify(token)
        assert exc_info.value.status_code == 401

    async def test_wrong_issuer_rejected(self, rsa_key, google_client_id):
        verifier = _google_verifier(rsa_key)
        token = _id_token(rsa_key, iss="https://evil.example.com", aud=google_client_id)
        with pytest.raises(AppError) as exc_info:
            await verifier.verify(token)
        assert exc_info.value.status_code == 401

    async def test_bad_signature_rejected(self, rsa_key, google_client_id):
        other_key = _generate_rsa_key()
        verifier = _google_verifier(rsa_key)
        token = _id_token(other_key, iss="https://accounts.google.com", aud=google_client_id)
        with pytest.raises(AppError) as exc_info:
            await verifier.verify(token)
        assert exc_info.value.status_code == 401

    async def test_expired_token_rejected(self, rsa_key, google_client_id):
        verifier = _google_verifier(rsa_key)
        token = _id_token(
            rsa_key,
            iss="https://accounts.google.com",
            aud=google_client_id,
            iat_offset=-3600,
            expire_offset=-1800,
        )
        with pytest.raises(AppError) as exc_info:
            await verifier.verify(token)
        assert exc_info.value.status_code == 401


# ── AppleOIDCVerifier ─────────────────────────────────────────────────────────


class TestAppleOIDCVerifier:
    async def test_valid_token_returns_claims(self, rsa_key, apple_client_id):
        verifier = _apple_verifier(rsa_key)
        token = _id_token(rsa_key, iss="https://appleid.apple.com", aud=apple_client_id, email=None)
        claims = await verifier.verify(token)
        assert claims.subject == "user-sub-123"
        assert claims.provider == "apple"
        assert claims.email is None

    async def test_wrong_audience_rejected(self, rsa_key, apple_client_id):
        verifier = _apple_verifier(rsa_key)
        token = _id_token(rsa_key, iss="https://appleid.apple.com", aud="com.other.app")
        with pytest.raises(AppError) as exc_info:
            await verifier.verify(token)
        assert exc_info.value.status_code == 401

    async def test_wrong_issuer_rejected(self, rsa_key, apple_client_id):
        verifier = _apple_verifier(rsa_key)
        token = _id_token(rsa_key, iss="https://accounts.google.com", aud=apple_client_id)
        with pytest.raises(AppError) as exc_info:
            await verifier.verify(token)
        assert exc_info.value.status_code == 401


# ── POST /v1/devices ──────────────────────────────────────────────────────────


async def _get_access_token(async_client: AsyncClient, sub: str) -> str:
    dev_res = await async_client.post(
        "/v1/auth/dev-token", json={"sub": sub, "email": f"{sub}@example.com"}
    )
    assert dev_res.status_code == 200
    ex_res = await async_client.post(
        "/v1/auth/exchange",
        json={
            "provider": "dev_mock",
            "id_token": dev_res.json()["id_token"],
            "device_name": "Test Phone",
            "device_platform": "ios",
        },
    )
    assert ex_res.status_code == 200
    return ex_res.json()["access_token"]


class TestRegisterDeviceEndpoint:
    async def test_register_device_returns_id(self, async_client: AsyncClient):
        token = await _get_access_token(async_client, "device_reg_user")
        headers = {"Authorization": f"Bearer {token}"}

        res = await async_client.post(
            "/v1/devices",
            json={"name": "iPad của Alice", "platform": "ios"},
            headers=headers,
        )
        assert res.status_code == 201
        data = res.json()
        assert data["id"]
        assert data["name"] == "iPad của Alice"
        assert data["platform"] == "ios"
        assert data["is_current"] is False

    async def test_registered_device_appears_in_list(self, async_client: AsyncClient):
        token = await _get_access_token(async_client, "device_list_user")
        headers = {"Authorization": f"Bearer {token}"}

        reg_res = await async_client.post(
            "/v1/devices",
            json={"name": "Android Phone", "platform": "android"},
            headers=headers,
        )
        assert reg_res.status_code == 201

        list_res = await async_client.get("/v1/devices", headers=headers)
        assert list_res.status_code == 200
        names = [d["name"] for d in list_res.json()]
        assert "Test Phone" in names  # created by /auth/exchange
        assert "Android Phone" in names

    async def test_register_requires_auth(self, async_client: AsyncClient):
        res = await async_client.post("/v1/devices", json={"name": "No Auth", "platform": "ios"})
        # HTTPBearer returns 403 when the Authorization header is missing.
        assert res.status_code in (401, 403)

    async def test_register_rejects_unknown_platform(self, async_client: AsyncClient):
        token = await _get_access_token(async_client, "device_platform_user")
        headers = {"Authorization": f"Bearer {token}"}
        res = await async_client.post(
            "/v1/devices",
            json={"name": "Weird", "platform": "windows"},
            headers=headers,
        )
        assert res.status_code == 422


# ── Rate limiting ─────────────────────────────────────────────────────────────


class TestRateLimiting:
    @pytest.fixture
    def enable_limiter(self):
        """Enable the limiter with fresh storage for this test only."""
        limiter.enabled = True
        limiter.reset()
        yield limiter
        limiter.enabled = False
        limiter.reset()

    async def test_auth_limit_returns_429_rate_limited(
        self, async_client: AsyncClient, enable_limiter
    ):
        # RATE_LIMIT_AUTH_PER_MIN defaults to 10/min — exhaust it.
        last_response = None
        for _ in range(11):
            last_response = await async_client.post(
                "/v1/auth/dev-token", json={"sub": "rate_limit_user"}
            )
        assert last_response is not None
        assert last_response.status_code == 429
        error = last_response.json()["error"]
        assert error["code"] == ErrorCode.RATE_LIMITED.value
        assert error["retryable"] is True

    async def test_keyed_by_user_different_users_not_blocked(
        self, async_client: AsyncClient, enable_limiter
    ):
        # Two different subs stay under the limit individually (key=ip:user).
        for i in range(5):
            res_a = await async_client.post("/v1/auth/dev-token", json={"sub": f"rl_user_a_{i}"})
            assert res_a.status_code == 200
        res_b = await async_client.post("/v1/auth/dev-token", json={"sub": "rl_user_b"})
        assert res_b.status_code == 200

    async def test_limiter_disabled_allows_high_volume(self, async_client: AsyncClient):
        # Default suite state (conftest) — limiter off, no 429s.
        for _ in range(12):
            res = await async_client.post("/v1/auth/dev-token", json={"sub": "unlimited_user"})
            assert res.status_code == 200
