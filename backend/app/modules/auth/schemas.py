from datetime import datetime
from typing import Literal

from pydantic import BaseModel


class AuthExchangeRequest(BaseModel):
    provider: Literal["apple", "google", "dev_mock"]
    id_token: str
    device_name: str
    device_platform: Literal["ios", "android"]


class AuthExchangeResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    device_id: str
    user_id: str


class RefreshRequest(BaseModel):
    refresh_token: str
    device_id: str


class RefreshResponse(BaseModel):
    access_token: str
    refresh_token: str
    expires_in: int


class RegisterDeviceRequest(BaseModel):
    name: str
    platform: Literal["ios", "android"]


class DeviceResponse(BaseModel):
    id: str
    name: str
    platform: str
    created_at: datetime
    last_seen_at: datetime
    is_current: bool


class DevMockTokenRequest(BaseModel):
    sub: str
    email: str | None = None
