import json

from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.core.errors import NotFoundError
from app.core.rate_limit import AUTH_LIMIT, limiter
from app.db.models.user import Device, User
from app.db.session import get_db
from app.dependencies import get_current_device, get_current_user
from app.modules.auth.schemas import (
    AuthExchangeRequest,
    AuthExchangeResponse,
    DeviceResponse,
    DevMockTokenRequest,
    RefreshRequest,
    RefreshResponse,
    RegisterDeviceRequest,
)
from app.modules.auth.service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])
auth_service = AuthService()


@router.post("/exchange", response_model=AuthExchangeResponse)
@limiter.limit(AUTH_LIMIT)
async def exchange_token(
    request: Request,
    body: AuthExchangeRequest,
    db: AsyncSession = Depends(get_db),
) -> AuthExchangeResponse:
    return await auth_service.exchange_token(db, body)


@router.post("/refresh", response_model=RefreshResponse)
@limiter.limit(AUTH_LIMIT)
async def refresh_tokens(
    request: Request,
    body: RefreshRequest,
    db: AsyncSession = Depends(get_db),
) -> RefreshResponse:
    return await auth_service.refresh_tokens(db, body)


@router.post("/dev-token")
@limiter.limit(AUTH_LIMIT)
async def generate_dev_token(request: Request, body: DevMockTokenRequest) -> dict[str, str]:
    if not settings.DEV_AUTH_ENABLED:
        raise NotFoundError("Dev auth is disabled")
    payload = {"sub": body.sub, "email": body.email}
    return {"id_token": json.dumps(payload)}


devices_router = APIRouter(prefix="/devices", tags=["devices"])


@devices_router.post("", response_model=DeviceResponse, status_code=201)
async def register_device(
    request: RegisterDeviceRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> DeviceResponse:
    """Register a new device for the current user (§4.4 device model).

    Returns the device_id to use with subsequent auth flows.
    """
    return await auth_service.register_device(db, current_user.id, request)


@devices_router.get("", response_model=list[DeviceResponse])
async def list_devices(
    current_user: User = Depends(get_current_user),
    current_device: Device = Depends(get_current_device),
    db: AsyncSession = Depends(get_db),
):
    return await auth_service.list_devices(db, current_user.id, current_device.id)


@devices_router.delete("/{device_id}")
async def revoke_device(
    device_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await auth_service.revoke_device(db, device_id, current_user.id)
    return {"status": "success"}
