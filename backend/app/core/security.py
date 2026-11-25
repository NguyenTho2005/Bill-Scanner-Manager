"""Centralized JWT helpers using PyJWT (B.3)."""

import hashlib
import secrets
from datetime import UTC, datetime, timedelta

import jwt
from jwt.exceptions import PyJWTError
from ulid import ULID

from app.config import settings


def generate_ulid() -> str:
    """Generate a new ULID string (B.6)."""
    return str(ULID())


def create_access_token(user_id: str, device_id: str, auth_time: int) -> str:
    """Create a signed access JWT (B.1).

    B.3: lifetime from Settings.ACCESS_TOKEN_EXPIRE_MINUTES (15 minutes).
    """
    expire = datetime.now(UTC) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode = {
        "sub": user_id,
        "device_id": device_id,
        "auth_time": auth_time,
        "exp": expire,
    }
    return jwt.encode(to_encode, settings.JWT_PRIVATE_KEY_PEM, algorithm=settings.JWT_ALGORITHM)


def create_refresh_token() -> tuple[str, str]:
    """Create a random opaque refresh token + its SHA-256 stored hash (B.2)."""
    plain_token = secrets.token_urlsafe(32)
    return plain_token, hash_token(plain_token)


def hash_token(token: str) -> str:
    """Hash a refresh token (SHA-256) for storage."""
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def verify_access_token(token: str) -> dict:
    """Verify and decode an access JWT (B.1)."""
    try:
        return jwt.decode(token, settings.JWT_PUBLIC_KEY_PEM, algorithms=[settings.JWT_ALGORITHM])
    except PyJWTError as exc:
        from app.core.errors import UnauthorizedError

        raise UnauthorizedError("Invalid access token") from exc


def encode_cursor(sequence: int) -> str:
    """C2 — encode a BigSerial sequence into the sync cursor format."""
    return f"seq_{sequence:018d}"


def decode_cursor(cursor_str: str) -> int:
    """C2 — decode a sync cursor into a sequence int; tolerate unknown."""
    try:
        return int(cursor_str.replace("seq_", ""))
    except ValueError:
        return 0
