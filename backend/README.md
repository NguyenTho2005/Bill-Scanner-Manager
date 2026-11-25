# BillTracker Backend — P1: Cloud Backup & Sync

Backend service cho ứng dụng BillTracker. Cung cấp Authentication, Cloud Sync, Media Storage và Account Management theo nguyên tắc **local-first, opt-in cloud**.

> **Quan trọng:** Ứng dụng Flutter hoạt động đầy đủ khi offline. Backend chỉ được sử dụng khi người dùng chủ động bật Cloud Sync.

---

## Yêu cầu hệ thống

| Tool | Phiên bản |
|---|---|
| Docker | 24.0+ |
| Docker Compose | 2.20+ |
| Python | 3.12+ (nếu phát triển local không dùng Docker) |
| GNU Make | 4.0+ |

---

## Quick Start

### 1. Clone và chuẩn bị config

```bash
cd backend/
cp .env.example .env
# .env dùng cho local dev — không cần sửa gì thêm
```

### 2. Khởi động toàn bộ stack

```bash
make up
# Hoặc chạy nền:
make up-detached
```

Services sẽ khởi động:
| Service | URL | Ghi chú |
|---|---|---|
| API | http://localhost:8000 | FastAPI |
| PostgreSQL | localhost:5432 | user: billtracker / pw: billtracker_dev |
| MinIO (S3) | http://localhost:9000 | S3-compatible object storage |
| MinIO Console | http://localhost:9001 | user: minioadmin / pw: minioadmin |
| API Docs | http://localhost:8000/docs | Swagger UI |
| ReDoc | http://localhost:8000/redoc | ReDoc |

### 3. Chạy migrations

```bash
make migrate
# Hoặc:
docker compose exec api alembic upgrade head
```

### 4. Seed dev data

```bash
make seed
```

Tạo:
- 2 dev users (`dev_user_alice`, `dev_user_bob`)
- 10 system categories (giống Flutter app)
- Sample transactions và budgets

### 5. Lấy dev token để test API

```bash
curl -X POST http://localhost:8000/v1/auth/dev-token \
  -H 'Content-Type: application/json' \
  -d '{
    "sub": "dev_user_alice",
    "device_name": "Test Device",
    "device_platform": "ios"
  }'
```

Dùng `access_token` trong header: `Authorization: Bearer <access_token>`

---

## Biến môi trường

Copy từ `.env.example` và điền giá trị thực (chỉ cần cho local dev là file mẫu đủ dùng).

| Biến | Mô tả | Giá trị dev mặc định |
|---|---|---|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql+asyncpg://billtracker:billtracker_dev@postgres:5432/billtracker` |
| `S3_ENDPOINT` | Object storage endpoint | `http://minio:9000` |
| `S3_BUCKET` | S3 bucket name | `billtracker-media` |
| `S3_ACCESS_KEY` | S3 access key | `minioadmin` |
| `S3_SECRET_KEY` | S3 secret key | `minioadmin` |
| `DEV_AUTH_ENABLED` | Bật mock auth (dev only) | `true` |
| `JWT_ALGORITHM` | JWT signing algorithm | `RS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Access token TTL | `15` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | Refresh token TTL | `90` |
| `MEDIA_MAX_ORIGINAL_BYTES` | Max file size original (bytes) | `20971520` (20MB) |
| `MEDIA_QUOTA_PER_USER_BYTES` | Quota per user | `2147483648` (2GB) |
| `SYNC_MAX_PUSH_OPS` | Max operations per push | `100` |
| `ACCOUNT_DELETION_GRACE_DAYS` | Grace period before deletion | `30` |
| `ENVIRONMENT` | `development` / `production` | `development` |
| `LOG_LEVEL` | Log level | `INFO` |

> ⚠️ **Bảo mật:** `DEV_AUTH_ENABLED=true` chỉ dùng cho local dev. Trong staging/production phải đặt `false`. Không commit `.env` với secret thật lên Git.

---

## Đăng nhập production: Google / Apple OIDC (bật đăng nhập thật)

Ứng dụng mobile có 3 provider đăng nhập: `google`, `apple`, `dev_mock`.
`dev_mock` chỉ chạy khi `DEV_AUTH_ENABLED=true` (dev/test). Khi bảo vệ / chạy thật,
cần cấu hình 2 provider OIDC bên dưới — backend sẽ **xác thực `id_token`** do mobile
gửi lên qua `POST /v1/auth/exchange` bằng public key của provider (JWKS), không có
network call nào khác tới provider.

### 1. Google Sign-In (`GOOGLE_CLIENT_ID`)

**Bước chuẩn bị (Google Cloud Console → https://console.cloud.google.com):**

1. Tạo project (hoặc chọn project có sẵn) → **APIs & Services → OAuth consent screen**:
   chọn User Type *External*, điền app name + support email.
2. **Credentials → Create Credentials → OAuth client ID**:
   - Android app: điền package name `com.billtracker.app` (khớp `applicationId` trong
     Flutter) + SHA-1 của keystore signing.
   - Web client (dùng cho iOS Sign-In qua GoogleSignIn SDK): tạo 1 client *Web application*.
3. Copy **Client ID** (dạng `1234567890-abcdef.apps.googleusercontent.com`).

**Cấu hình backend (`backend/.env` hoặc secret manager):**

```env
GOOGLE_CLIENT_ID=1234567890-abcdef.apps.googleusercontent.com
```

- `GOOGLE_CLIENT_ID` **phải là đúng client ID mà mobile app dùng để xin id_token**
  (audience). Backend kiểm tra claim `aud == GOOGLE_CLIENT_ID`, sai → 401
  `idp_token_invalid`.
- Nhu cầu về key file: **không cần** file key nào cho Google (chỉ cần Client ID —
  verification dùng JWKS công khai của Google tại
  `https://www.googleapis.com/oauth2/v3/certs`).
- Issuer chấp nhận: `https://accounts.google.com` hoặc `accounts.google.com`.

### 2. Sign in with Apple (`APPLE_*`)

**Bước chuẩn bị (Apple Developer → https://developer.apple.com/account):**

1. **Certificates, Identifiers & Profiles → Identifiers (+)**:
   chọn *Services IDs*, đăng ký App ID cho BillTracker (Bundle ID, ví dụ
   `com.billtracker.app`), bật capability **Sign In with Apple**.
2. **Keys (+)**: tạo key với *Sign In with Apple* enabled, chọn App ID ở trên →
   download file `.p8`, ghi lại **Key ID** và **Team ID**.
3. Tạo **Service ID** (ví dụ `com.billtracker.signin`) cho web flow nếu cần.

**Cấu hình backend:**

```env
APPLE_CLIENT_ID=com.billtracker.app          # hoặc Service ID cho web flow
APPLE_TEAM_ID=ABCDEF1234                     # Apple Developer Team ID
APPLE_KEY_ID=XYZ9876543                      # Key ID của key .p8
APPLE_PRIVATE_KEY_PATH=/run/secrets/apple_sign_in_key   # path tới file .p8
```

- `APPLE_CLIENT_ID` = `aud` trong id_token của Apple — backend kiểm tra khớp, sai → 401.
- Verification dùng JWKS công khai của Apple tại `https://appleid.apple.com/auth/keys`
  (issuer `https://appleid.apple.com`). `APPLE_PRIVATE_KEY_PATH` chỉ cần khi backend
  tự tạo client_secret để gọi token endpoint của Apple — luồng verify id_token hiện tại
  **không cần** private key, nhưng giữ đúng key config để sẵn sàng cho web flow.
- File `.p8` phải được mount vào container (Docker secret / volume) — **không** commit lên Git.

### 3. JWT keys cho production (`JWT_*_KEY_PATH`)

Mặc định dev dùng ephemeral RSA key tự sinh khi `DEV_AUTH_ENABLED=true` (không bền).
Production **bắt buộc** cấp key bền — backend sẽ từ chối khởi động nếu thiếu:

```bash
# Sinh key RSA 2048-bit một lần khi triển khai:
openssl genrsa -out jwt_private_key.pem 2048
openssl rsa -in jwt_private_key.pem -pubout -out jwt_public_key.pem

# Mount vào container (ví dụ Docker secrets):
#   JWT_PRIVATE_KEY_PATH=/run/secrets/jwt_private_key
#   JWT_PUBLIC_KEY_PATH=/run/secrets/jwt_public_key
```

| Biến | Ý nghĩa | Ghi chú |
|---|---|---|
| `JWT_PRIVATE_KEY_PEM` / `JWT_PUBLIC_KEY_PEM` | Key PEM trực tiếp trong env | Tiện dev, kém an toàn hơn file |
| `JWT_PRIVATE_KEY_PATH` / `JWT_PUBLIC_KEY_PATH` | **Path tới file key** (ưu tiên production) | Dùng Docker secrets / mounted volume. Backend tự đọc file khi biến `*_PEM` trống |
| `DEV_AUTH_ENABLED` | Mock auth | **Bắt buộc `false`** trong production (app từ chối start nếu `true`) |

Thứ tự ưu tiên resolve key: `*_PEM` → `*_KEY_PATH` (đọc file) → dev auto-generate →
production raise RuntimeError nếu vẫn không có key.

### 4. Rate limiting (`RATE_LIMIT_*`)

Bật mặc định (`RATE_LIMIT_ENABLED=true`), dùng slowapi in-process, key theo `IP + user_id`:

| Endpoint | Giới hạn mặc định | Env override |
|---|---|---|
| `/v1/auth/*` (exchange/refresh/dev-token) | 10 req/phút | `RATE_LIMIT_AUTH_PER_MIN` |
| `/v1/sync/push` | 30 req/phút | `RATE_LIMIT_SYNC_PUSH_PER_MIN` |
| `/v1/sync/pull` | 60 req/phút | `RATE_LIMIT_SYNC_PULL_PER_MIN` |
| `/v1/assistant/chat` | 10 req/phút | `RATE_LIMIT_ASSISTANT_PER_MIN` |

Vượt giới hạn trả **HTTP 429** với envelope chuẩn `{ "error": { "code": "rate_limited", "retryable": true, ... } }`.

> Lưu ý: in-process limiter — mỗi instance API tự đếm riêng. Khi scale ngang nhiều
> replica, cần đổi sang Redis storage (slowapi `storage_uri="redis://..."`) để giới hạn
> dùng chung.

### 5. Endpoint đăng ký thiết bị mới

```bash
curl -X POST http://localhost:8000/v1/devices \
  -H "Authorization: Bearer <access_token>" \
  -H 'Content-Type: application/json' \
  -d '{"name": "iPhone của Alice", "platform": "ios"}'
# → 201 { "id": "<device_id>", "name": "...", "platform": "ios", "is_current": false, ... }
```

Device id này dùng cho các flow `refresh` và hiển thị trong `GET /v1/devices` (danh sách
thiết bị, xoá thiết bị).

---

## Chạy Tests

```bash
# Tất cả tests
make test

# Unit tests only
make test-unit

# Integration tests only  
make test-integration

# Security / IDOR tests (quan trọng nhất)
make test-security

# Sync-specific tests
make test-sync

# Với coverage report
pytest --cov=app --cov-report=html
open htmlcov/index.html
```

### Test coverage targets

| Module | Coverage target |
|---|---|
| auth | ≥ 90% |
| sync | ≥ 90% |
| media | ≥ 85% |
| privacy | ≥ 85% |
| Overall | ≥ 80% |

---

## Database Operations

```bash
# Xem migration history
make migrate-history

# Rollback 1 migration
make migrate-down

# Reset về empty (DESTRUCTIVE)
make migrate-reset

# Open PostgreSQL shell
make psql
```

---

## API Endpoints P1

### Authentication & Devices
| Method | Path | Mô tả |
|---|---|---|
| `POST` | `/v1/auth/exchange` | Đổi IdP token lấy access + refresh token |
| `POST` | `/v1/auth/refresh` | Refresh token rotation |
| `POST` | `/v1/auth/dev-token` | **Dev only** — lấy token không cần IdP |
| `POST` | `/v1/devices` | Đăng ký thiết bị mới |
| `GET` | `/v1/devices` | Danh sách thiết bị đang active |
| `DELETE` | `/v1/devices/{id}` | Thu hồi thiết bị / session |

### Sync
| Method | Path | Mô tả |
|---|---|---|
| `POST` | `/v1/sync/push` | Đẩy batch operations (tối đa 100) |
| `GET` | `/v1/sync/pull?cursor=...` | Kéo thay đổi theo cursor |
| `GET` | `/v1/sync/bootstrap?page=...` | Snapshot đầy đủ cho thiết bị mới |

### Media
| Method | Path | Mô tả |
|---|---|---|
| `POST` | `/v1/media/upload-intents` | Tạo pre-signed upload URL |
| `POST` | `/v1/media/{id}/complete` | Xác nhận upload, validate server-side |
| `GET` | `/v1/media/{id}/download-intent` | Lấy pre-signed download URL |
| `DELETE` | `/v1/media/{id}` | Xóa mềm media |

### Account & Privacy
| Method | Path | Mô tả |
|---|---|---|
| `GET` | `/v1/me` | Thông tin cơ bản của user |
| `GET` | `/v1/me/export` | Tạo và download export data |
| `DELETE` | `/v1/me` | Yêu cầu xóa account (cần recent auth) |

### OCR (P2 Placeholder)
| Method | Path | Status |
|---|---|---|
| `POST` | `/v1/ocr/jobs` | 501 Not Implemented |
| `GET` | `/v1/ocr/jobs/{id}` | 501 Not Implemented |
| `DELETE` | `/v1/ocr/jobs/{id}` | 501 Not Implemented |

### Assistant (Optional Cloud AI)
| Method | Path | Mô tả | Ưu tiên |
|---|---|---|---|
| `POST` | `/v1/assistant/chat` | Proxy hỏi-đáp đến nhà cung cấp LLM; 503 khi chưa cấu hình `LLM_API_KEY` | P2 |

### Health
| Method | Path | Mô tả |
|---|---|---|
| `GET` | `/health` | Liveness check |
| `GET` | `/health/ready` | Readiness (DB + S3) |
| `GET` | `/health/version` | Version info |

---

## Code Quality

```bash
make lint          # Ruff linter
make format        # Ruff formatter
make typecheck     # Mypy type check
make check         # Tất cả trên cùng lúc
```

---

## Kiến trúc tóm tắt

```
Flutter App (Drift local DB + outbox)
    │
    ├── HTTPS/JWT ──► FastAPI (Modular Monolith)
    │                    ├── auth/       (JWT RS256, OIDC Apple/Google)
    │                    ├── sync/       (push/pull/bootstrap, cursor-based)
    │                    ├── media/      (pre-signed URL, magic bytes validation)
    │                    ├── privacy/    (export, account deletion)
    │                    └── health/
    │                         │
    │                    ├── PostgreSQL 16 (metadata, change_log, sync)
    │                    └── MinIO/S3 (media objects, private bucket)
    │
    └── Pre-signed URL ──► MinIO (direct upload, không qua API server)
```

Xem chi tiết: [`docs/architecture.md`](docs/architecture.md)

---

## Giới hạn P1 & Roadmap

### P1 (đã triển khai)
- ✅ Auth: Sign in với Apple / Google / dev mock
- ✅ Device management và token rotation
- ✅ Sync: push/pull/bootstrap với idempotency và conflict resolution
- ✅ Media: pre-signed URL upload/download với server-side validation
- ✅ Privacy: export data, account deletion với grace period 30 ngày
- ✅ Rate limiting cơ bản
- ✅ Structured logging với redaction

### P2 (chưa triển khai)
- ⬜ Cloud OCR (Google Cloud Vision / Azure Form Recognizer)
  - Interface placeholder: `app/modules/ocr/interface.py`
  - Endpoints trả 501 Not Implemented
- ⬜ Background job queue (arq/Celery) cho cleanup và export async
- ⬜ Field-level conflict merge (P1 dùng whole-record LWW)

### P3 (future)
- ⬜ WebSocket realtime sync
- ⬜ Push notifications (APNs/FCM)
- ⬜ Storage plans và billing
- ⬜ Multi-device conflict resolution UI

---

## Security Notes

- **KHÔNG** deploy lên cloud với config này — chỉ dành cho local development
- **KHÔNG** commit `.env` với secret thật
- `DEV_AUTH_ENABLED=true` bỏ qua OIDC verification — chỉ dùng khi test local
- Pre-signed URLs **không** được log (bị redact trong structured logger)
- `user_id` luôn lấy từ JWT token, **không** bao giờ từ request body
- Mọi DB query đều filter theo `user_id` để ngăn IDOR

---

## Liên hệ và đóng góp

Xem [`docs/implementation-plan.md`](docs/implementation-plan.md) để biết task backlog và dependency order.
