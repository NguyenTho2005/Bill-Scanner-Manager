from enum import Enum
from typing import Protocol


class OCRJobStatus(str, Enum):
    QUEUED = "queued"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class OCRResult:
    merchant: str | None
    transaction_date: str | None
    total: float | None
    currency: str | None
    overall_confidence: float
    line_items: list[dict]
    requires_review: bool
    model_version: str
    latency_ms: int


class CloudOCRProvider(Protocol):
    """Protocol for cloud OCR providers. Implement for P2."""

    async def submit_job(
        self,
        media_id: str,
        object_key: str,
        document_type: str,
        locale: str = "vi-VN",
    ) -> str:
        """Submit OCR job. Returns job_id."""
        ...

    async def get_job_status(self, job_id: str) -> OCRJobStatus: ...

    async def get_job_result(self, job_id: str) -> OCRResult: ...

    async def cancel_job(self, job_id: str) -> None: ...
