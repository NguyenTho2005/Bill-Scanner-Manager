"""OIDC id_token verifiers for Google and Apple (§4.4, §4.6 #4).

Both providers issue RS256 id_tokens signed with keys published in a JWKS
endpoint. Verification steps (identical for both providers):

1. Fetch the provider JWKS and pick the key matching the token's ``kid``.
2. Verify the RS256 signature, ``exp`` and ``aud`` against our client ID.
3. Verify ``iss`` against the provider's expected issuer(s).
4. Extract ``sub`` / ``email`` / ``auth_time`` (falls back to ``iat``).

Tests inject a fake JWKS client (see tests/integration/test_oidc_devices_ratelimit.py),
so no network access is required. ``dev_mock`` remains untouched (§4.6 #7).
"""

import asyncio
from dataclasses import dataclass
from datetime import UTC, datetime
from typing import Any, Protocol

import jwt
from jwt.exceptions import PyJWKClientError, PyJWTError

from app.config import settings
from app.core.errors import IdpTokenInvalidError, UnauthorizedError


@dataclass
class OIDCClaims:
    subject: str
    provider: str
    email: str | None
    auth_time: int


class OIDCVerifier(Protocol):
    async def verify(self, id_token: str) -> OIDCClaims: ...


class _JWKSClient(Protocol):
    """Subset of ``jwt.PyJWKClient`` used by the verifiers."""

    def get_signing_key_from_jwt(self, token: str) -> jwt.PyJWK: ...


class _BaseJWKSVerifier:
    """Shared RS256/JWKS verification logic for Google and Apple."""

    provider: str
    jwks_url: str
    issuers: tuple[str, ...]

    def __init__(self, jwks_client: _JWKSClient | None = None) -> None:
        self._jwks_client: _JWKSClient = jwks_client or jwt.PyJWKClient(
            self.jwks_url, cache_keys=True
        )

    @property
    def client_id(self) -> str:
        raise NotImplementedError

    async def verify(self, id_token: str) -> OIDCClaims:
        # JWKS fetch + RSA verify are blocking I/O — run off the event loop.
        return await asyncio.to_thread(self._verify_sync, id_token)

    def _verify_sync(self, id_token: str) -> OIDCClaims:
        if not self.client_id:
            raise UnauthorizedError(
                f"{self.provider} login is not configured: missing client ID "
                f"({'GOOGLE_CLIENT_ID' if self.provider == 'google' else 'APPLE_CLIENT_ID'})"
            )
        try:
            signing_key = self._jwks_client.get_signing_key_from_jwt(id_token)
            payload: dict[str, Any] = jwt.decode(
                id_token,
                signing_key.key,
                algorithms=["RS256"],
                audience=self.client_id,
                options={"require": ["exp", "sub"]},
            )
        except (PyJWTError, PyJWKClientError) as exc:
            raise IdpTokenInvalidError(f"Invalid {self.provider} id_token") from exc

        # PyJWT 2.x accepts a single issuer string; check both known forms here.
        if payload.get("iss") not in self.issuers:
            raise IdpTokenInvalidError(f"Invalid {self.provider} id_token issuer")

        subject = payload.get("sub")
        if not subject:
            raise IdpTokenInvalidError(f"{self.provider} id_token missing sub claim")

        auth_time_raw = payload.get("auth_time") or payload.get("iat")
        if isinstance(auth_time_raw, int | float):
            auth_time = int(auth_time_raw)
        else:
            auth_time = int(datetime.now(UTC).timestamp())

        return OIDCClaims(
            subject=str(subject),
            provider=self.provider,
            email=payload.get("email"),
            auth_time=auth_time,
        )


class GoogleOIDCVerifier(_BaseJWKSVerifier):
    """Verifies Google Sign-In id_tokens (RS256, aud=GOOGLE_CLIENT_ID)."""

    provider = "google"
    jwks_url = "https://www.googleapis.com/oauth2/v3/certs"
    issuers = ("https://accounts.google.com", "accounts.google.com")

    @property
    def client_id(self) -> str:
        return settings.GOOGLE_CLIENT_ID


class AppleOIDCVerifier(_BaseJWKSVerifier):
    """Verifies Sign in with Apple id_tokens (RS256, aud=APPLE_CLIENT_ID)."""

    provider = "apple"
    jwks_url = "https://appleid.apple.com/auth/keys"
    issuers = ("https://appleid.apple.com",)

    @property
    def client_id(self) -> str:
        return settings.APPLE_CLIENT_ID


class DevMockOIDCVerifier(OIDCVerifier):
    async def verify(self, id_token: str) -> OIDCClaims:
        if not settings.DEV_AUTH_ENABLED:
            raise UnauthorizedError("Dev mock auth is not enabled")
        import json
        from datetime import datetime

        try:
            payload = json.loads(id_token)
            return OIDCClaims(
                subject=payload["sub"],
                provider="dev_mock",
                email=payload.get("email"),
                auth_time=int(datetime.now(UTC).timestamp()),
            )
        except Exception as exc:
            raise UnauthorizedError("Invalid mock token format") from exc


def get_verifier(provider: str) -> OIDCVerifier:
    if provider == "google":
        return GoogleOIDCVerifier()
    elif provider == "apple":
        return AppleOIDCVerifier()
    elif provider == "dev_mock":
        if not settings.DEV_AUTH_ENABLED:
            raise UnauthorizedError("Dev mock auth is not enabled")
        return DevMockOIDCVerifier()
    else:
        raise ValueError(f"Unknown provider: {provider}")
