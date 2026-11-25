from datetime import UTC, datetime

from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.core.errors import ForbiddenError, UnauthorizedError
from app.core.logging import device_id_ctx_var, user_id_ctx_var
from app.core.security import verify_access_token
from app.db.models.user import Device, User
from app.db.session import get_db

oauth2_scheme = HTTPBearer()


def auth_time_to_dt(ts: float) -> datetime:
    """Convert POSIX timestamp to aware datetime."""
    return datetime.fromtimestamp(ts, tz=UTC)


async def get_current_user(
    request: Request,
    token: HTTPAuthorizationCredentials = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    settings = get_settings()
    cred = token.credentials
    auth_time = datetime.now(UTC).timestamp()

    # Support dev mock tokens during test / dev mode
    if settings.DEV_AUTH_ENABLED and cred.startswith("dev_mock_token_"):
        user_id = cred.replace("dev_mock_token_", "")
        user_id_ctx_var.set(user_id)
        device_id_ctx_var.set(f"dev_device_{user_id}")
        # B.1-compat: expose verified-ish auth_time for downstream consumers
        request.state.auth_time = auth_time

        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            # Create user on the fly for test
            user = User(id=user_id, created_at=auth_time_to_dt(auth_time))
            db.add(user)
            await db.flush()
        return user

    payload = verify_access_token(cred)
    user_id = payload.get("sub")
    if not user_id:
        raise UnauthorizedError("Invalid token payload")

    # B.1: expose verified auth_time for downstream consumers (e.g. DELETE /me)
    verified_auth_time = payload.get("auth_time")
    if isinstance(verified_auth_time, int | float):
        request.state.auth_time = int(verified_auth_time)
    else:
        request.state.auth_time = auth_time

    user_id_ctx_var.set(user_id)
    device_id_ctx_var.set(payload.get("device_id"))

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user:
        raise UnauthorizedError("User not found")
    if user.deleted_at:
        raise UnauthorizedError("User account deleted")

    return user


async def get_current_device(
    token: HTTPAuthorizationCredentials = Depends(oauth2_scheme),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Device:
    settings = get_settings()
    cred = token.credentials

    # Support dev mock device
    if settings.DEV_AUTH_ENABLED and cred.startswith("dev_mock_token_"):
        device_id = f"dev_device_{current_user.id}"
        result = await db.execute(select(Device).where(Device.id == device_id))
        device = result.scalar_one_or_none()
        if not device:
            device = Device(
                id=device_id,
                user_id=current_user.id,
                name="Dev Test Device",
                platform="ios",
                created_at=datetime.now(UTC),
                last_seen_at=datetime.now(UTC),
            )
            db.add(device)
            await db.flush()
        return device

    payload = verify_access_token(cred)
    device_id = payload.get("device_id")

    result = await db.execute(select(Device).where(Device.id == device_id))
    device = result.scalar_one_or_none()

    if not device:
        raise UnauthorizedError("Device not found")
    if device.user_id != current_user.id:
        raise ForbiddenError("Device does not belong to user")
    if device.revoked_at:
        raise UnauthorizedError("Device has been revoked")

    return device


async def get_device_id(current_device: Device = Depends(get_current_device)) -> str:
    return current_device.id


def get_storage():
    from app.modules.media.storage import StorageClient

    return StorageClient()


def require_recent_auth(
    token: HTTPAuthorizationCredentials = Depends(oauth2_scheme),
    current_user: User = Depends(get_current_user),
) -> User:
    settings = get_settings()
    cred = token.credentials
    if settings.DEV_AUTH_ENABLED and cred.startswith("dev_mock_token_"):
        return current_user

    payload = verify_access_token(cred)
    auth_time = payload.get("auth_time", 0)
    current_time = datetime.now(UTC).timestamp()

    if current_time - auth_time > 300:  # 5 minutes
        raise UnauthorizedError("Recent authentication required")

    return current_user
