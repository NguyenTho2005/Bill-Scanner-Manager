from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/ocr", tags=["ocr"])

not_implemented_exc = HTTPException(
    status_code=501,
    detail={
        "error": {
            "code": "not_implemented",
            "message": "Cloud OCR is planned for P2 release. On-device OCR is available in the Flutter app.",
            "retryable": False,
        }
    },
)


@router.post("/jobs")
async def create_ocr_job() -> None:
    raise not_implemented_exc


@router.get("/jobs/{job_id}")
async def get_ocr_job_status(job_id: str) -> None:
    raise not_implemented_exc


@router.delete("/jobs/{job_id}")
async def cancel_ocr_job(job_id: str) -> None:
    raise not_implemented_exc
