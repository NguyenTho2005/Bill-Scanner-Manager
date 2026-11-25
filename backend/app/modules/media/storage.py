"""S3-compatible object storage client.

Provides pre-signed URL generation and object management for media files.
NEVER log pre-signed URLs — they grant temporary access to private objects.
"""

from __future__ import annotations

import uuid
from typing import Any

import structlog
from aiobotocore.session import get_session
from botocore.exceptions import ClientError

from app.config import get_settings

logger = structlog.get_logger(__name__)

# Magic byte signatures for file type detection
# Key: MIME type, Value: (bytes_to_check, offset)
_MAGIC_SIGNATURES: dict[str, tuple[bytes, int]] = {
    "image/jpeg": (b"\xff\xd8\xff", 0),
    "image/png": (b"\x89PNG\r\n\x1a\n", 0),
    "image/webp": (b"WEBP", 8),  # check bytes 8-12 (after RIFF + size)
}


class StorageClient:
    """S3-compatible storage client wrapping aiobotocore.

    All pre-signed URLs are temporary and must NEVER be logged.
    Bucket must be PRIVATE — access only via pre-signed URLs.
    """

    ALLOWED_MIME_TYPES: frozenset[str] = frozenset(
        ["image/jpeg", "image/png", "image/heic", "image/webp"]
    )

    def __init__(self) -> None:
        settings = get_settings()
        self._session = get_session()
        self._s3_config: dict[str, Any] = {
            "region_name": settings.S3_REGION,
            "aws_access_key_id": settings.S3_ACCESS_KEY,
            "aws_secret_access_key": settings.S3_SECRET_KEY,
        }
        # MinIO / custom endpoint support
        if settings.S3_ENDPOINT:
            self._s3_config["endpoint_url"] = settings.S3_ENDPOINT
        self.bucket = settings.S3_BUCKET

    def _client(self):
        """Return async context manager for S3 client."""
        return self._session.create_client("s3", **self._s3_config)

    async def check_bucket(self) -> None:
        """Verify S3/MinIO connectivity by issuing HEAD on the configured bucket."""
        async with self._client() as client:
            await client.head_bucket(Bucket=self.bucket)

    async def generate_upload_url(
        self,
        object_key: str,
        content_type: str,
        expires: int = 900,
    ) -> str:
        """Generate pre-signed PUT URL (15 min default).

        SECURITY: Never log the returned URL.
        """
        async with self._client() as client:
            return await client.generate_presigned_url(
                "put_object",
                Params={
                    "Bucket": self.bucket,
                    "Key": object_key,
                    "ContentType": content_type,
                },
                ExpiresIn=expires,
            )

    async def generate_download_url(
        self,
        object_key: str,
        expires: int = 300,
    ) -> str:
        """Generate pre-signed GET URL (5 min default).

        SECURITY: Never log the returned URL.
        """
        async with self._client() as client:
            return await client.generate_presigned_url(
                "get_object",
                Params={
                    "Bucket": self.bucket,
                    "Key": object_key,
                },
                ExpiresIn=expires,
            )

    async def get_object_metadata(self, object_key: str) -> dict[str, Any] | None:
        """HEAD request to get size, etag, content-type. Returns None if not found."""
        async with self._client() as client:
            try:
                response = await client.head_object(Bucket=self.bucket, Key=object_key)
                return {
                    "size_bytes": response.get("ContentLength", 0),
                    "content_type": response.get("ContentType", ""),
                    "etag": response.get("ETag", "").strip('"'),
                }
            except ClientError as e:
                if e.response["Error"]["Code"] in ("404", "NoSuchKey"):
                    return None
                logger.error(
                    "s3_head_object_error",
                    object_key=object_key,
                    error_code=e.response["Error"]["Code"],
                )
                raise

    async def read_first_bytes(self, object_key: str, n: int = 16) -> bytes:
        """Read first N bytes for magic byte validation (never log content)."""
        async with self._client() as client:
            try:
                response = await client.get_object(
                    Bucket=self.bucket,
                    Key=object_key,
                    Range=f"bytes=0-{n - 1}",
                )
                async with response["Body"] as stream:
                    return await stream.read()
            except ClientError as e:
                logger.error("s3_read_first_bytes_error", error_code=e.response["Error"]["Code"])
                return b""

    async def delete_object(self, object_key: str) -> None:
        """Delete an object from the bucket (idempotent — no error if missing)."""
        async with self._client() as client:
            try:
                await client.delete_object(Bucket=self.bucket, Key=object_key)
            except ClientError:
                logger.warning("s3_delete_object_failed", object_key="[redacted]")

    def validate_mime_from_magic_bytes(self, data: bytes, declared_mime: str) -> bool:
        """Validate file magic bytes match declared MIME type.

        Returns True if magic bytes match, False if mismatch.
        HEIC: check 'ftyp' box at offset 4.
        WebP: RIFF header at 0, 'WEBP' at offset 8.
        """
        if not data or len(data) < 4:
            return False

        if declared_mime == "image/heic":
            # HEIC/HEIF: bytes 4-8 should be 'ftyp'
            return len(data) >= 8 and data[4:8] == b"ftyp"

        if declared_mime == "image/webp":
            # WebP: starts with RIFF and has WEBP at bytes 8-12
            return len(data) >= 12 and data[0:4] == b"RIFF" and data[8:12] == b"WEBP"

        sig = _MAGIC_SIGNATURES.get(declared_mime)
        if sig is None:
            return False
        magic_bytes, offset = sig
        return data[offset : offset + len(magic_bytes)] == magic_bytes

    def generate_object_key(self, user_id: str, media_id: str, suffix: str = "original") -> str:
        """Generate non-predictable, non-enumerable S3 object key.

        Format: {user_id}/{media_id}/{random_uuid}_{suffix}
        The random component prevents object key enumeration even if
        user_id and media_id are known.
        """
        return f"{user_id}/{media_id}/{uuid.uuid4().hex}_{suffix}"
