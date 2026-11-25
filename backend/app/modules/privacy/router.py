from datetime import UTC, datetime

from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

import app.core.errors as errors
from app.db.models.user import User
from app.db.session import get_db
from app.dependencies import get_current_user
from app.modules.media.storage import StorageClient

from .schemas import DeleteAccountResponse, ExportJobResponse
from .service import PrivacyService

router = APIRouter(prefix="/me", tags=["privacy"])


def get_privacy_service() -> PrivacyService:
    return PrivacyService(StorageClient())


@router.get("/export", response_model=ExportJobResponse)
async def request_export(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    service: PrivacyService = Depends(get_privacy_service),
):
    return await service.request_export(db, current_user.id)


@router.get("/export/{job_id}", response_model=ExportJobResponse)
async def get_export_job(
    job_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    service: PrivacyService = Depends(get_privacy_service),
):
    """Poll export job status (§4.6 #12)."""
    return await service.get_export_job(db, current_user.id, job_id)


@router.delete("", response_model=DeleteAccountResponse)
async def request_account_deletion(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    service: PrivacyService = Depends(get_privacy_service),
):
    # Require recent auth (auth_time < 5 min)
    auth_time = getattr(request.state, "auth_time", 0)
    now_ts = datetime.now(UTC).timestamp()
    if now_ts - auth_time > 300:
        raise errors.UnauthorizedError("Recent authentication required to delete account")

    return await service.request_account_deletion(db, current_user.id)


@router.get("")
async def get_me(
    current_user: User = Depends(get_current_user),
):
    return {
        "id": current_user.id,
        "created_at": current_user.created_at,
        "deleted_at": current_user.deleted_at,
    }
