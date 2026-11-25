from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.db.session import get_db
from app.modules.media.storage import StorageClient

router = APIRouter(tags=["health"])


def get_health_storage() -> StorageClient:
    return StorageClient()


@router.get("/health")
async def health_check() -> dict[str, str]:
    return {"status": "ok"}


@router.get("/health/ready")
async def readiness_check(
    db: AsyncSession = Depends(get_db),
    storage: StorageClient = Depends(get_health_storage),
) -> dict[str, object]:
    try:
        await db.execute(text("SELECT 1"))
    except Exception as exc:
        raise HTTPException(status_code=503, detail="Database connection failed") from exc

    try:
        await storage.check_bucket()
    except Exception as exc:
        raise HTTPException(status_code=503, detail="Storage connection failed") from exc

    return {
        "status": "ready",
        "checks": {"database": "ok", "storage": "ok"},
    }


@router.get("/health/version")
async def version_info() -> dict[str, str]:
    return {"version": settings.APP_VERSION, "environment": settings.ENVIRONMENT}
