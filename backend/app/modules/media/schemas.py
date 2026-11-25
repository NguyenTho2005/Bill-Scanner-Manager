from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class UploadIntentRequest(BaseModel):
    media_type: Literal["product", "receipt", "screenshot"]
    content_type: Literal["image/jpeg", "image/png", "image/heic", "image/webp"]
    size_bytes: int = Field(gt=0)
    content_hash: str  # SHA-256 hex, client-computed
    transaction_id: str | None = None
    width: int | None = None
    height: int | None = None
    captured_at: datetime | None = None


class UploadIntentResponse(BaseModel):
    media_id: str
    upload_url: str  # pre-signed PUT URL (NEVER log)
    expires_at: datetime


class CompleteUploadRequest(BaseModel):
    content_hash: str  # SHA-256, must match what was declared in intent
    size_bytes: int


class CompleteUploadResponse(BaseModel):
    media_id: str
    state: str  # 'ready'
    revision: int


class DownloadIntentResponse(BaseModel):
    media_id: str
    download_url: str  # pre-signed GET URL (NEVER log)
    expires_at: datetime


class MediaResponse(BaseModel):
    id: str
    transaction_id: str | None
    media_type: str
    state: str
    size_bytes: int
    width: int | None
    height: int | None
    captured_at: datetime | None
    revision: int
    created_at: datetime
