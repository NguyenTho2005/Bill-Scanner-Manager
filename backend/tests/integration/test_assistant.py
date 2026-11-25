"""Tests for the opt-in cloud assistant proxy."""

from __future__ import annotations

import json

import httpx
import pytest
from httpx import AsyncClient

import app.core.errors as errors
from app.main import app
from app.modules.assistant.router import get_assistant_service
from app.modules.assistant.schemas import AssistantChatRequest, ChatTurn
from app.modules.assistant.service import AssistantService

pytestmark = pytest.mark.asyncio


def _json_provider(body: dict, status_code: int = 200):
    def handler(request: httpx.Request) -> httpx.Response:
        return httpx.Response(status_code, json=body, request=request)

    return httpx.MockTransport(handler)


def _completion_body(text: str = "Bạn nên tiết kiệm hơn.") -> dict:
    return {
        "choices": [
            {"message": {"role": "assistant", "content": text}},
        ],
    }


class _Recorder:
    def __init__(self) -> None:
        self.requests: list[httpx.Request] = []

    def transport(self, body: dict, status_code: int = 200) -> httpx.MockTransport:
        def handler(request: httpx.Request) -> httpx.Response:
            self.requests.append(request)
            return httpx.Response(status_code, json=body, request=request)

        return httpx.MockTransport(handler)


def _client() -> AsyncClient:
    return AsyncClient(base_url="http://test", transport=httpx.ASGITransport(app=app))


async def test_chat_returns_the_provider_answer(user_a_headers):
    recorder = _Recorder()
    service = AssistantService(
        base_url="https://provider.test/v1",
        api_key="sk-secret",
        model="gpt-test",
        transport=recorder.transport(_completion_body()),
    )
    app.dependency_overrides[get_assistant_service] = lambda: service

    async with _client() as ac:
        response = await ac.post(
            "/v1/assistant/chat",
            json={"message": "làm sao để tiết kiệm"},
            headers=user_a_headers,
        )

    assert response.status_code == 200
    data = response.json()
    assert data["reply"] == "Bạn nên tiết kiệm hơn."
    assert data["model"] == "gpt-test"

    request = recorder.requests[0]
    assert request.headers["Authorization"] == "Bearer sk-secret"
    payload = json.loads(request.content)
    assert payload["model"] == "gpt-test"
    assert payload["messages"][0]["role"] == "system"
    assert "BillTracker" in payload["messages"][0]["content"]
    assert payload["messages"][-1]["content"] == "làm sao để tiết kiệm"


async def test_chat_forwards_history_and_context(user_a_headers):
    recorder = _Recorder()
    service = AssistantService(
        base_url="https://provider.test/v1",
        api_key="k",
        model="m",
        transport=recorder.transport(_completion_body()),
    )
    app.dependency_overrides[get_assistant_service] = lambda: service

    payload = AssistantChatRequest(
        message="top 3",
        context="Tháng này chi 50.000đ",
        history=[
            ChatTurn(role="user", content="tháng này tôi tiêu bao nhiêu?"),
            ChatTurn(role="assistant", content="Bạn chi 50.000đ."),
        ],
    )

    async with _client() as ac:
        await ac.post("/v1/assistant/chat", json=payload.model_dump(), headers=user_a_headers)

    sent = json.loads(recorder.requests[0].content)
    roles = [m["role"] for m in sent["messages"]]
    assert roles == ["system", "user", "assistant", "user"]
    assert "Tháng này chi 50.000đ" in sent["messages"][0]["content"]


async def test_chat_disabled_returns_503(user_a_headers):
    service = AssistantService(base_url="", api_key="", model="m")
    app.dependency_overrides[get_assistant_service] = lambda: service

    async with _client() as ac:
        response = await ac.post(
            "/v1/assistant/chat",
            json={"message": "xin chào"},
            headers=user_a_headers,
        )

    assert response.status_code == 503
    assert response.json()["error"]["code"] == "ai_unavailable"


async def test_chat_provider_401_returns_retryable_502(user_a_headers):
    service = AssistantService(
        base_url="https://provider.test/v1",
        api_key="sk-secret",
        model="m",
        transport=_json_provider({"error": "bad key"}, 401),
    )
    app.dependency_overrides[get_assistant_service] = lambda: service

    async with _client() as ac:
        response = await ac.post(
            "/v1/assistant/chat",
            json={"message": "xin chào"},
            headers=user_a_headers,
        )

    assert response.status_code == 502
    assert response.json()["error"]["retryable"] is True


async def test_chat_requires_auth(async_client):
    response = await async_client.post("/v1/assistant/chat", json={"message": "xin chào"})
    # HTTPBearer returns 403 when the header is missing.
    assert response.status_code in [401, 403]


async def test_chat_requires_message(user_a_headers):
    async with _client() as ac:
        response = await ac.post("/v1/assistant/chat", json={}, headers=user_a_headers)
    assert response.status_code == 422


@pytest.mark.parametrize(
    "provider_body",
    [
        {},  # missing choices
        {"choices": [{"message": {}}]},  # empty content
    ],
)
async def test_chat_rejects_malformed_provider_payload(user_a_headers, provider_body):
    service = AssistantService(
        base_url="https://provider.test/v1",
        api_key="k",
        model="m",
        transport=_json_provider(provider_body, 200),
    )
    app.dependency_overrides[get_assistant_service] = lambda: service

    async with _client() as ac:
        response = await ac.post(
            "/v1/assistant/chat",
            json={"message": "xin chào"},
            headers=user_a_headers,
        )

    assert response.status_code == 502


def test_service_requires_key_and_base_url():
    assert AssistantService(base_url="https://x/v1", api_key="k", model="m").is_configured
    assert not AssistantService(base_url="https://x/v1", api_key="", model="m").is_configured
    assert not AssistantService(base_url="", api_key="k", model="m").is_configured


def test_error_defaults():
    assert errors.AssistantUnavailableError().status_code == 503
    assert errors.AssistantUpstreamError().status_code == 502
    assert errors.AssistantUpstreamError().retryable is True
