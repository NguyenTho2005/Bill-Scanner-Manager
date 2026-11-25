"""BillTracker Backend API — FastAPI application factory.

Local-first, opt-in cloud sync backend for BillTracker.
All endpoints require Bearer token except /health.
DEV_AUTH_ENABLED=true enables mock OIDC for local testing only.
"""

from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import structlog
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi.errors import RateLimitExceeded

from app.config import get_settings
from app.core.errors import AppError, app_error_handler
from app.core.logging import configure_logging
from app.core.rate_limit import limiter
from app.middleware import RequestIDMiddleware, RequestTimingMiddleware, SecurityHeadersMiddleware

logger = structlog.get_logger(__name__)


def rate_limit_exceeded_handler(request: Request, exc: Exception) -> JSONResponse:
    """Convert slowapi RateLimitExceeded into the standard AppError envelope."""
    request_id = getattr(request.state, "request_id", "unknown")
    limit_detail = getattr(exc, "detail", "")
    return JSONResponse(
        status_code=429,
        content={
            "error": {
                "code": "rate_limited",
                "message": "Rate limit exceeded, retry later",
                "requestId": request_id,
                "retryable": True,
                "detail": {"limit": str(limit_detail)},
            }
        },
    )


def create_app() -> FastAPI:
    """Application factory — creates and configures the FastAPI app."""
    settings = get_settings()
    configure_logging(settings.ENVIRONMENT)

    @asynccontextmanager
    async def lifespan(app: FastAPI) -> AsyncIterator[None]:
        """Startup and shutdown lifecycle management."""
        log = structlog.get_logger()

        # Startup
        log.info(
            "billtracker_api_starting",
            version=settings.APP_VERSION,
            environment=settings.ENVIRONMENT,
            dev_auth_enabled=settings.DEV_AUTH_ENABLED,
        )

        if settings.DEV_AUTH_ENABLED and settings.is_production:
            raise RuntimeError(
                "DEV_AUTH_ENABLED=true is NOT allowed in production environment. "
                "Set DEV_AUTH_ENABLED=false."
            )

        yield

        # Shutdown
        log.info("billtracker_api_shutting_down")

    # Disable docs in production
    docs_url = "/docs" if not settings.is_production else None
    redoc_url = "/redoc" if not settings.is_production else None
    openapi_url = "/openapi.json" if not settings.is_production else None

    app = FastAPI(
        title="BillTracker API",
        description=(
            "Backend API for BillTracker Cloud Backup & Sync (P1).\n\n"
            "**Local-first principle**: app works fully offline; this API is opt-in.\n\n"
            "All endpoints (except /health) require `Authorization: Bearer <access_token>`."
        ),
        version=settings.APP_VERSION,
        docs_url=docs_url,
        redoc_url=redoc_url,
        openapi_url=openapi_url,
        lifespan=lifespan,
    )

    # ── Middleware (order matters: outermost first in execution) ──────────────
    app.add_middleware(SecurityHeadersMiddleware)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"] if settings.is_development else [],
        allow_credentials=False,  # credentials sent via Authorization header, not cookies
        allow_methods=["GET", "POST", "DELETE", "OPTIONS"],
        allow_headers=["Authorization", "Content-Type", "X-Request-ID"],
    )
    app.add_middleware(RequestTimingMiddleware)
    app.add_middleware(RequestIDMiddleware)

    # ── Exception handlers ────────────────────────────────────────────────────
    app.add_exception_handler(AppError, app_error_handler)  # type: ignore[arg-type]
    app.add_exception_handler(RateLimitExceeded, rate_limit_exceeded_handler)
    app.state.limiter = limiter

    # ── Routers ───────────────────────────────────────────────────────────────
    # Import here to avoid circular imports at module level
    from app.modules.assistant.router import router as assistant_router
    from app.modules.auth.router import devices_router
    from app.modules.auth.router import router as auth_router
    from app.modules.health.router import router as health_router
    from app.modules.households.router import budgets_router
    from app.modules.households.router import router as households_router
    from app.modules.media.router import router as media_router
    from app.modules.ocr.router import router as ocr_router
    from app.modules.privacy.router import router as privacy_router
    from app.modules.sync.router import router as sync_router

    # Health (no version prefix — required for load balancers)
    app.include_router(health_router)

    # Versioned API endpoints
    api_v1_prefix = "/v1"
    app.include_router(auth_router, prefix=api_v1_prefix)
    app.include_router(devices_router, prefix=api_v1_prefix)
    app.include_router(households_router, prefix=api_v1_prefix)
    app.include_router(budgets_router, prefix=api_v1_prefix)
    app.include_router(sync_router, prefix=api_v1_prefix)
    app.include_router(media_router, prefix=api_v1_prefix)
    app.include_router(privacy_router, prefix=api_v1_prefix)
    app.include_router(ocr_router, prefix=api_v1_prefix)
    app.include_router(assistant_router, prefix=api_v1_prefix)

    return app


# Module-level app instance (for uvicorn)
app = create_app()
