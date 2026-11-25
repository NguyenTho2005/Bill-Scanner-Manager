"""OpenAI-compatible chat proxy used by the opt-in cloud assistant.

The server holds the provider key so it never ships inside the mobile app.
On-device answers remain the default: this endpoint is only called for
free-form questions the local NLU cannot classify.
"""

from __future__ import annotations

import httpx

import app.core.errors as errors
from app.modules.assistant.schemas import (
    AssistantChatRequest,
    AssistantChatResponse,
)

SYSTEM_PROMPT = (
    "Bạn là trợ lý tài chính cá nhân trong ứng dụng BillTracker. "
    "Chỉ dùng số liệu trong phần DỮ LIỆU NGƯỜI DÙNG, không được bịa con số. "
    "Trả lời bằng tiếng Việt, ngắn gọn (tối đa 120 từ), văn bản thuần, "
    "không markdown, không bảng. Nếu thiếu dữ liệu, nói rõ và gợi ý cách "
    "ghi thêm giao dịch trong app. Không nhắc tới việc bạn là mô hình ngôn ngữ."
)


class AssistantService:
    """Calls any OpenAI-compatible ``/chat/completions`` endpoint."""

    def __init__(
        self,
        base_url: str,
        api_key: str,
        model: str,
        timeout: float = 30.0,
        temperature: float = 0.3,
        transport: httpx.AsyncBaseTransport | None = None,
    ) -> None:
        self._base_url = (base_url or "").rstrip("/")
        self._api_key = api_key or ""
        self._model = model or "gpt-4o-mini"
        self._timeout = timeout
        self._temperature = temperature
        self._transport = transport

    @property
    def is_configured(self) -> bool:
        """Cloud answers require both an endpoint and a provider key."""
        return bool(self._base_url and self._api_key)

    @property
    def model(self) -> str:
        return self._model

    async def chat(self, request: AssistantChatRequest) -> AssistantChatResponse:
        """Forward the question to the provider and return plain text."""
        if not self.is_configured:
            raise errors.AssistantUnavailableError(
                "Cloud assistant is not configured on this server. "
                "The app keeps answering on-device."
            )

        payload = {
            "model": self._model,
            "temperature": self._temperature,
            "messages": self._build_messages(request),
        }
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self._api_key}",
        }

        try:
            async with httpx.AsyncClient(
                timeout=self._timeout,
                transport=self._transport,
            ) as client:
                response = await client.post(
                    f"{self._base_url}/chat/completions",
                    json=payload,
                    headers=headers,
                )
        except httpx.TimeoutException as exc:
            raise errors.AssistantUpstreamError(
                "The AI provider timed out. Try again later."
            ) from exc
        except httpx.HTTPError as exc:
            raise errors.AssistantUpstreamError("Could not reach the AI provider.") from exc

        if response.status_code >= 400:
            # Never echo provider bodies: they may contain request metadata.
            raise errors.AssistantUpstreamError(
                f"The AI provider rejected the request ({response.status_code})."
            )

        try:
            data = response.json()
            content = data["choices"][0]["message"]["content"]
        except (ValueError, KeyError, IndexError, TypeError) as exc:
            raise errors.AssistantUpstreamError(
                "The AI provider returned an unexpected payload."
            ) from exc

        reply = str(content).strip()
        if not reply:
            raise errors.AssistantUpstreamError("The AI provider returned an empty answer.")

        return AssistantChatResponse(reply=reply, model=self._model)

    def _build_messages(self, request: AssistantChatRequest) -> list[dict[str, str]]:
        system = SYSTEM_PROMPT
        if request.context:
            system = f"{system}\n\nDỮ LIỆU NGƯỜI DÙNG:\n{request.context}"
        messages: list[dict[str, str]] = [{"role": "system", "content": system}]
        for turn in request.history:
            messages.append({"role": turn.role, "content": turn.content})
        messages.append({"role": "user", "content": request.message})
        return messages
