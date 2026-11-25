from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.core.errors import ForbiddenError, UnauthorizedError
from app.core.logging import get_logger
from app.core.security import create_access_token, create_refresh_token, generate_ulid, hash_token
from app.db.models.user import AuthIdentity, Device, RefreshToken, User
from app.modules.auth.oidc import get_verifier
from app.modules.auth.schemas import (
    AuthExchangeRequest,
    AuthExchangeResponse,
    DeviceResponse,
    RefreshRequest,
    RefreshResponse,
    RegisterDeviceRequest,
)

logger = get_logger(__name__)


class AuthService:
    async def exchange_token(
        self, db: AsyncSession, request: AuthExchangeRequest
    ) -> AuthExchangeResponse:
        verifier = get_verifier(request.provider)
        claims = await verifier.verify(request.id_token)

        result = await db.execute(
            select(AuthIdentity).where(
                AuthIdentity.provider == claims.provider,
                AuthIdentity.provider_subject == claims.subject,
            )
        )
        auth_identity = result.scalar_one_or_none()

        now = datetime.now(UTC)

        if not auth_identity:
            user = User(id=generate_ulid(), created_at=now)
            db.add(user)
            auth_identity = AuthIdentity(
                id=generate_ulid(),
                user_id=user.id,
                provider=claims.provider,
                provider_subject=claims.subject,
                created_at=now,
                last_used_at=now,
            )
            db.add(auth_identity)
        else:
            auth_identity.last_used_at = now
            result = await db.execute(select(User).where(User.id == auth_identity.user_id))
            user = result.scalar_one_or_none()
            if not user or user.deleted_at:
                raise UnauthorizedError("User account deleted")

        device = Device(
            id=generate_ulid(),
            user_id=user.id,
            name=request.device_name,
            platform=request.device_platform,
            created_at=now,
            last_seen_at=now,
        )
        db.add(device)

        plain_rt, rt_hash = create_refresh_token()
        rt_family = generate_ulid()
        refresh_token_record = RefreshToken(
            id=generate_ulid(),
            device_id=device.id,
            user_id=user.id,
            token_hash=rt_hash,
            family=rt_family,
            expires_at=now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
            created_at=now,
        )
        db.add(refresh_token_record)

        # Snapshot ids before commit (session expires attributes on commit)
        device_id, user_id = device.id, user.id
        access_token = create_access_token(user_id, device_id, claims.auth_time)

        await db.commit()

        return AuthExchangeResponse(
            access_token=access_token,
            refresh_token=plain_rt,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            device_id=device_id,
            user_id=user_id,
        )

    async def refresh_tokens(self, db: AsyncSession, request: RefreshRequest) -> RefreshResponse:
        rt_hash = hash_token(request.refresh_token)

        result = await db.execute(select(RefreshToken).where(RefreshToken.token_hash == rt_hash))
        rt_record = result.scalar_one_or_none()

        now = datetime.now(UTC)

        if not rt_record:
            raise UnauthorizedError("Invalid refresh token")

        if rt_record.used:
            # Token reuse detected! Revoke entire family
            family_tokens = await db.execute(
                select(RefreshToken).where(RefreshToken.family == rt_record.family)
            )
            for t in family_tokens.scalars():
                t.revoked_at = now
            await db.commit()
            raise UnauthorizedError("Token reuse detected")

        # SQLite stores timestamps without tzinfo; normalize for compare (E2.1)
        expires_at = rt_record.expires_at.replace(tzinfo=UTC) if rt_record.expires_at else None
        if rt_record.revoked_at or (expires_at is not None and expires_at < now):
            raise UnauthorizedError("Refresh token expired or revoked")

        if rt_record.device_id != request.device_id:
            raise UnauthorizedError("Invalid device")

        rt_record.used = True

        result = await db.execute(select(Device).where(Device.id == rt_record.device_id))
        device = result.scalar_one_or_none()
        if not device or device.revoked_at:
            raise UnauthorizedError("Device revoked")

        device.last_seen_at = now

        plain_rt, new_rt_hash = create_refresh_token()
        user_id = rt_record.user_id
        new_rt_record = RefreshToken(
            id=generate_ulid(),
            device_id=rt_record.device_id,
            user_id=user_id,
            token_hash=new_rt_hash,
            family=rt_record.family,
            expires_at=now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
            created_at=now,
        )
        db.add(new_rt_record)

        auth_time = int(now.timestamp())
        access_token = create_access_token(user_id, rt_record.device_id, auth_time)

        await db.commit()

        return RefreshResponse(
            access_token=access_token,
            refresh_token=plain_rt,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

    async def revoke_device(self, db: AsyncSession, device_id: str, current_user_id: str) -> None:
        result = await db.execute(select(Device).where(Device.id == device_id))
        device = result.scalar_one_or_none()

        if not device:
            return

        if device.user_id != current_user_id:
            raise ForbiddenError("Not allowed")

        now = datetime.now(UTC)
        device.revoked_at = now

        result = await db.execute(select(RefreshToken).where(RefreshToken.device_id == device_id))
        for rt in result.scalars():
            rt.revoked_at = now

        await db.commit()

    async def register_device(
        self, db: AsyncSession, user_id: str, request: RegisterDeviceRequest
    ) -> DeviceResponse:
        """Register a new device for [user_id] (POST /v1/devices)."""
        now = datetime.now(UTC)
        device = Device(
            id=generate_ulid(),
            user_id=user_id,
            name=request.name,
            platform=request.platform,
            created_at=now,
            last_seen_at=now,
        )
        db.add(device)
        await db.commit()
        await db.refresh(device)

        return DeviceResponse(
            id=device.id,
            name=device.name,
            platform=device.platform,
            created_at=device.created_at,
            last_seen_at=device.last_seen_at,
            is_current=False,
        )

    async def list_devices(
        self, db: AsyncSession, user_id: str, current_device_id: str
    ) -> list[DeviceResponse]:
        result = await db.execute(
            select(Device).where(Device.user_id == user_id, Device.revoked_at.is_(None))
        )
        devices = result.scalars().all()

        return [
            DeviceResponse(
                id=d.id,
                name=d.name,
                platform=d.platform,
                created_at=d.created_at,
                last_seen_at=d.last_seen_at,
                is_current=(d.id == current_device_id),
            )
            for d in devices
        ]
