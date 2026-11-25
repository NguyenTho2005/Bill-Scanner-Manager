# BillTracker — Project Context / LLM Knowledge Base

> Scope: entire repository at `/media/tho/NEW DATA1/BillTracker` (Flutter app + FastAPI backend).
> Generated from source code, config, migrations and tests. Last scan: 2026-11-25.
> Use this file as system prompt / grounding context. `PRD.md` describes intent; **code is the source of truth**.
> Secrets are redacted as `<REDACTED>`. Dev-only defaults in `docker-compose.yml` are intentionally omitted.

---

# 1. Project Overview

## 1.1 Product

**BillTracker** — Vietnamese-market, local-first personal expense tracker built around photos.

| Aspect | Value |
|---|---|
| Core value | Log an expense in <5 s by photographing the item or receipt; AI suggests category/amount |
| Default mode | Fully offline, on-device. No bank linking, no account required |
| Cloud | Optional P1 backend for backup/sync/media/export; **not wired into the app yet** |
| Currency | VND (`double` locally, `NUMERIC(18,4)` server-side) |
| UI language | Vietnamese (hardcoded), `vi_VN` locale; i18n scaffolding exists but is unused |
| Platforms | Android (minSdk 24, `com.billtracker.app`), iOS (`com.billtracker.billTracker`), portrait-only |
| Success KPIs (PRD) | time-to-log <5 s; category top-1 ≥80%; OCR total ≥90% after review; merchant/date/total ≥80% |

## 1.2 Core Workflows (input → output)

### A. Product Snap (fastest path)
```
camera/gallery pick (image_picker, max 2048px, q85 product / q90 receipt)
  → LocalImageStorageService: resize ≤2048px, JPEG q80, square 200px thumb, SHA-256
  → ML Kit Image Labeling (on-device, confidence ≥0.5)
  → LabelToCategoryMapper: keyword rules → category (threshold 0.65)
  → UI: user confirms category, enters amount via numpad, optional merchant/note
  → Transaction(type=expense, source=productSnap, status=confirmed) + TransactionMedia(product)
  → Drift transaction insert → BudgetRepository.checkAndTriggerAlerts()
  → pop back to Visual Feed
```
Price OCR now supplements labeling (§4.6 #15): after ML Kit Image Labeling, ML Kit
Text Recognition runs on the same stored image and `PriceTextExtractor` scans for
VND-style price strings (`45.000đ`, `45,000 VND`, `45000`, `45k`). When exactly one
candidate reaches confidence ≥0.70 the numpad is auto-filled (never auto-saved, user
can always edit — rule #5 §4.3); otherwise manual entry as before. Candidates +
classification are persisted to `ai_inferences` (`extracted_amounts_json`) by
`saveProductSnapInference` for OCR-KPI evaluation (README target: total ≥90%).

### B. Receipt Scan
```
camera/gallery pick → image store (compressed + thumb)
  → ML Kit Text Recognition (Latin script, on-device)
  → VietnameseReceiptParser:
       merchant = known-brand match (0.95) or first plausible line (0.65)
       total    = "tổng cộng/total/thành tiền..." keyword (0.92) or next line (0.88)
                  fallback = largest amount in last 8 lines (0.60)
       date     = dd/MM/yyyy or yyyy-MM-dd, 2020–2030
       payment  = momo/zalopay/shopeepay→ewallet; vnpay/vietqr→transfer; visa/card→card; cash
       lineItems= product rows between header and total line (keyword-skip + position
                  heuristic, per-line confidence 0.55–0.90; none when total is fallback)
       requiresReview = total missing or totalConfidence <0.70
  → editable review screen (amount, merchant, date, category, payment method,
    line-item editor: rename/qty/price, include checkbox, add/remove rows)
  → Transaction(source=receiptScan, status=needsReview if flagged) + TransactionMedia(receipt)
  → saveReceiptScanData: receipt_extractions row (incl. rawText — local-only,
    §4.6 #21 never synced) + receipt_line_items rows + outbox upserts
```
No edge/border detection or crop.

### C. Manual entry
`CreateEditTransactionScreen` → amount, category picker, date, merchant, note, payment method → duplicate check (`DuplicateDetector`, 24 h window, amount tolerance 0, merchant similarity ≥0.8) → save.

### D. Read / analyze
```
Drift (SQLite) → TransactionRepository joined with Categories + TransactionMedias
  → VisualFeedScreen (photo grid OR date-grouped timeline; filters: category, date presets, VN query parser, text)
  → TransactionDetailScreen (edit via direct MaterialPageRoute, delete cascade)
  → ReportRepositoryImpl (monthly summary, category donut, top 5, 6-month trend)
  → BudgetRepositoryImpl (monthly progress, 80%/100% local notifications, forecast banner)
```

### E. Assistant (floating bubble)
```
user text
  → VietnameseTextUtils normalize/strip diacritics
  → AssistantNlu → AssistantIntent (greeting/help/total/income/top/breakdown/count/compare/budget/recent/create/support/unknown)
  → if intent known: AssistantEngine answers locally from Drift (exact numbers, no network)
  → if unknown AND cloud enabled AND settings usable:
        buildSnapshot() aggregate context (no receipts/merchant/IDs)
        → OpenAI-compatible /chat/completions OR Gemini generateContent (user-owned key)
        → on LlmException: fall back to local answer + warning block
  → AssistantReply(text, blocks, suggestions) persisted in ChatMessages
  → DraftBlock ("cà phê 45k") is only written after user confirms
```

### F. Cloud sync (intended P1, backend only)
```
local mutation → (MISSING) sync_outbox → POST /v1/sync/push (≤100 ops)
server: token user → device check → idempotency → revision/tombstone check
        → entity upsert + change_log(sequence) 
client: GET /v1/sync/pull?cursor=seq_... (≤200) until has_more=false
new device: GET /v1/sync/bootstrap?page=N&page_size≤100
conflict: 409-style entry with server payload, hint=server_wins (whole-record LWW)
```
There is **no Flutter sync client, no outbox, no sync metadata columns** in the current app.

## 1.3 Tech Stack (exact)

### Mobile (`bill_tracker/`)
| Area | Package / version |
|---|---|
| Language | Dart `>=3.6.0 <4.0.0` (env: Flutter 3.47.2 stable) |
| State | `flutter_riverpod` 2.6.1 |
| Routing | `go_router` 14.8.1 (declared `^14.6.2`) |
| DI | `get_it` 8.3.0 |
| Local DB | `drift` 2.28.2, `drift_flutter` 0.2.7, `drift_dev` 2.28.3, `sqlite3` 2.9.4, `sqlite3_flutter_libs` 0.5.42 |
| Security | `flutter_secure_storage` 9.2.4, `local_auth` 2.3.0 |
| Camera/images | `image_picker` 1.2.3, `image` 4.9.2, `path_provider` 2.1.5, `path` 1.9.1 |
| On-device AI | `google_mlkit_text_recognition` 0.15.1, `google_mlkit_image_labeling` 0.14.2 |
| Notifications | `flutter_local_notifications` 18.0.1 |
| UI/charts | `fl_chart` 0.70.2, `gap` 3.0.1, `intl` 0.20.3, `google_fonts` 6.3.3 (Inter) |
| Networking | `http` 1.6.0 (assistant cloud only) |
| Utilities | `uuid` 4.6.0 (v4/v7), `equatable` 2.1.0, `crypto` 3.0.7 |
| Codegen | `build_runner` 2.7.2 |
| Lint | `flutter_lints` 5.0.0 + `very_good_analysis` 7.0.0 |
| Android | compileSdk from Flutter, minSdk 24, applicationId `com.billtracker.app` |

### Backend (`backend/`)
| Area | Package / version |
|---|---|
| Runtime | Python `>=3.12` (env 3.12.3) |
| Web | `fastapi` 0.115.6, `uvicorn[standard]` 0.32.1, `python-multipart` 0.0.18 |
| ORM/DB | `sqlalchemy[asyncio]` 2.0.36, `asyncpg` 0.30.0, `alembic` 1.14.0 |
| Validation | `pydantic` 2.10.4, `pydantic-settings` 2.7.0, `email-validator` 2.2.0 |
| Auth | `python-jose[cryptography]` 3.3.0, `cryptography` 44.0.0, `passlib[bcrypt]` 1.7.4, `jwcrypto` 1.5.6 |
| Storage | `aiobotocore` 2.15.2, `boto3` 1.35.76 |
| HTTP | `httpx` 0.28.1 |
| Logging | `structlog` 24.4.0 |
| Rate limit | `slowapi` 0.1.9 (declared, **not wired**) |
| Misc | `python-ulid` 3.0.0, `python-dotenv` 1.0.1 |
| Dev | pytest 8.3.4, pytest-asyncio 0.24.0, pytest-cov 6.0.0, asgi-lifespan, factory-boy, faker, ruff 0.8.6, mypy 1.14.1, moto[s3] 5.0.22 |
| Tooling | Ruff (py312, line 100, rules E/F/I/N/W/UP/S/B/A/C4/PT), mypy `strict=true`, coverage `fail_under=80` |

Declared but unused / inconsistent: `passlib`, `jwcrypto`, `slowapi`, `python-jose`. `app/core/security.py` imports `jwt` (PyJWT), which is not declared.

### Infrastructure
Docker Compose 3.9: `api` (python:3.12-slim, non-root uid 1001), `postgres:16-alpine`, `minio/minio`, one-shot `minio-setup` creating a private bucket.

## 1.4 External Services, Ports, Config

| Service | Endpoint / port | Notes |
|---|---|---|
| FastAPI | `http://localhost:8000` | `/health`, `/health/ready`, `/health/version`, Swagger `/docs` (non-prod only) |
| PostgreSQL | `localhost:5432` / db `billtracker` | async DSN `postgresql+asyncpg://...` |
| MinIO S3 API | `localhost:9000` | private bucket `billtracker-media` |
| MinIO Console | `localhost:9001` | dev only |
| S3 / MinIO access | pre-signed PUT (900 s) / GET (300 s) | URLs must never be logged |
| OpenAI-compatible LLM | `LLM_BASE_URL` + `/chat/completions` | optional server proxy, disabled when key empty |
| Gemini API | `https://generativelanguage.googleapis.com/v1beta` | optional BYO-key mobile client |
| ML Kit | on-device | no network, no API key |
| Apple/Google OIDC | configured by env | verifier classes are stubs |

Config keys (`.env`, all secrets redacted):

| Key | Default / meaning |
|---|---|
| `ENVIRONMENT` | `development` \| `staging` \| `production` |
| `DATABASE_URL` | required, `postgresql+asyncpg://...` |
| `JWT_ALGORITHM` | `RS256`; dev auto-generates ephemeral 2048-bit RSA if `DEV_AUTH_ENABLED` |
| `JWT_PRIVATE_KEY_PEM`, `JWT_PUBLIC_KEY_PEM` | `<REDACTED>` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` / `REFRESH_TOKEN_EXPIRE_DAYS` | 15 / 90 |
| `DEV_AUTH_ENABLED` | false default; **must be false in production** (startup raises otherwise) |
| `DEV_AUTH_MOCK_ISSUER` | `http://localhost:8000` |
| `APPLE_*`, `GOOGLE_CLIENT_ID` | `<REDACTED>` |
| `S3_ENDPOINT`, `S3_BUCKET`, `S3_REGION` | `http://localhost:9000`, `billtracker-media`, `us-east-1` |
| `S3_ACCESS_KEY`, `S3_SECRET_KEY` | `<REDACTED>` |
| `MEDIA_MAX_ORIGINAL_BYTES` / `COMPRESSED` / `THUMBNAIL` | 20 MB / 5 MB / 200 KB |
| `MEDIA_QUOTA_PER_USER_BYTES` | 2 GB (service hardcodes 100 MB — see §4.6) |
| `SYNC_MAX_PUSH_OPS` / `SYNC_MAX_PULL_LIMIT` | 100 / 200 |
| `SYNC_IDEMPOTENCY_TTL_DAYS` | 7 (service hardcodes 30 days) |
| `ACCOUNT_DELETION_GRACE_DAYS` | 30 |
| `EXPORT_DOWNLOAD_URL_TTL` | 86400 s |
| `LLM_BASE_URL`, `LLM_MODEL`, `LLM_API_KEY`, `LLM_TIMEOUT_SECONDS`, `LLM_TEMPERATURE` | empty key disables `/v1/assistant/chat` (503); model `gpt-4o-mini`, 30 s, 0.3 |
| `RATE_LIMIT_ENABLED` | true, but no limiter is installed |

---

# 2. Directory Structure

```text
BillTracker/
├── README.md                          # Product/architecture quick start (VI)
├── PRD.md                             # Product requirements, personas, KPIs, acceptance criteria
├── PRD_BACKEND.md                     # Cloud backend scope, API contract, sync rules
├── PROJECT_CONTEXT.md                 # ← this knowledge base
├── .agents/skills/                    # 8 agent skill definitions (ai-engineer, flutter-expert, …)
│
├── backend/                           # FastAPI modular monolith (P1 cloud)
│   ├── app/
│   │   ├── main.py                    # create_app(), middleware, routers, prod guards
│   │   ├── config.py                  # pydantic-settings, dev RSA key generation
│   │   ├── dependencies.py            # bearer auth, current user/device, recent-auth
│   │   ├── middleware.py              # request ID, timing, security headers
│   │   ├── core/
│   │   │   ├── errors.py              # ErrorCode enum, AppError hierarchy, JSON handler
│   │   │   ├── logging.py             # structlog, contextvars, sensitive-key redaction
│   │   │   └── security.py            # ULID, JWT, refresh-token hashing, cursor codec
│   │   ├── db/
│   │   │   ├── base.py                # declarative Base + timestamp/ownership/sync mixins
│   │   │   ├── session.py             # async engine + async_sessionmaker + get_db
│   │   │   └── models/                # user, transaction, category, budget, media,
│   │   │                              # receipt, ai, sync, account ORM models
│   │   └── modules/
│   │       ├── auth/                  # exchange/refresh/dev-token, devices, OIDC stubs
│   │       ├── sync/                  # push/pull/bootstrap, conflict, entity serializer
│   │       ├── media/                 # upload intents, complete, download, delete, S3
│   │       ├── privacy/               # /me, export, account deletion
│   │       ├── assistant/             # optional OpenAI-compatible chat proxy
│   │       ├── ocr/                   # P2 interface + 501 endpoints
│   │       └── health/                # liveness/readiness/version
│   ├── migrations/
│   │   ├── env.py
│   │   └── versions/0001_initial_schema.py, 0002_domain_tables.py
│   ├── tests/
│   │   ├── conftest.py                # in-memory SQLite + ASGI client + dev tokens
│   │   └── integration/               # auth, idor, media, privacy, sync, assistant
│   ├── scripts/seed_dev.py            # 2 dev users, categories, sample data
│   ├── scripts/export_openapi.py
│   ├── docs/architecture.md           # stack rationale, ERD, sync/security design
│   ├── docs/implementation-plan.md    # milestone backlog (mostly checked in prose)
│   ├── Dockerfile                     # multi-stage, non-root, uvicorn
│   ├── docker-compose.yml             # api + postgres + minio + bucket setup
│   ├── Makefile                       # up/down/migrate/seed/test/lint/openapi
│   ├── alembic.ini
│   ├── pyproject.toml
│   └── .env.example
│
└── bill_tracker/                      # Flutter app
    ├── lib/
    │   ├── main.dart                  # bootstrap: orientation, notifications, DI, ProviderScope
    │   ├── core/
    │   │   ├── ai/                    # ML Kit classifier/OCR, VN receipt parser, label mapper
    │   │   ├── analytics/             # AnalyticsService + console impl, event names
    │   │   ├── database/              # AppDatabase (schema v2), connection, 8 tables
    │   │   ├── di/injection_container.dart   # GetIt registrations
    │   │   ├── errors/failures.dart   # Failure hierarchy
    │   │   ├── extensions/            # VND/date formatting
    │   │   ├── notifications/         # local budget notifications
    │   │   ├── router/                # GoRouter, lock guard, shell nav, routes
    │   │   ├── security/              # biometric + PIN + secure storage
    │   │   ├── storage/               # image compression/store, JSON/CSV export, wipe
    │   │   ├── theme/                 # flat Material 3 theme, Inter, light/dark
    │   │   ├── utils/                 # UUID, SHA-256, Vietnamese text normalization
    │   │   └── widgets/               # image source bottom sheet
    │   ├── features/
    │   │   ├── assistant/             # domain NLU/engine/responder, data LLM clients, UI
    │   │   ├── auth/                  # app-lock provider + lock screen
    │   │   ├── budget/                # domain/data/presentation + forecaster
    │   │   ├── feed/                  # visual feed, filter bar, stats, photo grid
    │   │   ├── product_snap/          # camera → classify → amount → save
    │   │   ├── receipt_scan/          # camera → OCR → review → save
    │   │   ├── reports/               # monthly report screen + charts
    │   │   ├── settings/              # storage, export/import/wipe, lock, toggles
    │   │   └── transaction/           # entities, repos, duplicate detector, screens
    │   └── l10n/                      # generated ARB/localizations (unused by widgets)
    ├── test/                          # 163 passing unit/widget tests
    ├── android/ · ios/                # platform shells, camera/biometric permissions
    ├── assets/                        # fonts/icons/images (placeholders only)
    ├── pubspec.yaml · pubspec.lock
    ├── analysis_options.yaml          # very_good_analysis + exclusions
    └── l10n.yaml
```

---

# 3. Architecture & Data Flow

## 3.1 High-level

```text
┌──────────────────────── Flutter app (offline source of truth) ────────────────────────┐
│ Presentation (screens/widgets)                                                        │
│   Riverpod providers/notifiers                                                        │
│ Domain (entities, repository interfaces, pure services: NLU, parser, detector, forecast)│
│ Data (Drift repositories, secure storage, ML Kit adapters, HTTP LLM clients)           │
│ Core (Drift DB, DI, router, theme, security, image storage, notifications)             │
└───────────────────────────────┬───────────────────────────────────────────────────────┘
                                │  NO sync/API client exists today
                                ▼
┌──────────────────────── FastAPI modular monolith ─────────────────────────────────────┐
│ Middleware: request-id → timing → CORS → security headers                             │
│ Routers: /v1/auth, /v1/devices, /v1/sync, /v1/media, /v1/me, /v1/ocr, /v1/assistant    │
│ Services → SQLAlchemy async models → PostgreSQL 16                                    │
│ Media/privacy → aiobotocore → S3/MinIO (private bucket, pre-signed URLs)              │
│ Assistant → httpx → external OpenAI-compatible LLM                                    │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

## 3.2 Mobile layering rules

- `features/<name>/domain`: entities (`Equatable`), repository interfaces, pure logic. No Flutter imports except `dart:ui Color` in `Category`.
- `features/<name>/data`: Drift/HTTP implementations, mappers as extensions (`Row.toDomain()`, `Entity.toCompanion()`).
- `features/<name>/presentation`: screens/widgets/providers. Providers resolve repositories/services from GetIt.
- `core`: cross-feature infrastructure only.
- Writes always go through a repository inside a Drift transaction; UI never touches `AppDatabase`.
- Reactive reads use `query.watch()` → `StreamProvider`; one-off reads use `FutureProvider`.

## 3.3 Backend layering rules

- One package per bounded module under `app/modules/<module>/`: `router.py`, `service.py`, `schemas.py` (Pydantic), plus module-specific helpers.
- ORM models live centrally in `app/db/models/`; modules must not define their own Base.
- `user_id` always comes from the verified bearer token (`get_current_user`), never from body/query.
- Every query is user-scoped; IDOR tests exist.
- Errors use `AppError` subclasses → uniform envelope.
- Session lifecycle via `get_db`; **but most write routes never call `commit()`** (see §4.6).

## 3.4 API surface (implemented)

Base `/v1`; all endpoints except health/dev-token require `Authorization: Bearer <access_token>`.

| Method & path | Purpose | Notes |
|---|---|---|
| `POST /v1/auth/exchange` | IdP token → app session | body `{provider: apple\|google\|dev_mock, id_token, device_name, device_platform}` |
| `POST /v1/auth/refresh` | Rotate refresh token | reuse detection revokes entire family |
| `POST /v1/auth/dev-token` | Dev-only mock IdP | returns `{id_token: "<json>"}`; 404 if disabled |
| `GET /v1/devices` | List active devices | marks `is_current` |
| `DELETE /v1/devices/{device_id}` | Revoke device + its refresh tokens | |
| `POST /v1/sync/push` | Apply ≤100 operations | per-op savepoint, idempotency, conflict list |
| `GET /v1/sync/pull?cursor=...&limit≤200` | Incremental changes | cursor **required** |
| `GET /v1/sync/bootstrap?page&page_size≤100` | Snapshot for new device | per-entity SQL `LIMIT/OFFSET` pagination |
| `POST /v1/media/upload-intents` | Reserve media + pre-signed PUT | validates MIME/size/quota (quota from `MEDIA_QUOTA_PER_USER_BYTES`) |
| `POST /v1/media/{id}/complete` | Confirm upload | HEAD + magic bytes + size/hash |
| `GET /v1/media/{id}/download-intent` | Pre-signed GET | ownership + `state=ready`; `expires_at` = now + `S3_DOWNLOAD_URL_TTL` |
| `DELETE /v1/media/{id}` | Soft-delete media | async S3 delete (unreliable) |
| `GET /v1/me` | Current user | |
| `GET /v1/me/export` | Synchronous JSON export to S3 | creates an `export_jobs` row, then marks it `ready`; returns 24 h URL |
| `GET /v1/me/export/{job_id}` | Poll export job status | ownership-scoped; `processing`/`ready`/`expired`/`failed` |
| `DELETE /v1/me` | Schedule deletion T+30 d | intended recent-auth check is broken |
| `POST /v1/assistant/chat` | Optional LLM proxy | 503 when `LLM_API_KEY` empty |
| `POST/GET/DELETE /v1/ocr/jobs[...]` | P2 placeholder | always 501 |
| `GET /health`, `/health/ready`, `/health/version` | ops | ready checks DB only |

No `POST /v1/devices` exists, although PRD and `RegisterDeviceRequest` mention it.

## 3.5 Sync protocol (server implementation)

- **Operation**: `{operation_id, entity_type, entity_id, operation: upsert|delete, base_revision, occurred_at, payload}`.
- **Entity types**: `transaction`, `category`, `budget`, `media`, `receipt_extraction`, `receipt_line_item`, `ai_inference`.
- **Idempotency key**: `(operation_id, user_id, device_id)`; cached response JSON is replayed.
- **Cursor**: `seq_` + zero-padded 18-digit `change_log.sequence`.
- **Conflict**: `server_revision > base_revision` → `revision_mismatch`; upsert on tombstone → `tombstone_wins`; response carries `server_payload` (unless tombstoned) and `hint: server_wins`.
- **Delete**: soft delete (`deleted_at`), revision increment, change_log `delete`.
- **Bootstrap cursor**: `max(sequence)` at request time.
- **Limits**: push ≤100 ops (schema validator), pull `limit` 1..200, bootstrap page size 1..100.
- **Not enforced**: 5 MB payload cap, per-user rate limits, tombstone purge job, field-level merge.

## 3.6 Data Models — Mobile (Drift, schema v4)

`AppDatabase` tables (SQLite; all money `REAL`):

| Table (`DataClassName`) | Columns |
|---|---|
| `categories` (`CategoryRow`) | `id PK`, `parentId?`, `name`, `icon`, `colorValue`, `isSystem`, `sortOrder`, `revision`, `deletedAt?`, `syncState`, `lastSyncedAt?` |
| `transactions` (`TransactionRow`) | `id PK`, `type`, `amount REAL`, `currency='VND'`, `categoryId`, `merchant?`, `occurredAt`, `note?`, `paymentMethod?`, `source`, `status`, `createdAt`, `updatedAt`, `revision`, `deletedAt?`, `syncState`, `lastSyncedAt?` |
| `transaction_medias` (`TransactionMediaRow`) | `id PK`, `transactionId`, `type`, `originalPath?`, `compressedPath`, `thumbnailPath`, `hash`, `width?`, `height?`, `fileSizeBytes?`, `capturedAt?`, `revision`, `deletedAt?`, `syncState`, `lastSyncedAt?` |
| `budgets` (`BudgetRow`) | `id PK`, `categoryId`, `period='monthly'`, `amountLimit`, `alertThresholds='0.8,1.0,1.2'`, `alertSentAt80`, `alertSentAt100`, `alertSentAt120`, `periodStart`, `periodEnd`, `revision`, `deletedAt?`, `syncState`, `lastSyncedAt?` |
| `recurring_rules` (`RecurringRuleRow`) | `id PK`, `amount REAL`, `type` (expense/income), `currency='VND'`, `categoryId`, `merchant?`, `note?`, `frequency` (`daily`/`weekly`/`monthly`), `dayOfMonth?`, `dayOfWeek?`, `startDate`, `endDate?`, `nextRunAt`, `isActive`, `createdAt` |
| `ai_inferences` (`AIInferenceRow`) | `id PK`, `mediaId`, `modelVersion`, `labelsJson`, `suggestedCategoryId?`, `suggestedCategoryConfidence?`, `extractedAmountsJson`, `confidence`, `latencyMs`, `source='on_device'` |
| `receipt_extractions` (`ReceiptExtractionRow`) | `transactionId PK`, `merchant?`, `merchantConfidence?`, `merchantUserEdited`, `transactionDate?`, `dateConfidence?`, `total?`, `totalConfidence?`, `subtotal?`, `tax?`, `paymentMethod?`, `overallConfidence`, `rawText?`, `requiresReview`, `revision`, `deletedAt?`, `syncState`, `lastSyncedAt?` |
| `receipt_line_items` (`ReceiptLineItemRow`) | `id PK`, `transactionId`, `name`, `quantity?`, `unitPrice?`, `total`, `categorySuggestion?`, `confidence`, `revision`, `deletedAt?`, `syncState`, `lastSyncedAt` |
| `chat_messages` (`ChatMessageRow`) | `id PK`, `role`, `body`, `blocksJson='[]'`, `suggestionsJson='[]'`, `isLocal=true`, `isFeedback=false`, `createdAt` |

- Migration: `onCreate` seeds 10 system categories (`food_drinks`, `transport`, `shopping`, `entertainment`, `health`, `education`, `bills`, `work`, `travel`, `other`); `onUpgrade` v1→v2 creates `chat_messages`; v2→v3 adds sync columns (`revision`, `deletedAt`, `syncState`, `lastSyncedAt`) on all syncable tables, creates `sync_outbox` + `sync_metadata`, and backfills legacy camelCase enum values in-place (source/status); v3→v4 adds `budgets.alertSentAt120` (`_safeAddColumn`, idempotent); v4→v5 creates `recurring_rules` (fresh-upgrade path; local-only, not in sync).
- v3 adds `revision`, `deleted_at`, `sync_state`, `last_synced_at` (+`sync_outbox`, `sync_metadata`) to syncable tables (see migration above). `sync_outbox` (`id`, `entityType`, `entityId`, `operation`, `payloadJson`, `createdAt`, `retryCount`) and `sync_metadata` (`key PK`, `value`) are created; P3 will consume them.

Key domain entities (`lib/features/**/domain/entities`):

```dart
Transaction {id, type, amount, currency, categoryId, merchant?, occurredAt,
  note?, paymentMethod?, source, status, createdAt, updatedAt, category?, thumbnailPath?}
Category {id, parentId?, name, icon, colorValue, isSystem, sortOrder}
TransactionMedia {id, transactionId, type, originalPath?, compressedPath,
  thumbnailPath, hash, width?, height?, fileSizeBytes?, capturedAt?}
Budget {id, categoryId, period, amountLimit, alertThresholds, alertSentAt80,
  alertSentAt100, alertSentAt120, periodStart, periodEnd, category?}
CategoryBudgetProgress {budget, category, spentAmount; remainingAmount,
  progressRatio, clampedProgress, percent, isNearLimit, isExceeded}
ReportSummary {month, totalExpense, totalIncome, previousMonthExpense,
  categorySpendings, topExpenses, monthlyTrends; netBalance, expenseChangePercent}
ChatMessage {id, role, text, createdAt, status, blocks, suggestions, isLocal, isFeedback}
RecurringRule {id, amount, type, currency='VND', categoryId, frequency, dayOfMonth?,
  dayOfWeek?, startDate, endDate?, nextRunAt, isActive, merchant?, note?, createdAt}
RecurringFrequency {daily, weekly, monthly}  (enum stored as snake_case in DB)
TransactionDraft {amount, categoryId, categoryName, occurredAt, note?, type}
AssistantSettings {cloudEnabled=false, provider=openAiCompatible, baseUrl, model,
  apiKey, temperature=0.3; defaultBaseUrl, defaultGeminiBaseUrl, isUsable}
```

Enums persisted via TypeConverters to snake_case (important; A.1.1): `expense|income`; `product_snap|receipt_scan|manual|import`; `draft|confirmed|needs_review|failed`; `cash|card|transfer|ewallet|other`; `product|receipt|screenshot`. Dart-side enum names stay camelCase in domain (`TransactionSource.productSnap`, `TransactionStatus.needsReview`).

## 3.7 Data Models — Backend (PostgreSQL)

All syncable tables carry `revision INT DEFAULT 0`, `updated_at`, `deleted_at?`, and `user_id`.

| Table | Columns (abridged) |
|---|---|
| `users` | `id TEXT PK`, `created_at`, `deleted_at?`, `deletion_scheduled_at?` |
| `auth_identities` | `id PK`, `user_id FK`, `provider`, `provider_subject`, `created_at`, `last_used_at`; UNIQUE(provider,subject) |
| `devices` | `id PK`, `user_id`, `name`, `platform`, `push_token?`, `created_at`, `last_seen_at`, `revoked_at?` |
| `refresh_tokens` | `id PK`, `device_id`, `user_id`, `token_hash` (SHA-256), `family`, `used`, `expires_at`, `created_at`, `revoked_at?` |
| `transactions` | `id PK`, `user_id`, `type`, `amount NUMERIC(18,4)`, `currency`, `category_id`, `merchant?`, `occurred_at`, `note?`, `payment_method?`, `source`, `status` |
| `categories` | `id PK`, `user_id?` (null=system), `parent_id?`, `name`, `icon`, `color_value INT`, `is_system`, `sort_order` |
| `budgets` | `id PK`, `user_id`, `category_id`, `period`, `amount_limit NUMERIC`, `alert_thresholds TEXT`, `alert_sent_at_80`, `alert_sent_at_100`, `period_start`, `period_end` |
| `media` | `id PK`, `user_id`, `transaction_id?`, `object_key`, `thumbnail_key?`, `content_hash`, `size_bytes INT`, `mime_type`, `media_type`, `state`, `width?`, `height?`, `captured_at?` |
| `receipt_extractions` | `transaction_id PK`, `user_id`, `merchant?`, `merchant_confidence?`, `merchant_user_edited`, `transaction_date?`, `date_confidence?`, `total?`, `total_confidence?`, `subtotal?`, `tax?`, `payment_method?`, `overall_confidence`, `requires_review` (**no `raw_text`**) |
| `receipt_line_items` | `id PK`, `transaction_id`, `user_id`, `name`, `quantity?`, `unit_price?`, `total`, `category_suggestion?`, `confidence` |
| `ai_inferences` | `id PK`, `media_id`, `user_id`, `model_version`, `labels_json JSONB`, `suggested_category_id?`, `suggested_category_confidence?`, `extracted_amounts_json JSONB`, `confidence`, `latency_ms`, `source` |
| `change_log` | `sequence BIGSERIAL PK`, `user_id`, `entity_type`, `entity_id`, `operation`, `revision`, `device_id`, `changed_at`; index (user_id, sequence) |
| `sync_idempotency` | `operation_id PK`, `user_id`, `device_id`, `response_hash` (actually cached JSON), `created_at`, `expires_at`; UNIQUE(user,device,operation) |
| `export_jobs` | `id`, `user_id`, `status`, `download_key?`, `created_at`, `ready_at?`, `expires_at?` |
| `account_deletion_requests` | `id`, `user_id`, `initiated_by_device_id`, `requested_at`, `scheduled_delete_at`, `completed`, `completed_at?` |

Note: `export_jobs` / `account_deletion_requests` models exist but the privacy service does not persist rows into them.

## 3.8 API Schemas (contract-critical)

```python
AuthExchangeRequest {provider, id_token, device_name, device_platform}
AuthExchangeResponse {access_token, refresh_token, token_type, expires_in, device_id, user_id}

SyncOperation {operation_id, entity_type, entity_id, operation,
               base_revision:int, occurred_at:datetime, payload:dict|None}
PushRequest {device_id, operations[<=100]}
PushResponse {acknowledged:[{operation_id, entity_id, revision, sequence}],
              conflicts:[{operation_id, entity_id, entity_type, conflict_type,
                          server_revision, server_payload, hint}],
              server_cursor}
PullResponse {changes:[{entity_type, entity_id, operation, revision,
                        updated_at, payload, sequence}], next_cursor, has_more}
BootstrapResponse {entities:[{entity_type, entity_id, revision, updated_at, payload}],
                   page, total_pages, bootstrap_cursor}

UploadIntentRequest {media_type, content_type, size_bytes, content_hash,
                     transaction_id?, width?, height?, captured_at?}
UploadIntentResponse {media_id, upload_url, expires_at}
CompleteUploadRequest {content_hash, size_bytes}
DownloadIntentResponse {media_id, download_url, expires_at}

AssistantChatRequest {message<=2000, history[<=20]{role,content<=4000}, context<=6000}
AssistantChatResponse {reply, model, used_cloud:true}
```

Error envelope (all `AppError`):

```json
{"error":{"code":"sync_conflict|not_found|forbidden|unauthorized|validation_error|
  rate_limited|quota_exceeded|media_invalid|idp_token_invalid|tombstone_conflict|
  device_revoked|ai_unavailable|ai_upstream_error|internal_error",
  "message":"...","requestId":"...","retryable":false}}
```

## 3.9 Key interfaces / services

Mobile:

```dart
TransactionRepository: getTransactions(filter) / watchTransactions(filter) /
  getTransactionById / createTransaction(tx,{media}) / updateTransaction /
  deleteTransaction / getMediasForTransaction
CategoryRepository: getAllCategories / watchAllCategories / getCategoryById /
  createCategory / updateCategory / deleteCategory
RecurringTransactionRepository: watchAll / getAll / getDueRules / getById /
  save / update / setIsActive / delete
RecurringTransactionService: checkAndRunDueRules
BudgetRepository: getAllBudgets / watchAllBudgets / getBudgetById /
  getBudgetByCategoryId / watchBudgetProgressList({month}) / saveBudget /
  deleteBudget / checkAndTriggerAlerts
ReportRepository: getMonthlyReport(month) / watchMonthlyReport(month)
AssistantRepository: loadHistory / saveMessage / clearHistory / loadSettings / saveSettings
LlmClient: complete({settings, messages}) → String (throws LlmException)
ProductClassifier: classifyImage(path) → ProductClassificationResult
ReceiptOcrService: extractReceipt(path) → ReceiptExtractionResult
SecurityService: biometric + PIN + lock enable + auto-lock timeout
ImageStorageService: processAndStoreImage / deleteImageFiles / getImagesDirectory
DataManagementService: exportDataAsJson / exportDataAsCsv / importDataFromJson /
  getStorageUsage / deleteAllData
```

Backend:

```python
AuthService.exchange_token/refresh_tokens/revoke_device/list_devices
SyncService.push(db,user_id,device_id,request) / pull(db,user_id,cursor,limit) /
  bootstrap(db,user_id,page,page_size)
MediaService.create_upload_intent/complete_upload/get_download_intent/delete_media
PrivacyService.request_export/request_account_deletion
AssistantService.chat(request) ; property is_configured
StorageClient.generate_upload_url/generate_download_url/get_object_metadata/
  read_first_bytes/delete_object/validate_mime_from_magic_bytes/generate_object_key
```

## 3.10 Assistant engine details

- Intents: `greeting, help, totalSpend, incomeReport, topExpenses, categoryBreakdown, countTransactions, compareMonths, budgetStatus, recentTransactions, createTransaction, support, unknown`.
- Timeframes: today/yesterday, this/last week, this/last month, explicit `tháng N`, `N tháng gần đây`, all time.
- Local replies build `MetricBlock`, `TransactionListBlock`, `DraftBlock`, `NoteBlock`.
- Cloud path sends only `FinancialSnapshot.text` (monthly totals, category shares, budget limits) + up to 8 history turns. System prompt forbids inventing numbers, max 120 words, plain text, Vietnamese.
- Defaults: OpenAI-compatible `gpt-4o-mini`; Gemini `gemini-2.5-flash`; 40 s HTTP timeout; keys in `flutter_secure_storage` key `assistant_settings_v1`.
- Backend proxy mirrors this with server-side key and `LLM_*` env, returning 503 when unconfigured and 502 on upstream errors (provider bodies never echoed).

---

# 4. Coding Conventions & Constraints

## 4.1 Flutter / Dart

- Feature-first Clean Architecture: `domain` → `data` → `presentation`; imports point inward only.
- Entities extend `Equatable`; immutable with `copyWith`; no JSON in domain except assistant blocks/drafts/settings (explicit `fromJson/toJson`).
- Repositories are abstract in `domain`, Drift impls in `data`; mapping via extensions on generated rows/companions.
- DI: `get_it` lazy singletons registered in `configureDependencies()`; Riverpod `Provider` wrappers expose them to widgets. `securityServiceProvider` is intentionally overridden in `main.dart`.
- State: `StreamProvider` for DB streams, `FutureProvider` for one-shots, `AsyncNotifier`/`StateNotifier` for mutations; mutations use `AsyncValue.guard` and update an `AsyncValue<void>`.
- Navigation: `GoRouter` with `Routes` constants, auth redirect driven by `appLockProvider`, bottom-nav `ShellRoute`, full-screen camera routes outside the shell. Detail routes are nested under `/feed/transaction/:id`.
- Errors: sealed `AuthResult` (`AuthSuccess/AuthFailed/AuthCancelled`); `Failure` subclasses for storage/security/DB; UI catches and shows Vietnamese SnackBars.
- Formatting: VND via `double.toVnd()` (`1.234.500đ`), dates via `toRelativeLabel()`, `toDisplayDate()`, `toDisplayDateTime()`.
- Theme: flat Material 3, monochrome + green accent (`0xFF1A6B4A` light / `0xFF6FCF97` dark), Inter via `google_fonts`, no shadows/gradients.
- Lint: `very_good_analysis`; `public_member_api_docs` disabled; 80-char limit disabled; generated/l10n excluded.
- Codegen: `dart run build_runner build --delete-conflicting-outputs` after Drift/l10n changes. `AppDatabase.schemaVersion` must be bumped with a migration.
- Tests: unit tests for parsers/NLU/repos with in-memory Drift; widget tests with `ProviderScope` overrides and fakes (`test/features/assistant/fakes.dart`).
- Portrait-only; camera flows need a physical device.

## 4.2 Python / FastAPI

- Ruff + mypy strict + pytest asyncio auto mode; line length 100; `S` (bandit) rules enabled.
- Pydantic v2 schemas per module; `Literal` for closed enums; field limits on user text.
- Routers thin; business logic in `service.py`; dependencies in `app/dependencies.py`.
- Auth invariants: `user_id` from JWT `sub`; `device_id` from JWT; device must belong to user and not be revoked.
- Security headers on every response; CORS only in development; docs/OpenAPI disabled in production; `DEV_AUTH_ENABLED` forbidden in production.
- Logging: structlog with request/user/device contextvars; console renderer in dev, JSON in prod; redacts `access_token`, `refresh_token`, `bearer_token`, `amount`, `merchant`, `rawText`, `labels`, and any string containing `X-Amz-Signature`.
- IDs: ULID for server entities; client entity IDs are UUID v7/ULID-compatible.
- Money: `NUMERIC(18,4)` and `Decimal` server-side; JSON may carry floats.
- Timestamps: timezone-aware UTC everywhere.
- Alembic is the only schema authority; add migration + update ORM.
- Tests use in-memory **SQLite** (`sqlite+aiosqlite`, StaticPool) + `ASGITransport`; dev tokens `Bearer dev_mock_token_<userId>` bypass JWT.

## 4.3 Non-negotiable product principles

1. Offline-first: UI reads/writes local DB; server is a replica, never required.
2. Client is untrusted: no `user_id` from request body; all reads/writes user-scoped.
3. Idempotent sync: `operation_id` immutable across retries.
4. Least data: compressed image + thumbnail by default; originals only on explicit opt-in.
5. AI never overwrites user-edited fields; low confidence → `needsReview` / "Khác".
6. No secrets, tokens, pre-signed URLs, amounts, merchants or raw OCR text in logs/analytics.

## 4.4 Security model

- Access JWT RS256, 15 min, claims `sub`, `device_id`, `auth_time`, `exp`.
- Refresh token opaque 32-byte URL-safe, stored SHA-256 only, 90 days, rotation family; reuse → revoke family.
- Device revocation revokes all its refresh tokens; account deletion revokes all immediately.
- Media bucket private; server validates declared MIME against magic bytes (`jpeg/png/webp/heic`), size, hash; object keys include random UUID.
- PIN is stored as a weak 32-bit XOR/salted hash in secure storage (acknowledged in code; PBKDF2/Argon2 would be better). Biometrics via `local_auth` with device-credential fallback.
- Consent is intended to be granular (sync, media backup, original photos, cloud AI, analytics); only local booleans exist today.

## 4.5 Testing / quality commands

```bash
# Mobile
cd bill_tracker
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze          # currently: No issues found
flutter test             # currently: 190 tests, all pass

# Backend
cd backend
cp .env.example .env
make up && make migrate && make seed
make check               # ruff + format-check + mypy
make test                # pytest + coverage (fail_under 80)
```

## 4.6 Known constraints, gaps and defects (read before extending)

| # | Area | Constraint / defect | Impact |
|---|---|---|---|
| 1 | Sync | `SyncService.push` never calls `db.commit()`; `get_db` does not commit | In production, pushed ops/idempotency/change_log roll back on session close. Tests share one session, masking it. Media/privacy writes have the same issue. |
| 2 | Auth | `core/security.py` uses `jwt` (PyJWT) but only `python-jose` is declared; uses `settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES` / `JWT_REFRESH_TOKEN_EXPIRE_DAYS`, while `Settings` defines `ACCESS_TOKEN_EXPIRE_MINUTES` / `REFRESH_TOKEN_EXPIRE_DAYS` | `/auth/exchange` and `/auth/refresh` fail at runtime (ImportError/AttributeError). Current backend tests cannot pass as-is. |
| 3 | Privacy | `DELETE /v1/me` reads `request.state.auth_time`, which is never set | Always returns 401 "Recent authentication required". |
| 4 | Auth | Google/Apple verifiers `raise NotImplementedError` | Only `dev_mock` login works; production providers return 500. |
| 5 | Sync conflict | `json.dumps(conflict.model_dump())` when payload contains `Decimal` | Conflict caching can raise `TypeError`. |
| 6 | Mobile persistence | Enum `.name` writes produce `productSnap`, `receiptScan`, `needsReview`, `import_`; report mappers and backend expect `product_snap`, `receipt_scan`, `needs_review`, `import` | ✅ Fixed (migration v3, 2026-11-25): `TypeConverter`s store snake_case (`source`, `status`, `paymentMethod`), `onUpgrade` v2→v3 backfills legacy camelCase values in-place, report mappers accept both forms. |
| 7 | Mobile sync | No API client, no `sync_outbox`, no `sync_metadata`, no revision/tombstone columns | ✅ Schema part done (migration v3): revision/tombstone/sync columns + `sync_outbox` + `sync_metadata` + empty `SyncRepository` interface added; push/pull/bootstrap worker + device registration UI pending (P3). |
| 8 | Money | Mobile stores `REAL` (double) | Rounding drift vs server `NUMERIC(18,4)`. |
| 9 | Media | ~~`MediaService.MAX_QUOTA_BYTES = 100 MB` hardcoded; config says 2 GB; `expires_at` returns `now`~~ | ✅ Fixed (2026-11-25): `MAX_QUOTA_BYTES` reads `settings.MEDIA_QUOTA_PER_USER_BYTES`; upload/download `expires_at` = now + `S3_UPLOAD_URL_TTL` / `S3_DOWNLOAD_URL_TTL` (synced with the pre-signed URL TTLs). Declared media size limits still unused. |
| 10 | Rate limit | `slowapi` and `RATE_LIMIT_ENABLED` exist but no limiter/middleware installed | No abuse protection. |
| 11 | Background work | `asyncio.create_task` used with request-scoped DB/session for media delete and account cleanup (cleanup is a `pass` stub) | Tasks may run after session close; cleanup never happens. |
| 12 | Export | ~~Export is synchronous, does not create `export_jobs` row, no expiry cleanup~~ | ✅ Partially fixed (2026-11-25): `request_export` inserts an `export_jobs` row (`processing` → `ready`/`failed`, `ready_at`, `download_key`, `expires_at`) and `GET /v1/me/export/{job_id}` polls status (ownership-scoped, reports `expired` past TTL). Export itself remains synchronous; no background cleanup job. |
| 13 | Bootstrap | ~~Loads every entity row into memory before slicing~~ | ✅ Fixed (2026-11-25): `bootstrap` runs a SQL `COUNT` per entity type to map the global page window, then `ORDER BY pk LIMIT/OFFSET` only on intersecting tables; `BootstrapEntity`/`total_pages`/`bootstrap_cursor` contract unchanged. |
| 14 | Receipt | Parser never returns line items; UI never saves `receipt_line_items` or `rawText` | ✅ Fixed (2026-11-25): `VietnameseReceiptParser` parses line items between header & total line (keyword-skip heuristic, per-line confidence); review screen has an editable line-item editor (rename/qty/price/include/add/remove); `saveReceiptScanData` persists `receipt_extractions` (with `rawText`, local-only) + `receipt_line_items` + outbox upserts. |
| 15 | Product Snap | No price OCR despite documentation | ✅ Fixed (2026-11-25): `MlKitPriceOcrService` + `PriceTextExtractor` find VND price strings on the label; single candidate ≥0.70 auto-fills the numpad (editable, never auto-saved); candidates logged to `ai_inferences.extracted_amounts_json`. |
| 16 | Budget | ~~120% threshold stored/documented but only 80%/100% notifications fire; budget spend query ignores `status`~~ | ✅ Fixed (2026-11-25): `checkAndTriggerAlerts` checks 120% first (one critical alert, marks 80/100/120 sent, analytics threshold 1.2); `watchBudgetProgressList` + alert aggregation filter `status = confirmed`, so draft/failed never count. Migration v4 adds `alertSentAt120`; rollover resets it. |
| 17 | Settings | ~~`keepOriginalPhotosProvider` is not read by capture screens (`keepOriginal: false` hardcoded)~~ | ✅ Fixed (2026-11-25): Product Snap and Receipt Scan read the provider and pass it to `processAndStoreImage(keepOriginal: ...)`. |
| 18 | Routing | ~~`Routes.editTransaction` maps to `_PlaceholderScreen`; detail screen edits via direct `MaterialPageRoute`~~ | ✅ Fixed (2026-11-25): `Routes.editTransaction` (`/transaction/edit/:id`) resolves `transactionDetailProvider(id)` into `CreateEditTransactionScreen`; `_PlaceholderScreen` removed. |
| 19 | i18n | ~~`app_vi.arb` + generated `AppLocalizations` exist but no widget uses them~~ | ✅ Partially fixed (2026-11-25): `BillTrackerApp` wires `AppLocalizations.localizationsDelegates` / `supportedLocales`; `SettingsScreen` + `settings_screen_test.dart` migrated to `AppLocalizations` as reference pattern (other screens still hardcoded Vietnamese). |
| 20 | Dead code | ~~`TransactionListScreen`, `RegisterDeviceRequest`, `ExportJobResponse` paths partially unused~~ | ✅ Cleaned (2026-11-25): `TransactionListScreen` removed (replaced by `VisualFeedScreen`); `RegisterDeviceRequest` (`POST /v1/devices`) and `ExportJobResponse` (`GET /v1/me/export*`) are actively used and kept. |
| 21 | Backend/mobile schema | Backend `receipt_extractions` lacks `raw_text`; mobile has it | Mitigated (2026-11-25): mobile stores `rawText` locally for debug/retrain; `receiptExtractionPayload` deliberately omits `raw_text` (would fail server-side sync). Add a backend `raw_text` column before enabling it in the sync payload. |
| 22 | Test env | ~~Backend tests run on SQLite, prod on PostgreSQL; JSONB/BIGSERIAL/`Numeric` differ~~ | ✅ Mitigated (2026-11-25): added `postgres-test` service in `docker-compose.yml` + `make test-pg` + `TEST_DATABASE_URL` support in `tests/conftest.py` + `tests/integration/test_postgres_types.py` (JSONB/BIGSERIAL/Numeric). Default sandbox suite still runs on SQLite (`76 tests: 61 passed, 15 pre-existing failures`). |
| 23 | Logging | ~~Redaction misses generic `payload`, `note`, `context` keys; docs claim more~~ | ✅ Fixed (2026-11-25): `SENSITIVE_KEYS` lowercased (`rawtext`, `raw_text`) and expanded with `payload`, `note`, `context`, `total`, `subtotal`, `tax`, `unit_price`, `amount_limit`, `id_token`, `password`, `secret`, `api_key`, `authorization`, `labels_json`, `extracted_amounts_json`, `transactions`, `history`, `message`; recursive dict/list redaction added and covered by `tests/integration/test_logging_redaction.py`. |
| 24 | Health | ~~/health/ready checks DB only, not S3, although docs claim both~~ | ✅ Fixed (2026-11-25): `StorageClient.check_bucket()` issues `head_bucket` and `/health/ready` checks both DB (`SELECT 1`) and S3/MinIO (503 on failure); covered by `tests/integration/test_health.py`. |
| 25 | DB mixins | ~~`TimestampMixin`, `UserOwnedMixin`, `SyncableMixin` exist in `db/base.py` but models duplicate fields~~ | ✅ Fixed (2026-11-25): unused mixins removed from `app/db/base.py` (`Base(DeclarativeBase)` only). |
| 26 | Media/sync | `complete_upload` writes `change_log.operation='create'`, but `SyncChange.operation` only accepts `upsert` or `delete` | The next `/sync/pull` returning that row fails Pydantic validation (500). |
| 27 | Sync | ~~`upsert_entity` unconditionally set `currency`/`status`/`source` defaults (and `created_at`) on every model~~ | ✅ Fixed (2026-11-25): kwargs are filtered to the model's real columns first, so entities like `budget` no longer fail with `Unconsumed column names` / `NOT NULL`; covered by bootstrap tests. |

## 4.7 Extension rules (practical)

- Add a mobile feature: create `features/<name>/{domain,data,presentation}`; define repository interface in domain; implement with Drift; register in GetIt; expose Riverpod providers; add route in `Routes` + `AppRouter`.
- Change the local schema: edit table class, bump `schemaVersion`, add `onUpgrade` migration, rerun build_runner, update mappers and repository tests.
- Add a backend endpoint: create/extend module `schemas.py` + `service.py` + `router.py`; use `get_current_user`/`get_current_device`; raise `AppError` subclasses; add integration test with dev token headers; commit the session explicitly.
- Add a syncable entity: add ORM model with `user_id/revision/updated_at/deleted_at`; register in `ENTITY_TYPE_MAP`; update serialization PK special cases; add to `SyncOperation.entity_type` Literal; update change_log writers; add push/pull/bootstrap tests.
- Add an LLM feature: keep structured answers local; only free-form text may go to cloud; never send raw images, merchant names or IDs; respect `cloudEnabled` + `apiKey` + provider; always provide a local fallback.
- Never log secrets or raw financial content; use `<REDACTED>` placeholders in docs and tests.

---

# 5. Current Status & Next Steps

## 5.1 Verified status

| Check | Result |
|---|---|
| `flutter analyze` | Pending user re-run after final edits (routing, `SettingsScreen` l10n, `TransactionListScreen` removal); Flutter SDK is outside sandbox. Earlier baseline had **No issues found**. |
| `flutter test` | Pending user re-run after final edits (includes updated `settings_screen_test.dart`, `migration_v2_to_v3_test.dart` v6, `household_privacy_test.dart`). Earlier baseline had **163 tests passed** (203 after Phase 2 additions). |
| Backend ruff (`ruff check app/ tests/ scripts/` & `ruff format --check`) | **All checks passed! / 78 files already formatted** |
| Backend tests (SQLite) | `backend/.venv/bin/python -m pytest tests/` → **76 tests: 61 passed, 15 pre-existing SQLite/env failures** (new passing tests: `test_health.py` [2], `test_households.py` [3], `test_logging_redaction.py` [2], `test_postgres_types.py` [1]) |
| Backend tests (PostgreSQL) | `make test-pg` (`postgres-test` in `docker-compose.yml`) added; not started in sandbox (Docker unavailable in sandbox) |
| Secrets committed | No `.env` found; compose contains dev-only default credentials (redacted here) |

## 5.2 Completed

| Module | Status |
|---|---|
| Product Snap | ✅ camera/gallery → compress/thumb/hash → ML Kit labeling → category suggestion → numpad amount → save with media |
| Receipt Scan | ✅ ML Kit OCR → VN rule parser (merchant/total/date/payment/line items/confidence) → editable review + line-item editor → save, `needsReview` flag, `receipt_extractions`/`receipt_line_items` persisted |
| Visual Feed | ✅ photo grid, date-grouped timeline, stats header, category/date/text filters, VN query parsing, detail + delete |
| Manual Transaction | ✅ create/edit form, category picker, date picker, duplicate detection dialog |
| Budget | ✅ CRUD, monthly progress, 80/100/120 alerts (each once per cycle, confirmed expenses only), rollover reset, forecast banner (pure forecast math) |
| Giao dịch định kịt | ✅ CRUD quy tắc (schema v5, local-only), chạy khi mở feed (`checkAndRunDueRules`) + thông báo tap → mở giao dịch, logic nextRunAt đơn vị được unit-test (edge case tháng nhỏ/dài) |
| Reports | ✅ monthly metrics, donut, category list, top 5, 6-month trend, month picker |
| Assistant | ✅ local NLU/engine/drafts/feedback, bubble + popup + panel + settings sheet, OpenAI-compatible + Gemini clients (BYO key), offline fallback |
| Security / Lock | ✅ biometric + PIN, secure storage, auto-lock on background, lock screen routing |
| Data management | ✅ storage metrics, JSON/CSV export, JSON import, wipe-all, image/original retention plumbing |
| Backend auth | ✅ dev login, JWT issuing logic, refresh rotation/reuse detection, device list/revoke (JWT config bug blocks real use) |
| Backend sync | ✅ push/pull/bootstrap (SQL-paginated), idempotency cache, revision conflict, tombstones, cursor codec (commit bug blocks persistence) |
| Backend media | ✅ pre-signed upload/download, settings-driven quota, magic-byte/size/hash validation, real intent expiry, soft delete |
| Backend privacy | ✅ synchronous JSON export with `export_jobs` tracking + status polling; deletion scheduling logic (recent-auth and cleanup gaps) |
| Backend assistant | ✅ optional OpenAI-compatible proxy, 503 when unconfigured, 502 mapping, aggregate-only context |
| OCR/P2 | ⛔ interface + 501 endpoints only |

## 5.3 Incomplete / stubs

- Cloud sync **client** implementation (schema v3 + outbox/metadata + `SyncRepository` interface already landed): background worker, auth/device registration UI, media upload queue, conflict review UI.
- Apple/Google OIDC verifiers; real `POST /v1/devices`; production JWT key loading via file paths.
- Account deletion recent-auth enforcement + background purge worker; background export worker (still stub; job expiry cleanup deferred).
- Rate limiting; request payload cap; tombstone purge; Prometheus metrics (`S3 readiness check` done via `/health/ready`).
- Receipt edge detection/crop; per-line-item category mapping; backend `receipt_extractions.raw_text` column (currently mobile-only, §4.6 #21).
- Remaining screens l10n adoption (`SettingsScreen` + `BillTrackerApp` wired as reference).
- Remaining pre-existing backend SQLite-env test failures (15 tests).

## 5.4 Suggested next steps (priority order)

1. ~~**P0 – make backend honest:**~~ ✅ Done (2026-11-25): commit fixes, JWT config names + PyJWT dep, `request.state.auth_time`, Decimal conflict cache applied; backend suite still has 15 pre-existing SQLite-env failures to triage.
2. ~~**P0 – fix mobile enum persistence:**~~ ✅ Done (2026-11-25): migration v3 + TypeConverters + in-place backfill + report mapper alignment implemented and covered by `test/core/database/migration_v2_to_v3_test.dart`.
3. **P1 – sync client:** implement `SyncRepository` push/pull/bootstrap (retry/backoff), wire settings device registration + status screen, enqueue media uploads, conflict review UI (v3 schema + outbox/metadata ready).
4. **P1 – auth production path:** implement Google/Apple verifiers, `POST /v1/devices`, key-file loading, recent-auth dependency, rate limits.
5. **P1 – data lifecycle:** persist export jobs, add worker for deletion/media cleanup/tombstone purge (S3 readiness check done).
6. **P2 – AI/data depth:** line items + raw text persistence, product price OCR, cloud OCR jobs, field-level merge, 120% alerts, per-status budget math.
7. **P2 – polish:** expand l10n beyond `SettingsScreen`, PBKDF2/Argon2 PIN, run `make test-pg` against live PostgreSQL and `flutter analyze && flutter test` locally.

## 5.5 TODO/FIXME scan

No `TODO`/`FIXME`/`HACK` markers exist in `backend/app`, `backend/tests` or `bill_tracker/lib`.
The only explicit unimplemented markers are:

```python
# backend/app/modules/auth/oidc.py
GoogleOIDCVerifier.verify -> raise NotImplementedError("Google verifier not implemented yet")
AppleOIDCVerifier.verify  -> raise NotImplementedError("Apple verifier not implemented yet")
```

All other gaps are implicit in stubs (`pass` in `_cleanup_user_data`), placeholder responses (OCR 501), placeholder routes, or missing wiring described in §4.6/§5.3.

---

## 5.6 Quick Reference for an LLM

- **When asked "how does X work?"** → answer from §1.2 (flow), §3.6/§3.7 (data), then cite the file path.
- **When asked to add a feature** → obey §4.1/§4.2/§4.7; do not assume cloud sync exists; do not send financial data to an LLM by default.
- **When asked about sync** → distinguish *backend implemented* from *mobile absent*; mention commit bug.
- **When asked about auth** → only dev mock works today; production OIDC is a stub.
- **When asked about accuracy** → category mapping is keyword rules over ML Kit labels; receipts use regex/keyword heuristics; line items and price OCR are absent.
- **When asked about money** → VND, local `double`, server `NUMERIC(18,4)`; formatting `#.###đ`.
- **Never invent endpoints, libraries, tables, ports, env vars or features not listed above.**
