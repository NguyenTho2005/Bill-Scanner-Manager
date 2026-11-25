from typing import Any

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.rate_limit import SYNC_PULL_LIMIT, SYNC_PUSH_LIMIT, limiter
from app.db.session import get_db
from app.dependencies import get_current_device, get_current_user
from app.modules.sync.schemas import BootstrapResponse, PullResponse, PushRequest, PushResponse
from app.modules.sync.service import SyncService

router = APIRouter(prefix="/sync", tags=["sync"])
sync_service = SyncService()


@router.post("/push", response_model=PushResponse)
@limiter.limit(SYNC_PUSH_LIMIT)
async def push(
    request: Request,
    payload: PushRequest,
    current_user: Any = Depends(get_current_user),
    current_device: Any = Depends(get_current_device),
    db: AsyncSession = Depends(get_db),
) -> PushResponse:
    # Get IDs from dependencies
    user_id = current_user.id
    device_id = current_device.id
    return await sync_service.push(db, user_id, device_id, payload)


@router.get("/pull", response_model=PullResponse)
@limiter.limit(SYNC_PULL_LIMIT)
async def pull(
    request: Request,
    cursor: str = Query(..., description="Required cursor"),
    limit: int = Query(default=200, le=200, ge=1),
    current_user: Any = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> PullResponse:
    user_id = current_user.id
    return await sync_service.pull(db, user_id, cursor, limit)


@router.get("/bootstrap", response_model=BootstrapResponse)
async def bootstrap(
    page: int = Query(default=0, ge=0),
    page_size: int = Query(default=100, le=100, ge=1),
    current_user: Any = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> BootstrapResponse:
    user_id = current_user.id
    return await sync_service.bootstrap(db, user_id, page, page_size)
