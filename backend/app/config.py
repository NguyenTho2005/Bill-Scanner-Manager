"""Application configuration loaded from environment variables.

All secrets (DB password, S3 keys, JWT keys) must come from environment variables
or a secrets manager. Never hardcode secrets here.

In development with DEV_AUTH_ENABLED=true, an ephemeral RSA key pair is generated
automatically at startup. This is NOT suitable for production.
"""

from __future__ import annotations

from functools import lru_cache
from typing import Literal

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # ── Application ─────────────────────────────────────────────────────────
    ENVIRONMENT: Literal["development", "staging", "production"] = "development"
    LOG_LEVEL: str = "INFO"
    APP_VERSION: str = "0.1.0"

    # ── Database ─────────────────────────────────────────────────────────────
    DATABASE_URL: str = Field(description="PostgreSQL asyncpg connection URL")

    # ── JWT / Auth ────────────────────────────────────────────────────────────
    JWT_ALGORITHM: str = "RS256"
    JWT_PRIVATE_KEY_PEM: str = Field(
        default="", description="RSA private key PEM (auto-generated in dev)"
    )
    JWT_PUBLIC_KEY_PEM: str = Field(
        default="", description="RSA public key PEM (auto-generated in dev)"
    )
    JWT_PRIVATE_KEY_PATH: str = Field(
        default="",
        description=(
            "Path to RSA private key PEM file (production). Used when "
            "JWT_PRIVATE_KEY_PEM is empty. Example: /run/secrets/jwt_private_key"
        ),
    )
    JWT_PUBLIC_KEY_PATH: str = Field(
        default="",
        description=(
            "Path to RSA public key PEM file (production). Used when "
            "JWT_PUBLIC_KEY_PEM is empty. Example: /run/secrets/jwt_public_key"
        ),
    )
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 90

    # ── Dev/Mock Auth ─────────────────────────────────────────────────────────
    DEV_AUTH_ENABLED: bool = Field(
        default=False,
        description="Enable mock OIDC (dev/test only). NEVER set true in production.",
    )
    DEV_AUTH_MOCK_ISSUER: str = "http://localhost:8000"

    # ── Apple OIDC ────────────────────────────────────────────────────────────
    APPLE_CLIENT_ID: str = ""
    APPLE_TEAM_ID: str = ""
    APPLE_KEY_ID: str = ""
    APPLE_PRIVATE_KEY_PATH: str = ""

    # ── Google OIDC ───────────────────────────────────────────────────────────
    GOOGLE_CLIENT_ID: str = ""

    # ── Object Storage (S3-compatible) ────────────────────────────────────────
    S3_ENDPOINT: str = ""  # empty = use AWS S3 default
    S3_BUCKET: str = "billtracker-media"
    S3_REGION: str = "us-east-1"
    S3_ACCESS_KEY: str = ""
    S3_SECRET_KEY: str = ""
    S3_UPLOAD_URL_TTL: int = 900  # 15 minutes
    S3_DOWNLOAD_URL_TTL: int = 300  # 5 minutes

    # ── Media Limits ──────────────────────────────────────────────────────────
    MEDIA_MAX_ORIGINAL_BYTES: int = 20 * 1024 * 1024  # 20 MB
    MEDIA_MAX_COMPRESSED_BYTES: int = 5 * 1024 * 1024  # 5 MB
    MEDIA_MAX_THUMBNAIL_BYTES: int = 200 * 1024  # 200 KB
    MEDIA_QUOTA_PER_USER_BYTES: int = 2 * 1024 * 1024 * 1024  # 2 GB

    # ── Sync ──────────────────────────────────────────────────────────────────
    SYNC_MAX_PUSH_OPS: int = 100
    SYNC_MAX_PULL_LIMIT: int = 200
    SYNC_IDEMPOTENCY_TTL_DAYS: int = 7

    # ── Account Lifecycle ─────────────────────────────────────────────────────
    ACCOUNT_DELETION_GRACE_DAYS: int = 30
    EXPORT_DOWNLOAD_URL_TTL: int = 86400  # 24 hours

    # ── Optional Cloud Assistant (P2, opt-in) ─────────────────────────────────
    # Empty values keep the endpoint disabled; the mobile app answers locally.
    LLM_BASE_URL: str = Field(
        default="",
        description="OpenAI-compatible base URL, e.g. https://api.openai.com/v1",
    )
    LLM_API_KEY: str = Field(default="", description="Provider key (server-side only)")
    LLM_MODEL: str = "gpt-4o-mini"
    LLM_TIMEOUT_SECONDS: float = 30.0
    LLM_TEMPERATURE: float = 0.3

    # ── Rate Limiting ─────────────────────────────────────────────────────────
    RATE_LIMIT_ENABLED: bool = True
    RATE_LIMIT_AUTH_PER_MIN: int = Field(
        default=10, description="Requests/min per IP+user for /v1/auth/*"
    )
    RATE_LIMIT_SYNC_PUSH_PER_MIN: int = Field(
        default=30, description="Requests/min per IP+user for /v1/sync/push"
    )
    RATE_LIMIT_SYNC_PULL_PER_MIN: int = Field(
        default=60, description="Requests/min per IP+user for /v1/sync/pull"
    )
    RATE_LIMIT_ASSISTANT_PER_MIN: int = Field(
        default=10, description="Requests/min per IP+user for /v1/assistant/chat"
    )

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=True,
    )

    @staticmethod
    def _load_pem_file(path: str) -> str:
        """Read a PEM key file; raise a clear error when missing/unreadable."""
        try:
            with open(path, encoding="utf-8") as fh:
                content = fh.read()
        except OSError as exc:
            raise RuntimeError(
                f"JWT key file not found or unreadable: {path!r}. "
                "Set JWT_PRIVATE_KEY_PATH / JWT_PUBLIC_KEY_PATH correctly, "
                "or provide JWT_PRIVATE_KEY_PEM / JWT_PUBLIC_KEY_PEM directly."
            ) from exc
        if "PRIVATE KEY" not in content and "PUBLIC KEY" not in content:
            raise RuntimeError(
                f"JWT key file {path!r} does not look like a PEM key " "(missing BEGIN/END header)."
            )
        return content

    def model_post_init(self, __context: object) -> None:
        """Load keys from file paths, auto-generate in dev, validate production.

        Resolution order (B.3):
          1. Inline PEM env vars (JWT_PRIVATE_KEY_PEM / JWT_PUBLIC_KEY_PEM).
          2. PEM files referenced by JWT_PRIVATE_KEY_PATH / JWT_PUBLIC_KEY_PATH
             (production pattern — Docker secrets / mounted volumes).
          3. Dev: ephemeral RSA pair generated when DEV_AUTH_ENABLED=true.
          4. Production with no key at all → refuse to start.
        """
        if not self.JWT_PRIVATE_KEY_PEM and self.JWT_PRIVATE_KEY_PATH:
            object.__setattr__(
                self, "JWT_PRIVATE_KEY_PEM", self._load_pem_file(self.JWT_PRIVATE_KEY_PATH)
            )
        if not self.JWT_PUBLIC_KEY_PEM and self.JWT_PUBLIC_KEY_PATH:
            object.__setattr__(
                self, "JWT_PUBLIC_KEY_PEM", self._load_pem_file(self.JWT_PUBLIC_KEY_PATH)
            )

        if self.DEV_AUTH_ENABLED and not self.JWT_PRIVATE_KEY_PEM:
            private_key = rsa.generate_private_key(
                public_exponent=65537,
                key_size=2048,
            )
            # Store in mutable copy — pydantic v2 models are normally frozen
            # but BaseSettings allows mutation during __init__
            object.__setattr__(
                self,
                "JWT_PRIVATE_KEY_PEM",
                private_key.private_bytes(
                    encoding=serialization.Encoding.PEM,
                    format=serialization.PrivateFormat.PKCS8,
                    encryption_algorithm=serialization.NoEncryption(),
                ).decode("utf-8"),
            )
            object.__setattr__(
                self,
                "JWT_PUBLIC_KEY_PEM",
                private_key.public_key()
                .public_bytes(
                    encoding=serialization.Encoding.PEM,
                    format=serialization.PublicFormat.SubjectPublicKeyInfo,
                )
                .decode("utf-8"),
            )

        if self.is_production and not self.JWT_PRIVATE_KEY_PEM:
            raise RuntimeError(
                "Production requires JWT keys: set JWT_PRIVATE_KEY_PEM / "
                "JWT_PUBLIC_KEY_PEM, or JWT_PRIVATE_KEY_PATH / "
                "JWT_PUBLIC_KEY_PATH (e.g. Docker secrets). "
                "DEV_AUTH_ENABLED must also be false in production."
            )

    @field_validator("ENVIRONMENT")
    @classmethod
    def validate_environment(cls, v: str) -> str:
        """Ensure DEV_AUTH_ENABLED cannot be set in production (checked elsewhere)."""
        return v

    @property
    def is_development(self) -> bool:
        return self.ENVIRONMENT == "development"

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT == "production"


@lru_cache
def get_settings() -> Settings:
    """Return cached Settings singleton. Use as FastAPI dependency."""
    return Settings()


# Module-level convenience instance
settings = get_settings()
