"""Request/response contracts for the optional assistant proxy."""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field


class ChatTurn(BaseModel):
    """One previous conversation turn replayed to the model."""

    role: Literal["user", "assistant"]
    content: str = Field(min_length=1, max_length=4000)


class AssistantChatRequest(BaseModel):
    """A free-form question plus the on-device aggregate context.

    The client sends only aggregated spending figures it already computed
    locally (monthly totals, category shares, budget limits). It never sends
    receipt images, merchant names or account identifiers.
    """

    message: str = Field(min_length=1, max_length=2000)
    history: list[ChatTurn] = Field(default_factory=list, max_length=20)
    context: str | None = Field(
        default=None,
        max_length=6000,
        description="Aggregated, non-identifying spending summary from the device",
    )


class AssistantChatResponse(BaseModel):
    """Plain-text answer produced by the configured LLM."""

    reply: str
    model: str
    used_cloud: bool = True
