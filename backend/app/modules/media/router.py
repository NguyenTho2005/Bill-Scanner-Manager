from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.user import User
from app.db.session import get_db
from app.dependencies import get_current_user, get_device_id

from .schemas import (
    CompleteUploadRequest,
    CompleteUploadResponse,
    DownloadIntentResponse,
    UploadIntentRequest,
    UploadIntentResponse,
)
from .service import MediaService
from .storage import StorageClient

router = APIRouter(prefix="/media", tags=["media"])


def get_media_service() -> MediaService:
    return MediaService(StorageClient())


@router.post("/upload-intents", response_model=UploadIntentResponse)
async def create_upload_intent(
    request: UploadIntentRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    service: MediaService = Depends(get_media_service),
):
    return await service.create_upload_intent(db, current_user.id, request)


@router.post("/{media_id}/complete", response_model=CompleteUploadResponse)
async def complete_upload(
    media_id: str,
    request: CompleteUploadRequest,
    current_user: User = Depends(get_current_user),
    device_id: str = Depends(get_device_id),
    db: AsyncSession = Depends(get_db),
    service: MediaService = Depends(get_media_service),
):
    return await service.complete_upload(db, current_user.id, media_id, request, device_id)


@router.get("/{media_id}/download-intent", response_model=DownloadIntentResponse)
async def get_download_intent(
    media_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    service: MediaService = Depends(get_media_service),
):
    return await service.get_download_intent(db, current_user.id, media_id)


@router.delete("/{media_id}", status_code=204)
async def delete_media(
    media_id: str,
    current_user: User = Depends(get_current_user),
    device_id: str = Depends(get_device_id),
    db: AsyncSession = Depends(get_db),
    service: MediaService = Depends(get_media_service),
):
    await service.delete_media(db, current_user.id, media_id, device_id)
    return None
