# BillTracker Backend P1 — Implementation Plan

> **Mục tiêu:** Triển khai đầy đủ backend P1 "Cloud Backup & Sync" theo `PRD_BACKEND.md`.  
> **Nguyên tắc:** Modular monolith, local-first, opt-in sync, không deploy cloud, không production secrets.

---

## Dependency Order & Milestones

```
M0: Foundation         → M1: DB Schema & Auth → M2: Sync Core
→ M3: Media API        → M4: Privacy & Account → M5: Tests & Hardening
→ M6: Docs & README
```

---

## M0 — Project Foundation

### Task M0.1: Project scaffold & tooling
- [ ] Tạo `backend/pyproject.toml` (dependencies, dev tools, ruff, mypy config)
- [ ] Tạo `backend/Dockerfile` (multi-stage: builder + runtime, non-root user)
- [ ] Tạo `backend/docker-compose.yml` (api, postgres:16, minio)
- [ ] Tạo `backend/.env.example` (không có secret thật, có comment hướng dẫn)
- [ ] Tạo `backend/Makefile` (targets: up, down, migrate, seed, test, lint, openapi)
- [ ] Tạo `backend/app/__init__.py`, `backend/app/main.py` (FastAPI app factory)
- [ ] Tạo `backend/app/config.py` (pydantic-settings, tất cả config từ env vars)

**Files tạo:**
```
backend/pyproject.toml
backend/Dockerfile
backend/docker-compose.yml
backend/.env.example
backend/Makefile
backend/app/__init__.py
backend/app/main.py
backend/app/config.py
```

**Verify:** `docker compose up --build` → API responds `GET /health` → HTTP 200

---

### Task M0.2: Core infrastructure
- [ ] `backend/app/db/base.py` — SQLAlchemy async engine + Base declarative
- [ ] `backend/app/db/session.py` — async_sessionmaker, get_db dependency
- [ ] `backend/app/core/errors.py` — AppError, ErrorCode enum, exception handlers
- [ ] `backend/app/core/logging.py` — structlog config, redaction filter (tokens, URLs, amounts)
- [ ] `backend/app/middleware.py` — request_id middleware, timing middleware
- [ ] `backend/app/dependencies.py` — get_current_user, get_device, get_storage
- [ ] `backend/app/core/security.py` — JWT sign/verify (RS256), token generation

**Files tạo:**
```
backend/app/db/base.py
backend/app/db/session.py
backend/app/core/errors.py
backend/app/core/logging.py
backend/app/core/security.py
backend/app/middleware.py
backend/app/dependencies.py
```

---

## M1 — PostgreSQL Schema & Auth

### Task M1.1: Alembic setup & base migration
- [ ] Tạo `backend/migrations/alembic.ini`
- [ ] Tạo `backend/migrations/env.py` (async engine, import all models)
- [ ] Tạo migration `0001_initial_schema.py`:
  - `users` table
  - `auth_identities` table (unique: provider + provider_subject)
  - `devices` table
  - `refresh_tokens` table (hash stored, rotation family)
  - `sync_idempotency` table
  - `change_log` table (BIGSERIAL sequence, index: user_id + sequence)
  - `export_jobs` table
  - `account_deletion_requests` table

**Files tạo:**
```
backend/migrations/alembic.ini
backend/migrations/env.py
backend/migrations/script.py.mako
backend/migrations/versions/0001_initial_schema.py
```

**Verify:** `alembic upgrade head` trên DB trống → không lỗi → `alembic downgrade -1` → không lỗi

---

### Task M1.2: Domain tables migration
- [ ] Tạo migration `0002_domain_tables.py`:
  - `categories` (user_id nullable for system; revision, updated_at, deleted_at)
  - `transactions` (user_id, revision, updated_at, deleted_at)
  - `budgets` (user_id, revision, updated_at, deleted_at)
  - `media` (user_id, object_key NOT public URL, state enum, revision, updated_at, deleted_at)
  - `receipt_extractions` (user_id, revision, updated_at, deleted_at)
  - `receipt_line_items` (user_id, revision, updated_at, deleted_at)
  - `ai_inferences` (user_id, revision, updated_at, deleted_at)
- [ ] Indexes:
  - `(user_id, sequence)` on change_log — BTREE
  - `(user_id, deleted_at)` on transactions — partial index (WHERE deleted_at IS NULL)
  - `(user_id, updated_at)` on all sync tables — for pull ordering
  - `(user_id, operation_id)` on sync_idempotency — UNIQUE
  - `(provider, provider_subject)` on auth_identities — UNIQUE

**Files tạo:**
```
backend/migrations/versions/0002_domain_tables.py
```

---

### Task M1.3: SQLAlchemy ORM models
- [ ] `backend/app/db/models/user.py` — User, AuthIdentity, Device, RefreshToken
- [ ] `backend/app/db/models/transaction.py` — Transaction
- [ ] `backend/app/db/models/category.py` — Category
- [ ] `backend/app/db/models/budget.py` — Budget
- [ ] `backend/app/db/models/media.py` — Media
- [ ] `backend/app/db/models/receipt.py` — ReceiptExtraction, ReceiptLineItem
- [ ] `backend/app/db/models/ai.py` — AIInference
- [ ] `backend/app/db/models/sync.py` — ChangeLog, SyncIdempotency
- [ ] `backend/app/db/models/account.py` — ExportJob, AccountDeletionRequest
- [ ] `backend/app/db/models/__init__.py` — export all

**Files tạo:**
```
backend/app/db/models/user.py
backend/app/db/models/transaction.py
backend/app/db/models/category.py
backend/app/db/models/budget.py
backend/app/db/models/media.py
backend/app/db/models/receipt.py
backend/app/db/models/ai.py
backend/app/db/models/sync.py
backend/app/db/models/account.py
backend/app/db/models/__init__.py
```

---

### Task M1.4: Auth module
- [ ] `backend/app/modules/auth/oidc.py`:
  - OIDC verifier interface (Protocol)
  - Google OIDC verifier (fetch jwks_uri, verify id_token)
  - Apple OIDC verifier (fetch Apple public keys, verify id_token)
  - DevMock OIDC verifier (dev-only, configurable via env `DEV_AUTH_ENABLED=true`)
- [ ] `backend/app/modules/auth/service.py`:
  - `exchange_token()` — verify IdP token → find/create user → issue access+refresh tokens
  - `refresh_token()` — verify RT hash, detect reuse, rotate
  - `revoke_device()` — invalidate all RTs for device
- [ ] `backend/app/modules/auth/schemas.py` — Pydantic request/response models
- [ ] `backend/app/modules/auth/router.py`:
  - `POST /v1/auth/exchange`
  - `POST /v1/auth/refresh`
  - `POST /v1/devices` (register device)
  - `GET /v1/devices` (list active devices)
  - `DELETE /v1/devices/{device_id}` (revoke)

**Files tạo:**
```
backend/app/modules/auth/oidc.py
backend/app/modules/auth/service.py
backend/app/modules/auth/schemas.py
backend/app/modules/auth/router.py
backend/app/modules/auth/__init__.py
```

**Verify:** Unit test cho token rotation, reuse detection, device revoke

---

## M2 — Sync Core

### Task M2.1: Sync service — push
- [ ] `backend/app/modules/sync/conflict.py`:
  - `resolve_conflict()` — LWW policy + tombstone wins rule
  - Tombstone detection: `is_tombstone_conflict(entity, operation)`
- [ ] `backend/app/modules/sync/service.py` — `push_operations()`:
  - Idempotency check (sync_idempotency table)
  - Per-operation DB transaction: upsert entity + insert change_log
  - Conflict detection (revision mismatch)
  - Tombstone wins over old upsert
  - Return acknowledged + conflicts + serverCursor
- [ ] `backend/app/modules/sync/schemas.py`:
  - `PushRequest`, `PushResponse`
  - `PullResponse`, `BootstrapResponse`
  - `SyncOperation`, `AcknowledgedOp`, `ConflictEntry`
  - `SyncChange` (pull item)
- [ ] `backend/app/modules/sync/router.py`:
  - `POST /v1/sync/push`
  - `GET /v1/sync/pull`
  - `GET /v1/sync/bootstrap`

**Files tạo:**
```
backend/app/modules/sync/conflict.py
backend/app/modules/sync/service.py
backend/app/modules/sync/schemas.py
backend/app/modules/sync/router.py
backend/app/modules/sync/__init__.py
```

**Verify:**
- Push 100 ops — all acked
- Push same op_id twice — idempotent response
- Push stale revision — 409 conflict
- Push delete after update — tombstone wins
- Pull cursor pagination — correct sequence tracking
- Bootstrap — returns all entities for new device

---

### Task M2.2: Entity payload serialization
- [ ] `backend/app/modules/sync/entity_serializer.py`:
  - Map entity_type → ORM model
  - `serialize_entity(entity_type, row)` → dict (no internal fields like object_key)
  - `deserialize_payload(entity_type, payload, user_id)` → ORM model kwargs
  - Validate user_id ownership before any read/write (IDOR prevention)

---

## M3 — Media API

### Task M3.1: S3-compatible storage client
- [ ] `backend/app/modules/media/storage.py`:
  - `StorageClient` class wrapping aiobotocore
  - `generate_upload_presigned_url(key, content_type, expires=900)` — 15 min
  - `generate_download_presigned_url(key, expires=300)` — 5 min
  - `verify_object_exists(key)` → bool + size + etag
  - `get_object_head(key)` → metadata (size, content-type)
  - `delete_object(key)` async
  - `read_magic_bytes(key, n=16)` → bytes (for MIME validation)
  - Config từ env: `S3_ENDPOINT`, `S3_BUCKET`, `S3_ACCESS_KEY`, `S3_SECRET_KEY` (never hardcoded)

**Files tạo:**
```
backend/app/modules/media/storage.py
```

---

### Task M3.2: Media service & validation
- [ ] `backend/app/modules/media/service.py`:
  - `create_upload_intent()`:
    - Validate metadata (MIME allowlist, size limit, quota check)
    - Generate unique `object_key` (NOT predictable, NOT user-visible path)
    - Create `media` row (state=`pending_upload`)
    - Return pre-signed PUT URL (never logged)
  - `complete_upload()`:
    - Verify object exists in S3 (HEAD request)
    - Validate magic bytes (JPEG: FFD8FF, PNG: 89504E47, HEIC: detect by ftyp)
    - Validate actual size ≤ limit
    - Validate content hash matches declared
    - Update media state → `ready`
    - Insert change_log entry
  - `get_download_intent()`:
    - Verify media ownership (WHERE user_id = current_user.id AND id = media_id)
    - Generate pre-signed GET URL (never logged)
  - `soft_delete_media()`:
    - Set deleted_at, state=`deleted`
    - Queue object deletion job (P1: immediate async delete)

- [ ] `backend/app/modules/media/schemas.py`
- [ ] `backend/app/modules/media/router.py`:
  - `POST /v1/media/upload-intents`
  - `POST /v1/media/{media_id}/complete`
  - `GET /v1/media/{media_id}/download-intent`
  - `DELETE /v1/media/{media_id}`

**Files tạo:**
```
backend/app/modules/media/service.py
backend/app/modules/media/schemas.py
backend/app/modules/media/router.py
backend/app/modules/media/__init__.py
```

**Verify:**
- Upload intent → pre-signed URL → PUT binary → complete → download intent
- Wrong hash → complete rejected
- Wrong MIME magic bytes → complete rejected
- Deleted media → download-intent → 404
- Other user's media → 403

---

## M4 — Privacy & Account Lifecycle

### Task M4.1: Data export
- [ ] `backend/app/modules/privacy/service.py` — `request_export()`:
  - Create `export_jobs` row (status=`queued`)
  - Async task: fetch all user data, serialize to JSON, compress, upload to S3 with user-scoped key
  - Generate pre-signed download URL (expires 24h)
  - Update job status → `ready`
  - P1: synchronous export (no queue needed); P2: background worker
- [ ] `GET /v1/me/export` — initiate + return job status + download URL when ready

---

### Task M4.2: Account deletion
- [ ] `backend/app/modules/privacy/service.py` — `request_account_deletion()`:
  - Require re-auth proof (recent `auth_time` claim in token, max 5 min old)
  - Create `account_deletion_requests` row
  - Immediately: revoke ALL refresh tokens for user
  - Immediately: revoke all device sessions
  - Immediately: mark pre-signed URLs invalid (set `deleted_at` on user → middleware rejects)
  - Schedule: set `users.deletion_scheduled_at = now() + 30 days`
  - Background job: delete all media objects from S3, delete metadata rows, delete user row
- [ ] `DELETE /v1/me` — endpoint

**Files tạo:**
```
backend/app/modules/privacy/service.py
backend/app/modules/privacy/schemas.py
backend/app/modules/privacy/router.py
backend/app/modules/privacy/__init__.py
```

---

### Task M4.3: OCR P2 placeholder
- [ ] `backend/app/modules/ocr/__init__.py`
- [ ] `backend/app/modules/ocr/interface.py` — Protocol classes, enums
- [ ] `backend/app/modules/ocr/router.py` — all endpoints return `501 Not Implemented`

**Files tạo:**
```
backend/app/modules/ocr/__init__.py
backend/app/modules/ocr/interface.py
backend/app/modules/ocr/router.py
```

---

## M5 — Tests & Hardening

### Task M5.1: Test infrastructure
- [ ] `backend/tests/conftest.py`:
  - `async_client` fixture (httpx AsyncClient with test app)
  - `db_session` fixture (test DB with rollback)
  - `minio_client` fixture (test MinIO or mock)
  - `auth_headers` fixture (dev_mock token for test user)
  - `two_users` fixture (two distinct test users for IDOR tests)

**Files tạo:**
```
backend/tests/conftest.py
backend/tests/__init__.py
```

---

### Task M5.2: Unit tests
- [ ] `tests/unit/test_security.py` — JWT sign/verify, token rotation, reuse detection
- [ ] `tests/unit/test_conflict.py` — LWW rule, tombstone wins, idempotency
- [ ] `tests/unit/test_entity_serializer.py` — payload serialize/deserialize, user_id injection
- [ ] `tests/unit/test_media_validation.py` — magic bytes, MIME, size, quota
- [ ] `tests/unit/test_logging_redaction.py` — assert tokens/URLs not in log output

**Files tạo:**
```
backend/tests/unit/test_security.py
backend/tests/unit/test_conflict.py
backend/tests/unit/test_entity_serializer.py
backend/tests/unit/test_media_validation.py
backend/tests/unit/test_logging_redaction.py
```

---

### Task M5.3: Integration tests (security-focused)
- [ ] `tests/integration/test_idor.py`:
  - User A cannot read/modify User B's transactions, budgets, categories, media
  - User A cannot push operations with User B's entity_ids
  - User A cannot get download-intent for User B's media
- [ ] `tests/integration/test_sync_push.py`:
  - Push 1 op → ack
  - Push same op_id → idempotent (no duplicate)
  - Push stale revision → 409 conflict with server payload
  - Push upsert after tombstone → 409 tombstone conflict
  - Push delete → tombstone created
  - Push 101 ops → 422 validation error (max 100)
- [ ] `tests/integration/test_sync_pull.py`:
  - Pull with cursor → returns changes since cursor
  - Pull with no cursor → error (no infinite dump)
  - Pull after tombstone → tombstone included
  - Pull → hasMore pagination
- [ ] `tests/integration/test_sync_bootstrap.py`:
  - New device: bootstrap → all entities
  - Bootstrap cursor → subsequent pull works
- [ ] `tests/integration/test_sync_two_devices.py`:
  - Device A offline push → Device B sees via pull
  - Device A and B push same entity → conflict resolution
  - Tombstone doesn't resurrect
- [ ] `tests/integration/test_media.py`:
  - Upload intent → PUT (mock S3) → complete (hash mismatch fails) → download-intent
  - Delete → download-intent 404
  - Wrong MIME magic bytes → complete 422
- [ ] `tests/integration/test_auth.py`:
  - Token refresh → old token invalid
  - Refresh token reuse → entire family revoked
  - Device revoke → token invalid
- [ ] `tests/integration/test_privacy.py`:
  - Export → job created → download URL
  - Account delete (no recent auth) → 401
  - Account delete (valid re-auth) → tokens revoked immediately

**Files tạo:**
```
backend/tests/integration/test_idor.py
backend/tests/integration/test_sync_push.py
backend/tests/integration/test_sync_pull.py
backend/tests/integration/test_sync_bootstrap.py
backend/tests/integration/test_sync_two_devices.py
backend/tests/integration/test_media.py
backend/tests/integration/test_auth.py
backend/tests/integration/test_privacy.py
```

---

### Task M5.4: Seed data & health
- [ ] `backend/app/modules/health/router.py` — `/health`, `/health/ready`, `/health/version`
- [ ] `backend/scripts/seed_dev.py`:
  - 2 dev users với mock identities
  - 10 system categories
  - Sample transactions, budgets (no real financial amounts)
  - Idempotent (re-run safe)

**Files tạo:**
```
backend/app/modules/health/router.py
backend/app/modules/health/__init__.py
backend/scripts/seed_dev.py
```

---

## M6 — Documentation & README

### Task M6.1: README
- [ ] `backend/README.md`:
  - Prerequisites (Docker, Python 3.12, make)
  - Quick start (`make up`, `make migrate`, `make seed`)
  - Environment variables (table từ `.env.example`)
  - Running tests (`make test`)
  - API docs URL (`http://localhost:8000/docs`)
  - P1 limitations (no Cloud OCR, no realtime WebSocket, no push notifications)
  - P2 OCR placeholder note

**Files tạo:**
```
backend/README.md
```

---

### Task M6.2: OpenAPI export
- [ ] `backend/scripts/export_openapi.py` — export `openapi.json` to `backend/docs/`
- [ ] Verify all endpoints documented với example request/response

**Files tạo:**
```
backend/scripts/export_openapi.py
backend/docs/openapi.json (generated)
```

---

## Execution Order (strict dependency)

```
M0.1 → M0.2 → M1.1 → M1.2 → M1.3 → M1.4
                                          ↓
                                       M2.1 → M2.2
                                                ↓
                                             M3.1 → M3.2
                                                      ↓
                                                   M4.1 → M4.2 → M4.3
                                                                    ↓
                                                              M5.1 → M5.2 → M5.3 → M5.4
                                                                                      ↓
                                                                                    M6.1 → M6.2
```

---

## Definition of Done per Milestone

| Milestone | DoD |
|---|---|
| M0 | `docker compose up` → API starts, `/health` → 200 |
| M1 | `alembic upgrade head` → OK, `alembic downgrade base` → OK, auth exchange + token rotation tests pass |
| M2 | Push/pull/bootstrap tests pass; idempotency, tombstone, conflict tests all green |
| M3 | Upload-complete-download flow tested; IDOR test for media pass; wrong magic bytes rejected |
| M4 | Export job creates downloadable file; delete revokes tokens immediately; OCR endpoints return 501 |
| M5 | `pytest -x` all green; no IDOR failures; two-device sync scenario passes |
| M6 | `README.md` reviewed; `make openapi` generates valid JSON; no dead-link in docs |

---

## What's Out of Scope (P1 Boundaries)

| Feature | Status | Notes |
|---|---|---|
| Cloud OCR (Google Vision, Azure) | P2 | Interface placeholder in `ocr/interface.py` |
| Background job queue (arq/celery) | P2 | P1 uses asyncio tasks or DB polling |
| WebSocket realtime sync | P3 | Polling-based sync is sufficient |
| Push notifications | P3 | No APNs/FCM integration |
| Multi-user shared budgets | Never (P1) | Single-user scope only |
| Bank account integration | Never | Out of product scope |
| Production cloud deployment | Explicitly excluded | Local Docker only |
| Storage plans / billing | P3 | Fixed quota P1 |
| Field-level merge conflict | P2 | P1 uses whole-record LWW |
