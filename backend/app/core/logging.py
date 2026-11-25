import logging
import sys
from contextvars import ContextVar
from typing import Any, cast

import structlog

request_id_ctx_var: ContextVar[str | None] = ContextVar("request_id", default=None)
user_id_ctx_var: ContextVar[str | None] = ContextVar("user_id", default=None)
device_id_ctx_var: ContextVar[str | None] = ContextVar("device_id", default=None)

# Always keep lowercase because lookup uses `key.lower()` (§4.6 #23).
SENSITIVE_KEYS = frozenset(
    {
        "access_token",
        "refresh_token",
        "bearer_token",
        "id_token",
        "password",
        "secret",
        "api_key",
        "authorization",
        "amount",
        "amount_limit",
        "total",
        "subtotal",
        "tax",
        "unit_price",
        "merchant",
        "note",
        "payload",
        "context",
        "rawtext",
        "raw_text",
        "labels",
        "labels_json",
        "extracted_amounts_json",
        "transactions",
        "history",
        "message",
    }
)


def _redact_value(value: Any) -> Any:
    if isinstance(value, str) and "X-Amz-Signature" in value:
        return "***REDACTED_URL***"
    if isinstance(value, dict):
        return {
            k: "***REDACTED***" if str(k).lower() in SENSITIVE_KEYS else _redact_value(v)
            for k, v in value.items()
        }
    if isinstance(value, list):
        return [_redact_value(item) for item in value]
    return value


def add_context_vars(
    logger: structlog.types.BindableLogger, method_name: str, event_dict: dict[str, Any]
) -> dict[str, Any]:
    req_id = request_id_ctx_var.get()
    if req_id:
        event_dict["request_id"] = req_id
    uid = user_id_ctx_var.get()
    if uid:
        event_dict["user_id"] = uid
    did = device_id_ctx_var.get()
    if did:
        event_dict["device_id"] = did
    return event_dict


def redact_sensitive_data(
    logger: structlog.types.BindableLogger, method_name: str, event_dict: dict[str, Any]
) -> dict[str, Any]:
    for key in list(event_dict.keys()):
        if key.lower() in SENSITIVE_KEYS:
            event_dict[key] = "***REDACTED***"
        else:
            event_dict[key] = _redact_value(event_dict[key])
    return event_dict


def configure_logging(environment: str) -> None:
    shared_processors: list[Any] = [
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        add_context_vars,
        redact_sensitive_data,
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
    ]

    if environment == "production":
        processors = shared_processors + [structlog.processors.JSONRenderer()]
    else:
        processors = shared_processors + [structlog.dev.ConsoleRenderer()]

    structlog.configure(
        processors=processors,
        wrapper_class=structlog.stdlib.BoundLogger,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )
    logging.basicConfig(format="%(message)s", stream=sys.stdout, level=logging.INFO)


def get_logger(name: str) -> structlog.stdlib.BoundLogger:
    return cast(structlog.stdlib.BoundLogger, structlog.get_logger(name))
