"""Optional assistant proxy endpoint (opt-in cloud AI)."""

from __future__ import annotations

from fastapi import APIRouter, Depends, Request

from app.config import get_settings
from app.core.rate_limit import ASSISTANT_LIMIT, limiter
from app.db.models.user import User
from app.dependencies import get_current_user
from app.modules.assistant.schemas import (
    AssistantChatRequest,
    AssistantChatResponse,
)
from app.modules.assistant.service import AssistantService

router = APIRouter(prefix="/assistant", tags=["assistant"])


def get_assistant_service() -> AssistantService:
    """Build the service from server-side configuration."""
    settings = get_settings()
    return AssistantService(
        base_url=settings.LLM_BASE_URL,
        api_key=settings.LLM_API_KEY,
        model=settings.LLM_MODEL,
        timeout=settings.LLM_TIMEOUT_SECONDS,
        temperature=settings.LLM_TEMPERATURE,
    )


@router.post("/chat", response_model=AssistantChatResponse)
@limiter.limit(ASSISTANT_LIMIT)
async def chat(
    request: Request,
    payload: AssistantChatRequest,
    current_user: User = Depends(get_current_user),
    service: AssistantService = Depends(get_assistant_service),
) -> AssistantChatResponse:
    """Answer a free-form question with the configured LLM.

    Questions about concrete numbers are answered on-device by the app; this
    endpoint exists for conversational follow-ups when the user explicitly
    enabled cloud AI.
    """
    return await service.chat(payload)
