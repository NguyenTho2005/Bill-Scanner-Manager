from datetime import datetime
from typing import Literal

from pydantic import BaseModel


class ExportJobResponse(BaseModel):
    job_id: str
    status: Literal["queued", "processing", "ready", "failed", "expired"]
    download_url: str | None = None
    expires_at: datetime | None = None
    created_at: datetime


class DeleteAccountRequest(BaseModel):
    pass


class DeleteAccountResponse(BaseModel):
    message: str
    scheduled_delete_at: datetime
