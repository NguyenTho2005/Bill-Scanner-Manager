"""In-process API rate limiting via slowapi (§4.6 #10).

Key = client IP + authenticated user id (extracted from the Bearer token
without signature verification — keying only, no trust decision).

Limits (configurable via env, see Settings):
  - /v1/auth/*           → RATE_LIMIT_AUTH_PER_MIN       (default 10/min)
  - /v1/sync/push        → RATE_LIMIT_SYNC_PUSH_PER_MIN   (default 30/min)
  - /v1/sync/pull        → RATE_LIMIT_SYNC_PULL_PER_MIN   (default 60/min)
  - /v1/assistant/chat   → RATE_LIMIT_ASSISTANT_PER_MIN   (default 10/min)

Exceeding a limit raises slowapi's RateLimitExceeded, converted by the
handler in main.py into the standard AppError envelope (code=rate_limited,
HTTP 429).
"""

import jwt
from fastapi import Request
from slowapi import Limiter
from slowapi.util import get_remote_address

from app.config import get_settings


def rate_limit_key(request: Request) -> str:
    """Build the limit key: ``ip:user_id`` (user from unverified JWT sub)."""
    ip = get_remote_address(request) or "unknown"
    auth = request.headers.get("Authorization", "")
    user_id = ""
    if auth.startswith("Bearer "):
        try:
            payload = jwt.decode(auth[7:], options={"verify_signature": False})
            user_id = str(payload.get("sub") or "")
        except Exception:  # noqa: BLE001 — keying must never break the request
            user_id = ""
    return f"{ip}:{user_id}"


settings = get_settings()

limiter = Limiter(
    key_func=rate_limit_key,
    storage_uri="memory://",
    enabled=settings.RATE_LIMIT_ENABLED,
)

# Limit values, read from settings at import time (routes decorate with these).
AUTH_LIMIT: str = f"{settings.RATE_LIMIT_AUTH_PER_MIN}/minute"
SYNC_PUSH_LIMIT: str = f"{settings.RATE_LIMIT_SYNC_PUSH_PER_MIN}/minute"
SYNC_PULL_LIMIT: str = f"{settings.RATE_LIMIT_SYNC_PULL_PER_MIN}/minute"
ASSISTANT_LIMIT: str = f"{settings.RATE_LIMIT_ASSISTANT_PER_MIN}/minute"
