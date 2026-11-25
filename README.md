# BillTracker — Visual Expense Tracker & Smart Receipt Scanner

Ứng dụng di động quản lý chi tiêu cá nhân bằng **hình ảnh**: chụp món đồ hoặc quét hóa đơn để ghi nhận giao dịch nhanh, tự động phân loại bằng AI và xem lại lịch sử như một nhật ký ảnh.

> **Local-first, riêng tư:** toàn bộ luồng cốt lõi hoạt động **offline trên thiết bị**, không bắt buộc liên kết tài khoản ngân hàng. Backend cloud là **opt-in (P1)** — chỉ dùng khi người dùng tự bật Cloud Sync để sao lưu / đồng bộ đa thiết bị.

---

## 1. Sản phẩm làm gì?

| Vấn đề | Cách BillTracker giải quyết |
|---|---|
| Nhập giao dịch thủ công chậm, dễ bỏ cuộc | **Product Snap:** chụp ảnh món đồ → nhập số tiền qua numpad → xác nhận trong < 5 giây |
| Danh sách số liệu khô khan, khó nhớ đã mua gì | **Visual Feed / Photo Grid:** xem chi tiêu theo ảnh, màu danh mục, merchant |
| Hóa đơn giấy bị mất, ảnh rải rác trong thư viện | **Receipt Scan:** OCR tự đọc merchant / ngày / tổng tiền / line items, kèm màn hình Review để sửa |
| Không thấy "tiêu tiền đi đâu" | **Budget & Reports:** ngân sách theo danh mục, cảnh báo 80/100/120%, donut chart, xu hướng tháng |
| Lo dùng app tài chính bị thu thập dữ liệu | **Riêng tư:** local-only mặc định, khóa sinh trắc học/PIN, cloud chỉ khi opt-in rõ ràng, export/xóa dữ liệu bất kỳ lúc nào |
| Muốn "hỏi về chi tiêu" / "ghi giao dịch bằng câu" | **Trợ lý chi tiêu (bong bóng chat nổi):** chạm bong bóng ở góc màn hình để mở popup hỏi đáp tổng chi, top khoản, danh mục, ngân sách, so sánh tháng — chạy offline trên thiết bị; tuỳ chọn LLM cloud (BYO key) |

## 2. Tính năng chính (theo PRD)

### MVP — Local / On-device
- [x] **Product Snap to Expense** — chụp sản phẩm, AI gợi ý danh mục (ML Kit Image Labeling), đọc giá từ nhãn/menu (OCR), sửa trước khi lưu
- [x] **Bill & Receipt OCR Scanner** — nhận diện viền hóa đơn, crop, OCR on-device (ML Kit Text Recognition) + parser hóa đơn tiếng Việt, overlay Review
- [x] **Visual Transaction Timeline** — Photo Grid, Visual Feed theo ngày, List View, lọc theo danh mục/thời gian, tìm kiếm
- [x] **Budget & Visual Reports** — ngân sách tháng, biểu đồ tròn theo danh mục, top khoản chi, so sánh tháng, dự báo chi tiêu
- [x] **Storage, Privacy & Security** — SQLite/Drift local-first, khóa sinh trắc học (`local_auth`) + PIN dự phòng, mã hóa secure storage, nén ảnh/thumbnail

### Backend P1 — Cloud Backup & Sync (opt-in)
- [x] Auth (Apple / Google OIDC + dev mock), quản lý thiết bị, refresh token rotation
- [x] Đồng bộ push/pull theo cursor, idempotency, tombstone khi xóa, xung đột last-write-wins (whole-record)
- [x] Media storage qua pre-signed URL lên S3/MinIO, validate MIME/size/hash phía server
- [x] Export dữ liệu + xóa tài khoản (grace period 30 ngày)
- [ ] **P2:** Cloud OCR fallback (async job) — interface + endpoint placeholder (501)
- [ ] **P3:** Realtime sync, push notification, field-level merge, storage plan/billing

> Chi tiết yêu cầu: [`PRD.md`](PRD.md) (sản phẩm) và [`PRD_BACKEND.md`](PRD_BACKEND.md) (backend/cloud).

## 3. Kiến trúc tổng thể

```text
┌────────────────────────────  Mobile (Flutter)  ────────────────────────────┐
│  UI (Riverpod + GoRouter)                                                   │
│    ├─ Product Snap  ├─ Receipt Scan  ├─ Visual Feed  ├─ Budget  ├─ Reports  │
│    └─ Transaction   └─ Auth / Lock Screen    └─ Settings                     │
│                                  │                                          │
│  Core: Camera/Image · ML Kit AI · Drift/SQLite local DB · Notifications     │
│        Biometric Lock · Secure Storage · Image Compression                  │
└──────────────────────────────┬─────────────────────────────────────────────┘
                               │  HTTPS + JWT  (chỉ khi đã bật Cloud Sync)
                               │  pre-signed URL (upload ảnh trực tiếp lên S3)
                               ▼
┌────────────────────────────  Backend (FastAPI)  ──────────────────────────┐
│  Modular monolith: auth · sync (push/pull/bootstrap) · media · privacy ·    │
│                    health · ocr (P2 placeholder)                            │
│  PostgreSQL 16 (metadata + change_log)   +   MinIO/S3 (ảnh private)        │
└────────────────────────────────────────────────────────────────────────────┘
```

### Nguyên tắc không đổi
1. **Offline-first** — local DB là nguồn đọc/ghi cho UI; server chỉ là bản sao đồng bộ.
2. **Không tin client** — `user_id` luôn lấy từ access token, không nhận từ body; mọi query filter theo user (chống IDOR).
3. **Idempotent** — gửi lại cùng `operationId` không tạo bản ghi trùng.
4. **Least data** — mặc định chỉ backup ảnh nén/thumbnail; ảnh gốc chỉ lên khi người dùng opt-in riêng.
5. **Không ghi đè dữ liệu người dùng đã sửa** bằng kết quả AI.

## 4. Cấu trúc thư mục

```text
BillTracker/
├── bill_tracker/            # App di động Flutter
│   ├── lib/
│   │   ├── core/            # AI (ML Kit), camera, database (Drift), DI, router, security, storage, theme…
│   │   ├── features/        # auth · budget · feed · product_snap · receipt_scan · reports · settings · transaction · visual_feed
│   │   └── l10n/            # i18n (flutter gen-l10n)
│   ├── test/
│   └── pubspec.yaml
├── backend/                 # API FastAPI + PostgreSQL + MinIO
│   ├── app/modules/         # auth · health · media · ocr · privacy · sync
│   ├── app/db/models/       # user, transaction, category, budget, media, receipt, ai, sync…
│   ├── migrations/          # Alembic
│   ├── tests/               # unit + integration (gồm IDOR/security)
│   └── docs/                # architecture.md, implementation-plan.md
├── PRD.md                   # PRD sản phẩm
├── PRD_BACKEND.md           # PRD bổ sung backend/cloud
└── README.md                # ← file này
```

## 5. Công nghệ

| Lớp | Công nghệ chính |
|---|---|
| Mobile | Flutter (Dart ≥ 3.6), Riverpod, GoRouter, GetIt |
| Local DB | Drift trên SQLite, `flutter_secure_storage` |
| On-device AI | ML Kit Text Recognition + Image Labeling (`google_mlkit_*`) |
| Camera/ảnh | `image_picker`, `image`, `path_provider` |
| Backend | Python 3.12+, FastAPI, SQLAlchemy async + Alembic, Pydantic, `python-jose` (JWT RS256), `aioboto3`/`boto3` |
| Hạ tầng (local) | Docker Compose: API + PostgreSQL 16 + MinIO |

## 6. Cách chạy nhanh

Bạn có thể chạy **chỉ mobile**, **chỉ backend**, hoặc **cả hai**. Mobile chạy được ngay không cần backend (local-only).

### 6.1. Mobile (Flutter) — xem [`bill_tracker/README.md`](bill_tracker/README.md)

```bash
cd bill_tracker
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # codegen Drift/l10n
flutter run          # chọn thiết bị: flutter devices
flutter test
flutter analyze
```

### 6.2. Backend (Docker) — xem [`backend/README.md`](backend/README.md)

```bash
cd backend
cp .env.example .env
make up            # API + PostgreSQL + MinIO
make migrate
make seed          # 2 user dev + danh mục + dữ liệu mẫu
# API:    http://localhost:8000   ·  Docs: http://localhost:8000/docs
# MinIO:  http://localhost:9001   (minioadmin / minioadmin)

# Lấy dev token để gọi API:
curl -X POST http://localhost:8000/v1/auth/dev-token \
  -H 'Content-Type: application/json' \
  -d '{"sub":"dev_user_alice","device_name":"Test","device_platform":"ios"}'
```

### 6.3. API chính (P1)

| Nhóm | Endpoint |
|---|---|
| Auth & device | `POST /v1/auth/exchange`, `POST /v1/auth/refresh`, `POST /v1/devices`, `DELETE /v1/devices/{id}` |
| Sync | `POST /v1/sync/push`, `GET /v1/sync/pull?cursor=…`, `GET /v1/sync/bootstrap` |
| Media | `POST /v1/media/upload-intents`, `POST /v1/media/{id}/complete`, `GET /v1/media/{id}/download-intent`, `DELETE /v1/media/{id}` |
| Tài khoản | `GET /v1/me`, `GET /v1/me/export`, `DELETE /v1/me` |
| Khỏe | `GET /health`, `/health/ready`, `/health/version` |

## 7. Luồng đồng bộ (tóm tắt)

1. Mọi thay đổi local được ghi vào bảng `sync_outbox` cùng transaction với entity.
2. Khi online: client **push** batch outbox (tối đa 100 operation) → server validate token/quyền/idempotency → ghi entity + `change_log`.
3. Client **pull** từ `cursor` gần nhất cho đến khi trống (thiết bị mới dùng `bootstrap` phân trang).
4. Xóa = **tombstone** (giữ ≥ 30 ngày, thắng update cũ hơn, tránh "hồi sinh" dữ liệu đã xóa).
5. Conflict (`baseRevision` cũ) → server trả `409 sync_conflict` kèm bản server để client tự xử lý/review.

## 8. Bảo mật & riêng tư — cần nhớ

- Chế độ local-only: **không** gửi request auth/sync/upload/OCR nào.
- Consent tách rời: Cloud Sync · backup media · backup ảnh gốc · cloud OCR/AI · analytics.
- Không log access token, refresh token, pre-signed URL hay nội dung tài chính/OCR thô.
- `DEV_AUTH_ENABLED=true` **chỉ** cho local dev — tắt ở staging/production. Không commit `.env` có secret thật.
- Bucket S3/MinIO phải **private**, chỉ truy cập qua pre-signed URL ngắn hạn.

## 9. Trạng thái & roadmap

| Giai đoạn | Tình trạng |
|---|---|
| MVP mobile (camera → expense, OCR, Visual Feed, Budget, lock) | Đã triển khai phần lớn trong `bill_tracker/` |
| Backend P1 (auth, sync, media, privacy) | Đã triển khai trong `backend/` |
| P2: Cloud OCR async, job queue, field-level merge | Chưa — placeholder |
| P3: Realtime sync, push notification, billing | Tương lai |

Mục tiêu sản phẩm: ghi nhận giao dịch phổ biến trong **< 5 giây**, AI gợi ý danh mục top-1 **≥ 80%**, OCR tổng tiền sau xác thực **≥ 90%** (chi tiết KPI trong `PRD.md`).

## 10. Tài liệu liên quan

- [`PRD.md`](PRD.md) — yêu cầu sản phẩm, user stories, acceptance criteria, KPI.
- [`PRD_BACKEND.md`](PRD_BACKEND.md) — backend/cloud: data model, API contract, SLO, kế hoạch sprint.
- [`backend/docs/architecture.md`](backend/docs/architecture.md) — kiến trúc backend.
- [`backend/docs/implementation-plan.md`](backend/docs/implementation-plan.md) — task backlog backend.
- [`bill_tracker/README.md`](bill_tracker/README.md) — hướng dẫn chạy app Flutter.
- [`backend/README.md`](backend/README.md) — hướng dẫn chạy/seed/test backend.

## 11. Đóng góp

1. Đọc PRD liên quan trước khi làm tính năng mới; cập nhật acceptance criteria nếu hành vi thay đổi.
2. Mobile: `flutter analyze` + `flutter test` trước khi commit.
3. Backend: `make check` (ruff + format + mypy) và `make test` (gồm security/IDOR) trước khi mở PR.
4. Không commit `.env`, secret, hoặc file build/cache (`build/`, `__pycache__/` đã có trong `.gitignore`).
