import io
import json
import logging

import structlog

from app.core.logging import configure_logging, redact_sensitive_data


def test_redact_sensitive_data_covers_financial_and_nested_keys() -> None:
    logger = structlog.get_logger("test")
    event = {
        "event": "sync_push_received",
        "amount": 150000,
        "merchant": "Highlands Coffee",
        "note": "Cà phê sáng",
        "rawText": "TONG CONG 150.000",
        "payload": {"amount": 200000, "merchant": "Phúc Long"},
        "context": "Chi 500k cho ăn uống",
        "nested": {
            "url": "https://minio.local/bucket/obj?X-Amz-Signature=secret123",
            "safe": "ok",
        },
        "request_id": "req_123",
    }

    redacted = redact_sensitive_data(logger, "info", dict(event))

    assert redacted["amount"] == "***REDACTED***"
    assert redacted["merchant"] == "***REDACTED***"
    assert redacted["note"] == "***REDACTED***"
    assert redacted["rawText"] == "***REDACTED***"
    assert redacted["payload"] == "***REDACTED***"
    assert redacted["context"] == "***REDACTED***"
    assert redacted["nested"]["url"] == "***REDACTED_URL***"
    assert redacted["nested"]["safe"] == "ok"
    assert redacted["request_id"] == "req_123"


def test_configured_logger_emits_no_amount_or_merchant(caplog) -> None:
    stream = io.StringIO()
    configure_logging("production")
    root_logger = logging.getLogger()
    handler = logging.StreamHandler(stream)
    old_handlers = list(root_logger.handlers)
    root_logger.handlers = [handler]
    try:
        log = structlog.get_logger("test_request")
        log.info(
            "sample_request",
            amount=987654,
            merchant="SecretMerchantName",
            note="SecretPersonalNote",
            payload={"inner_amount": 42000},
            context="SensitiveContext",
        )
    finally:
        root_logger.handlers = old_handlers

    output = stream.getvalue()
    assert "987654" not in output
    assert "SecretMerchantName" not in output
    assert "SecretPersonalNote" not in output
    assert "42000" not in output
    assert "SensitiveContext" not in output
    # Production renderer emits valid JSON with redacted markers
    parsed = json.loads(output.strip())
    assert parsed["amount"] == "***REDACTED***"
    assert parsed["merchant"] == "***REDACTED***"
    assert parsed["note"] == "***REDACTED***"
    assert parsed["payload"] == "***REDACTED***"
    assert parsed["context"] == "***REDACTED***"
