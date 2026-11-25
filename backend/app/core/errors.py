from enum import Enum

from fastapi import Request
from fastapi.responses import JSONResponse


class ErrorCode(str, Enum):
    SYNC_CONFLICT = "sync_conflict"
    NOT_FOUND = "not_found"
    FORBIDDEN = "forbidden"
    UNAUTHORIZED = "unauthorized"
    VALIDATION_ERROR = "validation_error"
    RATE_LIMITED = "rate_limited"
    QUOTA_EXCEEDED = "quota_exceeded"
    MEDIA_INVALID = "media_invalid"
    IDP_TOKEN_INVALID = "idp_token_invalid"
    TOMBSTONE_CONFLICT = "tombstone_conflict"
    DEVICE_REVOKED = "device_revoked"
    AI_UNAVAILABLE = "ai_unavailable"
    AI_UPSTREAM_ERROR = "ai_upstream_error"
    INTERNAL_ERROR = "internal_error"


class AppError(Exception):
    def __init__(
        self,
        error_code: ErrorCode,
        message: str,
        status_code: int = 400,
        retryable: bool = False,
        detail: dict | None = None,
    ):
        self.error_code = error_code
        self.message = message
        self.status_code = status_code
        self.retryable = retryable
        self.detail = detail or {}


class SyncConflictError(AppError):
    def __init__(self, message: str = "Sync conflict detected"):
        super().__init__(ErrorCode.SYNC_CONFLICT, message, 409, retryable=False)


class NotFoundError(AppError):
    def __init__(self, message: str = "Resource not found"):
        super().__init__(ErrorCode.NOT_FOUND, message, 404, retryable=False)


class ForbiddenError(AppError):
    def __init__(self, message: str = "Access forbidden"):
        super().__init__(ErrorCode.FORBIDDEN, message, 403, retryable=False)


class UnauthorizedError(AppError):
    def __init__(self, message: str = "Unauthorized access"):
        super().__init__(ErrorCode.UNAUTHORIZED, message, 401, retryable=False)


class TombstoneConflictError(AppError):
    def __init__(self, message: str = "Cannot update deleted item"):
        super().__init__(ErrorCode.TOMBSTONE_CONFLICT, message, 409, retryable=False)


class QuotaExceededError(AppError):
    def __init__(self, message: str = "Storage quota exceeded"):
        super().__init__(ErrorCode.QUOTA_EXCEEDED, message, 402, retryable=False)


class AssistantUnavailableError(AppError):
    def __init__(self, message: str = "Cloud assistant is not configured"):
        super().__init__(ErrorCode.AI_UNAVAILABLE, message, 503, retryable=False)


class AssistantUpstreamError(AppError):
    def __init__(self, message: str = "AI provider error"):
        super().__init__(ErrorCode.AI_UPSTREAM_ERROR, message, 502, retryable=True)


class DeviceRevokedError(AppError):
    def __init__(self, message: str = "Device has been revoked"):
        super().__init__(ErrorCode.DEVICE_REVOKED, message, 401, retryable=False)


class IdpTokenInvalidError(AppError):
    """Identity provider (Google/Apple) rejected the id_token (§4.4)."""

    def __init__(self, message: str = "Identity provider token is invalid"):
        super().__init__(ErrorCode.IDP_TOKEN_INVALID, message, 401, retryable=False)


class RateLimitedError(AppError):
    """Too many requests (§4.6 #10)."""

    def __init__(self, message: str = "Rate limit exceeded"):
        super().__init__(ErrorCode.RATE_LIMITED, message, 429, retryable=True)


class MediaValidationError(AppError):
    def __init__(self, message: str = "Invalid media format or size"):
        super().__init__(ErrorCode.MEDIA_INVALID, message, 422, retryable=False)


async def app_error_handler(request: Request, exc: AppError):
    request_id = getattr(request.state, "request_id", "unknown")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.error_code.value,
                "message": exc.message,
                "requestId": request_id,
                "retryable": exc.retryable,
            }
        },
    )
