# Use.md — Các lệnh chạy dự án BillTracker

Tài liệu này tập hợp **các command thường dùng** để chạy, kiểm thử và debug dự án.
Cập nhật lần cuối: 2026-11-26.

Dự án gồm 2 phần độc lập:

| Phần | Thư mục | Công nghệ | Bắt buộc? |
|---|---|---|---|
| Mobile app | `bill_tracker/` | Flutter + Drift + ML Kit | Có (chạy được một mình, local-first) |
| Backend API | `backend/` | FastAPI + PostgreSQL + MinIO | Không (chỉ khi bật cloud sync) |

> App hoạt động đầy đủ **offline**. Backend là opt-in, không cần để demo app.

---

## 0. Quick start (TL;DR)

```bash
# ── App Flutter ──────────────────────────────────────────────
cd bill_tracker
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # chỉ khi sửa DB/l10n
flutter emulators --launch Pixel_6                          # bật emulator Android
flutter run

# ── Backend (tuỳ chọn) ───────────────────────────────────────
cd ../backend
cp .env.example .env
make up-detached
make migrate
make seed
# API:   http://localhost:8000/docs
# MinIO: http://localhost:9001  (minioadmin / minioadmin)
```

---

## 1. Yêu cầu hệ thống

| Tool | Phiên bản tối thiểu | Kiểm tra |
|---|---|---|
| Flutter | 3.6+ (Dart 3.6+) | `flutter --version` |
| Android SDK | API 34+ | `flutter doctor` |
| Java | 17+ | `java -version` |
| Docker | 24+ | `docker --version` |
| Docker Compose | 2.20+ | `docker compose version` |
| GNU Make | 4.0+ | `make --version` |
| Python (nếu chạy backend không Docker) | 3.12+ | `python3.12 --version` |

Kiểm tra toàn bộ toolchain Flutter:

```bash
flutter doctor -v
```

---

## 2. App Flutter (`bill_tracker/`)

### 2.1. Cài dependency

```bash
cd bill_tracker
flutter pub get
```

### 2.2. Sinh code tự động (Drift / l10n)

Chỉ cần chạy khi **sửa bảng database** hoặc **file dịch `.arb`**:

```bash
cd bill_tracker
dart run build_runner build --delete-conflicting-outputs
```

Khi đang code liên tục, dùng watch mode:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

Sinh lại localization:

```bash
flutter gen-l10n
```

### 2.3. Chạy app

```bash
# Xem thiết bị / emulator đang có
flutter devices

# Liệt kê emulator
flutter emulators

# Bật emulator (ví dụ Pixel 6)
flutter emulators --launch Pixel_6
adb wait-for-device

# Chạy app (chọn thiết bị nếu có nhiều)
flutter run

# Chỉ định thiết bị
flutter run -d emulator-5554

# Bản release (mượt hơn, không hot reload)
flutter run --release

# Chạy trên thiết bị thật qua USB
adb devices
flutter run -d <device-id>
```

Trong lúc `flutter run`:

| Phím | Tác dụng |
|---|---|
| `r` | Hot reload |
| `R` | Hot restart |
| `p` | Bật/tắt debug paint |
| `q` | Thoát |

### 2.4. Build APK

```bash
cd bill_tracker

# Debug APK
flutter build apk --debug

# Release APK (cần keystore)
flutter build apk --release

# App bundle cho Play Store
flutter build appbundle --release
```

File ra ở `bill_tracker/build/app/outputs/flutter-apk/`.

### 2.5. Test & kiểm tra chất lượng

```bash
cd bill_tracker

flutter analyze                 # static analysis
flutter test                    # toàn bộ test
flutter test test/features/...  # một file/thư mục cụ thể
flutter test --coverage         # kèm coverage (coverage/lcov.info)
```

### 2.6. Dọn dẹp khi build lỗi

```bash
cd bill_tracker
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## 3. Backend (`backend/`)

### 3.1. Chuẩn bị

```bash
cd backend
cp .env.example .env
# .env mặc định đủ dùng cho local dev — KHÔNG commit file .env
```

### 3.2. Chạy bằng Docker (khuyến nghị)

```bash
cd backend

make up            # chạy foreground, thấy log
make up-detached   # chạy nền
```

Các service sau khi chạy:

| Service | URL | Tài khoản |
|---|---|---|
| API | http://localhost:8000 | — |
| Swagger UI | http://localhost:8000/docs | — |
| ReDoc | http://localhost:8000/redoc | — |
| PostgreSQL | `localhost:5432` | `billtracker` / `billtracker_dev` |
| MinIO S3 API | http://localhost:9000 | `minioadmin` / `minioadmin` |
| MinIO Console | http://localhost:9001 | `minioadmin` / `minioadmin` |

### 3.3. Migration & seed dữ liệu

```bash
cd backend

make migrate            # chạy tất cả migration
make migrate-current    # xem version hiện tại
make migrate-history    # lịch sử migration
make migrate-down       # rollback 1 bước
make migrate-reset      # ⚠️ xoá sạch + chạy lại (mất dữ liệu)

make seed               # seed dev data (idempotent)
```

Seed tạo: 2 dev user (`dev_user_alice`, `dev_user_bob`), 10 categories, sample transactions/budgets.

### 3.4. Lấy token dev để gọi API

```bash
curl -X POST http://localhost:8000/v1/auth/dev-token \
  -H 'Content-Type: application/json' \
  -d '{
    "sub": "dev_user_alice",
    "device_name": "Test Device",
    "device_platform": "ios"
  }'
```

Lưu token vào biến môi trường:

```bash
TOKEN=$(curl -s -X POST http://localhost:8000/v1/auth/dev-token \
  -H 'Content-Type: application/json' \
  -d '{"sub":"dev_user_alice","device_name":"Test","device_platform":"ios"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

curl -H "Authorization: Bearer $TOKEN" http://localhost:8000/v1/me
```

### 3.5. Kiểm tra sức khoẻ API

```bash
make health          # /health
make health-ready    # /health/ready  (DB + S3)
```

Hoặc:

```bash
curl http://localhost:8000/health
curl http://localhost:8000/health/ready
curl http://localhost:8000/health/version
```

### 3.6. Log & debug

```bash
cd backend

make logs            # follow log API
make psql            # vào PostgreSQL shell
make shell           # Python shell trong container API
make minio-console   # in thông tin MinIO console

docker compose ps            # trạng thái container
docker compose exec api bash # vào container API
```

### 3.7. Tắt / reset

```bash
cd backend

make down          # tắt container, giữ dữ liệu
make down-clean    # tắt + xoá volume (mất DB và ảnh MinIO)
make clean         # xoá cache Python local
```

### 3.8. Test & quality backend

```bash
cd backend

make test               # toàn bộ test + coverage
make test-unit          # unit tests
make test-integration   # integration tests
make test-security      # IDOR + auth tests
make test-sync          # sync push/pull tests
make test-pg            # test với PostgreSQL container

make lint               # ruff check
make format-check       # kiểm tra format
make typecheck          # mypy
make check              # lint + format + typecheck
make lint-fix           # tự sửa lỗi lint
make format             # tự format code
```

Nếu chưa cài dependency local:

```bash
cd backend
python3.12 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
```

---

## 4. Chạy app + backend cùng lúc

App mặc định **không gọi backend**. Nếu cần test tích hợp cloud:

### Emulator Android → backend trên máy host

Emulator không thấy `localhost` của host. Dùng `10.0.2.2`:

```text
http://10.0.2.2:8000
```

### Thiết bị thật → backend trên máy host

```bash
adb reverse tcp:8000 tcp:8000
# sau đó app dùng http://localhost:8000
```

> Lưu ý: `DEV_AUTH_ENABLED=true` chỉ dành cho local dev. Tắt khi staging/production.

---

## 5. Cổng & URL thường dùng

| Cổng | Dịch vụ | Ghi chú |
|---|---|---|
| 8000 | FastAPI | `http://localhost:8000` |
| 5432 | PostgreSQL | `billtracker` / `billtracker_dev` |
| 9000 | MinIO S3 API | `minioadmin` / `minioadmin` |
| 9001 | MinIO Console | `http://localhost:9001` |
| 5433 | PostgreSQL test | chỉ khi chạy `make test-pg` |

Kiểm tra cổng bị chiếm:

```bash
docker ps
ss -ltnp | grep -E '8000|5432|9000|9001'
```

---

## 6. Troubleshooting

### `Multiple adb binaries found`

Máy có nhiều bản adb. Ưu tiên SDK của bạn:

```bash
export PATH="$HOME/Android/Sdk/platform-tools:$PATH"
```

Thêm vào `~/.bashrc` / `~/.zshrc` để giữ lâu dài.

### `Android license status unknown`

```bash
flutter doctor --android-licenses
```

### Flutter cảnh báo chạy bằng root

Chỉ chạy Flutter bằng user thường (không dùng `sudo`, không login root). Nếu file đã bị root sở hữu:

```bash
sudo chown -R $USER:$USER bill_tracker
```

### Build Android lần đầu rất chậm

Gradle tải dependency. Chờ vài phút, các lần sau nhanh hơn.

### `flutter run` không thấy thiết bị

```bash
adb kill-server
adb start-server
adb devices
flutter devices
```

### Lỗi Drift do thiếu file `.g.dart`

```bash
cd bill_tracker
dart run build_runner build --delete-conflicting-outputs
```

### Backend không kết nối được DB

```bash
cd backend
docker compose ps
make logs
# nếu cần reset:
make down-clean && make up-detached && make migrate && make seed
```

### Port 8000 đã bị chiếm

```bash
docker ps | grep 8000
# hoặc đổi port trong docker-compose.yml (ví dụ "8001:8000")
```

---

## 7. Quy ước trước khi commit

```bash
# Mobile
cd bill_tracker
flutter analyze && flutter test

# Backend
cd backend
make check && make test
```

- Không commit `.env`, secret, keystore, `build/`, `__pycache__/`.
- Cập nhật `PRD.md` / `PRD_BACKEND.md` nếu thay đổi hành vi sản phẩm.

---

## 8. Tài liệu liên quan

| File | Nội dung |
|---|---|
| `README.md` | Tổng quan sản phẩm, kiến trúc |
| `PRD.md` | Yêu cầu sản phẩm mobile |
| `PRD_BACKEND.md` | Yêu cầu backend/cloud |
| `PROJECT_CONTEXT.md` | Bối cảnh & tiến độ dự án |
| `backend/README.md` | Hướng dẫn backend chi tiết (OIDC, JWT, rate limit…) |
| `backend/docs/architecture.md` | Kiến trúc backend |
| `backend/docs/implementation-plan.md` | Backlog backend |
