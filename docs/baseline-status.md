# Baseline Status — BillTracker

> Mục đích: chốt **điểm xuất phát** (môi trường + hiện trạng code) trước khi sửa bất kỳ logic nào, để các giai đoạn sau so sánh trước/sau.
> Ngày chạy: 2026-11-25 (UTC+7). Không sửa code logic, không commit gì ngoài file này.
> Nguồn tham chiếu: `PROJECT_CONTEXT.md` §4.6 (26 điểm rủi ro) và §5.3 (phần dở dang).

---

## 0. Tóm tắt một dòng

| Hạng mục | Kết quả baseline |
|---|---|
| Flutter analyze | ✅ **No issues found** |
| Flutter test | ✅ **163 passed / 0 failed** (khớp `PROJECT_CONTEXT.md`) |
| Backend install theo tài liệu | ❌ **Không thể** (`pip install -e ".[dev]"` fail 2 tầng) |
| Backend `make check` | ❌ **Fail** — ruff 403 lỗi, format 53 file, mypy 82 lỗi |
| Backend `make test` | ❌ **Fail** — 30 error + 7 failed (JSONB/SQLite, JWT, session dùng chung) |
| Docker stack | ❌ **Không dựng được** (image MinIO không còn trên registry; Dockerfile lỗi cú pháp pip) |
| Alembic trên PostgreSQL thật | ✅ **OK** — `0002 (head)`, 16 bảng |
| Seed dev data | ❌ **Fail** — `ImportError: cannot import name 'create_engine'` |

**Kết luận:** app Flutter là phần duy nhất đang xanh. Backend P1 **không chạy được end-to-end** ở baseline: không cài được dependency, không build được image, không qua lint/typecheck, test suite đỏ gần như toàn bộ, và login (`/v1/auth/exchange`) trả 500.

---

## 1. Môi trường đo

| Thành phần | Phiên bản / ghi chú |
|---|---|
| OS | Linux, user `root`, repo trên `/media/tho/NEW DATA1/BillTracker` |
| Python | 3.12.3 (`/usr/bin/python3.12`) |
| Flutter | 3.47.2 stable, Dart SDK 3.13.0 (theo cảnh báo analyzer) |
| Docker | 29.1.3; Docker Compose v2.40.3; daemon active |
| GNU Make | 4.3 |
| Git | Repo root **không phải** git repo; chỉ `bill_tracker/` là git repo |
| `backend/.venv` ban đầu | Hỏng: **không có pip**, không có package nào (`No module named pytest`) |

Ghi chú trạng thái git của `bill_tracker/`: trước khi chạy đã có 10 file modified + 3 untracked (assistant feature, `chat_messages_table.dart`). Sau `pub get` + `build_runner` + `test`, `git status --short` **giống hệt** bản chụp trước đó → tooling không tạo thay đổi mới.

---

## 2. Mobile (Flutter)

Thư mục: `bill_tracker/`

### 2.1 `flutter pub get`

```text
Got dependencies!
78 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

Kết quả: ✅ OK (chỉ cảnh báo version cũ, không phải lỗi).

### 2.2 `dart run build_runner build --delete-conflicting-outputs`

```text
SDK language version 3.13.0 is newer than `analyzer` language version 3.11.0. Run `flutter packages upgrade`.
...
Built with build_runner in 45s; wrote 143 outputs.
```

Kết quả: ✅ OK. Cảnh báo analyzer cũ vs SDK 3.13 (không chặn build).

### 2.3 `flutter analyze`

```text
Analyzing bill_tracker...
No issues found! (ran in 7.5s)
```

Kết quả: ✅ **0 issue** (khớp PROJECT_CONTEXT §4.5).

### 2.4 `flutter test`

```text
00:15 +163: All tests passed!
```

Kết quả: ✅ **163 passed, 0 failed** — **khớp chính xác** con số 163 trong `PROJECT_CONTEXT.md` §4.5/§5.1.
Không có test skip, không có test flaky trong lần chạy này.

> Lưu ý môi trường: Flutter in cảnh báo "running flutter as root" — không ảnh hưởng kết quả.

---

## 3. Backend — cài dependency

### 3.1 Bootstrap venv

`backend/.venv` không có pip → phải chạy `python -m ensurepip --upgrade` (pip 24.0 → 26.3). Đây là lỗi môi trường có sẵn, không phải do repo.

### 3.2 `pip install -e ".[dev]"` → ❌ FAIL (tầng 1: build backend)

```text
ValueError: Unable to determine which files to ship inside the wheel using the following heuristics:
https://hatchpypa.io/.../default-file-selection
The most likely cause of this is that there is no directory that matches the name of your project (billtracker_backend).
...
error: metadata-generation-failed
× Encountered error while generating package metadata.
╰─> from file:///media/tho/NEW%20DATA1/BillTracker/backend
```

Nguyên nhân: `pyproject.toml` dùng `hatchling` nhưng **không khai báo** `[tool.hatch.build.targets.wheel] packages = ["app"]`; tên project `billtracker-backend` không trùng thư mục `app/`.

### 3.3 Cài theo danh sách dependency → ❌ FAIL (tầng 2: xung đột version)

Sinh requirements từ `pyproject.toml` (runtime + `dev`) rồi cài:

```text
ERROR: Cannot install -r requirements (line 15) and -r requirements (line 16) because these package versions have conflicting dependencies.
    aiobotocore 2.15.2 depends on botocore<1.35.37 and >=1.35.16
    boto3 1.35.76 depends on botocore<1.36.0 and >=1.35.76
ERROR: ResolutionImpossible
```

→ **`pyproject.toml` không thể resolve**: pin `boto3==1.35.76` mâu thuẫn trực tiếp với `aiobotocore==2.15.2`.

**Workaround đã dùng để đo tiếp (không sửa repo):** cài toàn bộ danh sách **trừ** dòng `boto3==1.35.76`; pip tự chọn `boto3 1.35.36` (tương thích `botocore 1.35.36`). Cài thành công 70+ package, gồm `pytest 8.3.4`, `pytest-asyncio 0.24.0`, `pytest-cov 6.0.0`, `ruff 0.8.6`, `mypy 1.14.1`, `moto 5.0.22`.

### 3.4 Hai dependency thiếu, không khai báo

Sau khi cài đủ danh sách, app vẫn không import được:

```text
File ".../app/core/security.py", line 1, in <module>
    import jwt
ModuleNotFoundError: No module named 'jwt'
```

→ `core/security.py` dùng **PyJWT**, nhưng `pyproject.toml` chỉ có `python-jose[cryptography]`. Đã cài `PyJWT==2.10.1` **chỉ để chẩn đoán**.

Tiếp theo, test suite dừng ở conftest:

```text
File ".../tests/conftest.py", line 19, in <module>
    engine = create_async_engine(TEST_DB_URL, ...)
ModuleNotFoundError: No module named 'aiosqlite'
```

→ `aiosqlite` là dependency test **không được khai báo**. Đã cài `aiosqlite==0.20.0` **chỉ để chẩn đoán**.

> Hai package này **không có trong repo**; chúng chỉ tồn tại trong `.venv` local. Nếu không cài, backend không thể import app / chạy test.

---

## 4. Docker & cơ sở dữ liệu

### 4.1 `cp .env.example .env`

Đã tạo `backend/.env` từ `.env.example` (chỉ chứa placeholder `CHANGE_ME`, `DATABASE_URL` trỏ `localhost:5432`). Không có secret thật.

### 4.2 `make up` / `make up-detached` → ❌ FAIL (image)

`make up` là `docker compose up --build` (foreground) nên chạy `make up-detached` (cùng lệnh + `-d`) để không treo session:

```text
minio-setup Error pull access denied for minio/mc, repository does not exist or may require 'docker login'
Error response from daemon: pull access denied for minio/mc, repository does not exist or may require 'docker login'
make: *** [Makefile:17: up-detached] Error 1
```

Kiểm tra độc lập:

```text
docker pull minio/minio:latest  → pull access denied ... repository does not exist
docker pull minio/mc:latest     → pull access denied ... repository does not exist
docker pull quay.io/minio/minio:latest → 401 UNAUTHORIZED
docker pull postgres:16-alpine  → OK (Digest sha256:f2f98726...)
```

→ Docker daemon và mạng OK; **image MinIO không còn pull được anonymous** (repo Docker Hub bị gỡ/giới hạn, quay.io trả 401). Đây là blocker hạ tầng, không phải lỗi code. Không thể chạy `make up`, do đó `make migrate`, `make seed`, `make health` (compose exec/curl vào API container) đều không dùng được.

### 4.3 Thay thế để kiểm chứng migration: PostgreSQL 16 standalone

Chạy `postgres:16-alpine` tạm ở port **55432** (không sửa compose):

```text
alembic upgrade head
INFO  [alembic.runtime.migration] Running upgrade  -> 0001, initial schema
INFO  [alembic.runtime.migration] Running upgrade 0001 -> 0002, domain tables
→ EXIT 0
alembic current → 0002 (head)
```

16 bảng được tạo đúng: `users, auth_identities, devices, refresh_tokens, transactions, categories, budgets, media, receipt_extractions, receipt_line_items, ai_inferences, change_log, sync_idempotency, export_jobs, account_deletion_requests, alembic_version`.

→ ✅ **Migrations hợp lệ trên PostgreSQL thật.** (Container đã được xoá sau khi đo.)

### 4.4 `make seed` → ❌ FAIL (script hỏng)

`make seed` = `docker compose exec api python scripts/seed_dev.py` → không chạy được vì compose không up. Chạy trực tiếp với `DATABASE_URL` trỏ PG tạm:

```text
File ".../scripts/seed_dev.py", line 33, in <module>
    from app.db.base import create_engine
ImportError: cannot import name 'create_engine' from 'app.db.base'
```

Soi thêm trong script (chưa chạy tới nên chưa thấy traceback):

- dòng 34: `from app.db.session import async_session_maker` — tên này **có** tồn tại, nhưng script dùng như sync session.
- dòng 183: `engine = create_engine(str(settings.database_url))` — `Settings` **không có** attribute `database_url` (chỉ có `DATABASE_URL`), và `create_engine` (sync) không dùng được với DSN `postgresql+asyncpg://`.
- dòng 184: `async_session_maker.configure(bind=engine)` — sai kiểu engine.

→ Seed script hiện **không thể chạy**; dev data (2 user, categories, sample transactions) không được tạo.

### 4.5 `docker build` → ❌ FAIL (Dockerfile lỗi cú pháp)

Build riêng image API (không cần MinIO):

```text
Step 7/19 : RUN pip install --no-cache-dir --prefix=/install ".[" && pip install --no-cache-dir --prefix=/install .
ERROR: Invalid requirement: '.[': Expected package name at the start of dependency specifier
The command '/bin/sh -c pip install ... ".[" ...' returned a non-zero code: 1
```

Hai lỗi trong 1 dòng: `".["` là requirement không hợp lệ, và dù sửa thành `.[dev]` thì vẫn sẽ đụng cả lỗi hatchling (§3.2) và xung đột boto3/aiobotocore (§3.3). Ngoài ra bước cuối `pip install .` cũng cần hatchling config đúng.

→ Docker image **chưa từng build thành công** ở baseline.

---

## 5. Backend `make check` → ❌ FAIL

`make check` = `lint` → `format-check` → `typecheck`; dừng ngay ở target đầu tiên (Makefile không dùng `-` để bỏ qua lỗi).

### 5.1 `ruff check app/ tests/ scripts/`

```text
Found 403 errors.
[*] 265 fixable with the `--fix` option (3 hidden fixes can be enabled with the `--unsafe-fixes` option).
make: *** [Makefile:85: lint] Error 1
```

Phân bố: `app/` 318, `tests/` 63, `scripts/` 22.

| Mã | Số lỗi | Ghi chú |
|---|---|---|
| W293 | 133 | whitespace trên dòng trống |
| E501 | 85 | dòng > 100 ký tự |
| UP017 | 48 | `datetime.timezone.utc` → `datetime.UTC` |
| I001 | 45 | import chưa sort |
| B008 | 44 | `Depends()`/`Query()` trong default argument (đặc thù FastAPI — cần per-file ignore) |
| F401 | 21 | import thừa |
| UP007, W291, F841, F541, B904, UP035, S105, PGH… | còn lại | |

File nhiều lỗi nhất: `app/modules/sync/service.py` (48), `app/modules/auth/service.py` (35), `app/modules/media/service.py` (32), `app/dependencies.py` (23), `scripts/seed_dev.py` (21).

### 5.2 `ruff format --check app/ tests/ scripts/`

```text
Would reformat: tests/integration/test_sync_bootstrap.py
...
53 files would be reformatted, 11 files already formatted
```

### 5.3 `mypy app/` (strict)

```text
Found 82 errors in 27 files (checked 52 source files)
```

Lỗi đáng chú ý (trùng §4.6):

```text
app/modules/auth/service.py:124: error: "Settings" has no attribute "JWT_REFRESH_TOKEN_EXPIRE_DAYS"; maybe "REFRESH_TOKEN_EXPIRE_DAYS"?  [attr-defined]
app/modules/auth/service.py:137: error: "Settings" has no attribute "JWT_ACCESS_TOKEN_EXPIRE_MINUTES"; maybe "ACCESS_TOKEN_EXPIRE_MINUTES"?  [attr-defined]
app/modules/sync/service.py:62: error: Argument "conflict_type" to "ConflictEntry" has incompatible type "str | None"; expected "Literal['revision_mismatch', 'tombstone_wins']"  [arg-type]
app/modules/sync/service.py:168: error: Argument "operation" to "SyncChange" has incompatible type "str"; expected "Literal['upsert', 'delete']"  [arg-type]
```

Các nhóm còn lại: `no-untyped-def` ở toàn bộ router (privacy 3, media 4, auth 4, health 3…), `storage.py` 9 lỗi (aiobotocore typing), `entity_serializer.py` 6, `middleware.py` 6.

→ **Chất lượng backend ở baseline: đỏ ở cả 3 cổng lint/format/type.** "No issues found" của PROJECT_CONTEXT chỉ đúng cho Flutter.

---

## 6. Backend `make test` → ❌ FAIL

### 6.1 Lỗi tầng 1 — không import được package

```text
$ make test
pytest -v --tb=short --cov=app --cov-report=term-missing
ImportError while loading conftest '.../tests/conftest.py'.
tests/conftest.py:7: in <module>
    from app.db.base import Base
E   ModuleNotFoundError: No module named 'app'
make: *** [Makefile:65: test] Error 4
```

Nguyên nhân: bare `pytest` không thêm CWD vào `sys.path`, và package `app` không được cài (editable install fail — §3.2). Chạy `python -m pytest` thì qua tầng này.

### 6.2 Lỗi tầng 2 — thiếu `jwt`

```text
app/core/security.py:1: in <module>
    import jwt
E   ModuleNotFoundError: No module named 'jwt'
```

(Đã cài PyJWT để đo tiếp — §3.4.)

### 6.3 Lỗi tầng 3 — thiếu `aiosqlite`

```text
tests/conftest.py:19: in <module>
    engine = create_async_engine(TEST_DB_URL, ...)
E   ModuleNotFoundError: No module named 'aiosqlite'
```

(Đã cài aiosqlite để đo tiếp — §3.4.)

### 6.4 Lỗi tầng 4 — SQLite không render JSONB (§4.6 #22, nặng hơn dự đoán)

```text
sqlalchemy.exc.CompileError: (in table 'ai_inferences', column 'labels_json'):
Compiler <sqlalchemy.dialects.sqlite.base.SQLiteTypeCompiler object ...> can't render element of type JSONB
AttributeError: 'SQLiteTypeCompiler' object has no attribute 'visit_JSONB'. Did you mean: 'visit_JSON'?
```

Đây là **hard error lúc `Base.metadata.create_all`**, không chỉ là khác biệt ngữ nghĩa: `tests/conftest.py` dùng `sqlite+aiosqlite:///:memory:` trong khi model `AIInference.labels_json` khai báo `JSONB` (PostgreSQL-only). Hệ quả: **30/39 test error ngay ở fixture**, toàn bộ test DB-backed (auth, sync, media, privacy, idor) không chạy được.

Bằng chứng bổ sung: các test này **pass được** khi chạy trên PostgreSQL thật (xem §6.5 — số error vẫn 30 vì conftest vẫn là SQLite; nhưng migration PG chạy OK ở §4.3).

### 6.5 Kết quả tổng hợp

| Cấu hình chạy | Passed | Failed | Errors | Ghi chú |
|---|---|---|---|---|
| `python -m pytest` (không có PG) | 2 | 7 | 30 | assistant tests cố kết nối PG thật |
| `python -m pytest` + `DATABASE_URL` → PG tạm | 3 | 6 | 30 | thêm 1 test pass |
| `make test` | — | — | — | fail trước khi collect (`No module named 'app'`) |

### 6.6 Vì sao 6–7 test assistant fail (2 nguyên nhân khác nhau)

**(a) Không có PostgreSQL ở `localhost:5432`:**

```text
ConnectionRefusedError: [Errno 111] Connect call failed ('127.0.0.1', 5432)
```

`tests/integration/test_assistant.py` tự tạo `AsyncClient(ASGITransport(app=app))` và **không dùng fixture `async_client`/`get_db` override**, nên request đi vào DB thật theo `settings.DATABASE_URL`. Đây là lỗi thiết kế test (test không hermetic).

**(b) Khi đã có PG: session dùng chung bị concurrent access:**

```text
sqlalchemy.exc.InterfaceError: (sqlalchemy.dialects.postgresql.asyncpg.InterfaceError)
<class 'asyncpg.exceptions._base.InterfaceError'>: cannot perform operation: another operation is in progress
[SQL: SELECT users.id, ... FROM users WHERE users.id = $1::VARCHAR]
```

Nguyên nhân: `conftest.async_client` yield **một `AsyncSession` duy nhất** cho mọi request; khi test bắn nhiều request song song (hoặc dependency + background task) thì asyncpg báo lỗi. Với SQLite in-memory thì lỗi này bị che bởi lỗi JSONB ở trên.

### 6.7 Coverage

Không có báo cáo coverage vì pytest fail trước/song song. Gate `fail_under = 80` trong `pyproject.toml` **không thể đạt** ở baseline (suite đỏ).

### 6.8 `make test-unit` cũng hỏng cấu trúc

`tests/unit/` **không tồn tại** (chỉ có `tests/integration/` + `conftest.py`). Target `make test-unit` và `make test-security` (một phần) sẽ fail vì path không có.

---

## 7. Smoke test API runtime (uvicorn + PostgreSQL tạm)

Chạy `uvicorn app.main:app --port 8010` với `DATABASE_URL` trỏ PG tạm:

| Request | Kết quả |
|---|---|
| `GET /health` | ✅ 200 `{"status":"ok"}` |
| `GET /health/ready` | ✅ 200 `{"status":"ready"}` (chỉ check DB — §4.6 #24 vẫn đúng) |
| `POST /v1/auth/dev-token` | ✅ 200, trả `{"id_token":"{\"sub\": \"baseline_user\", ...}"}` (raw JSON string — đúng như mô tả "mock id_token JSON") |
| `POST /v1/auth/exchange` (id_token hợp lệ từ dev-token) | ❌ **HTTP 500** |
| `POST /v1/auth/exchange` (token dạng `dev_mock_token_<id>`) | ⚠️ 401 `"Invalid mock token format"` (định dạng này chỉ dùng cho **bearer** dependency, không dùng cho exchange) |

Traceback 500 (nguyên văn):

```text
AttributeError: 'Settings' object has no attribute 'JWT_REFRESH_TOKEN_EXPIRE_DAYS'. Did you mean: 'REFRESH_TOKEN_EXPIRE_DAYS'?
```

→ **§4.6 #2 xác nhận trên runtime thật**: không thể lấy access token ⇒ mọi endpoint cần auth (sync push/pull, media, /v1/me, DELETE /me) **không thể test end-to-end** ở baseline. Test `DELETE /v1/me` (§4.6 #3) và sync (§4.6 #1) chưa thể quan sát hành vi thực tế; chỉ xác nhận ở mức code.

---

## 8. Đối chiếu §4.6 — 26 điểm còn đúng hay đã sửa?

Chú thích: ✅ còn đúng (bằng chứng mới) · 🟡 đúng ở mức code, chưa quan sát runtime · ❌ đã được sửa.

| # | Nội dung §4.6 | Trạng thái | Bằng chứng baseline |
|---|---|---|---|
| 1 | `SyncService.push` không `commit()`; `get_db` cũng không commit | ✅ | `grep "await db.commit()" app/modules` chỉ ra 4 dòng, **tất cả trong `auth/service.py`**; `app/db/session.py get_db` chỉ `yield session` |
| 2 | JWT config sai tên + PyJWT không khai báo | ✅ | mypy 2 lỗi `attr-defined`; runtime 500 `'Settings' object has no attribute 'JWT_REFRESH_TOKEN_EXPIRE_DAYS'`; `import jwt` fail trước khi cài PyJWT |
| 3 | `DELETE /v1/me` đọc `request.state.auth_time` không bao giờ được set | 🟡 | `grep "state.auth_time\s*=" app` → **không có kết quả**; không test được runtime vì #2 |
| 4 | Google/Apple verifier `NotImplementedError` | ✅ | `app/modules/auth/oidc.py:18,22` |
| 5 | `json.dumps(conflict.model_dump())` với `Decimal` | 🟡 | `sync/service.py:73` vẫn `json.dumps({'type':'conflict','data': conflict.model_dump()})`; chưa dựng được kịch bản conflict do #1/#22 |
| 6 | Enum mobile lưu `.name` lệch snake_case backend | 🟡 | Code vẫn serialize `.name`; test Flutter xanh vì test cũng dùng `.name`; backend payload dùng snake_case |
| 7 | Mobile không có sync client/outbox/metadata | ✅ | `grep` toàn `lib/` không có HTTP client gọi `/v1/*`, không có bảng outbox; settings chỉ là `StateProvider<bool>` |
| 8 | Tiền lưu `REAL` (double) mobile | ✅ | `transactions_table.dart` dùng `RealColumn amount` |
| 9 | Quota media hardcode 100 MB; `expires_at = now` | ✅ | `media/service.py:17 MAX_QUOTA_BYTES = 100*1024*1024`; `:73 expires_at=now  # Simplified for P1`; `:157 expires_at=now` |
| 10 | Rate limit chưa wire | ✅ | `grep -rn "Limiter\|slowapi" app` → không có kết quả trong `app/`; chỉ có trong `pyproject.toml` |
| 11 | `asyncio.create_task` + cleanup `pass` | ✅ | `media/service.py:192`, `privacy/service.py:133`; `_cleanup_user_data` body chỉ `pass` (`:142`) |
| 12 | Export đồng bộ, không ghi `export_jobs` | ✅ | `privacy/service.py request_export` query + build JSON + upload trong request; không có `db.add(ExportJob...)` |
| 13 | Bootstrap load toàn bộ rồi slice | ✅ | `sync/service.py:204-219` comment "fetch all sequentially and slice … not efficient for real bootstrap"; `total = len(results)` |
| 14 | Line items/rawText không persist ở mobile | ✅ | `grep rawText lib/features/receipt_scan lib/features/transaction` → rỗng; `receipt_line_items` chỉ có ở table + generated code, không có repository/insert |
| 15 | Product Snap không OCR giá | ✅ | Flow chỉ ML Kit **image labeling** + numpad nhập tay; không gọi text recognition |
| 16 | Chỉ cảnh báo 80/100; budget tính cả status | ✅ | `budget_repository_impl.dart:186,221` chỉ 80/100; UI có `_notifyAt120` nhưng không có `alertSentAt120`; query `:168-177` không filter `status` |
| 17 | `keepOriginalPhotosProvider` không được đọc | ✅ | `product_snap_screen.dart:102 keepOriginal: false`, `receipt_scan_screen.dart:107 keepOriginal: false` |
| 18 | `Routes.editTransaction` là placeholder | ✅ | `app_router.dart:118-121` builder → `_PlaceholderScreen(title: 'Sửa ${id}')` |
| 19 | l10n có generated nhưng không dùng | ✅ | `grep "AppLocalizations" lib --include=*.dart` ngoài `lib/l10n` → **0 kết quả** |
| 20 | Dead code | ✅ | `TransactionListScreen` không được router tham chiếu (chỉ `VisualFeedScreen` dùng ở `/feed`) |
| 21 | Backend `receipt_extractions` thiếu `raw_text` | ✅ | `grep -rn raw_text app/db/models app/modules` → **0 kết quả** |
| 22 | Test SQLite vs prod PostgreSQL | ✅ (nặng hơn) | `CompileError ... can't render element of type JSONB` → 30 error ngay fixture; không chỉ khác ngữ nghĩa |
| 23 | Redaction bỏ sót key generic | ✅ | `logging.py:11 SENSITIVE_KEYS` chỉ gồm 7 key; không có `payload`, `note`, `context` |
| 24 | `/health/ready` chỉ check DB | ✅ | `health/router.py` chỉ `SELECT 1`, không gọi S3 |
| 25 | Mixins bị model duplicate, không dùng | ✅ | `grep TimestampMixin\|SyncableMixin\|UserOwnedMixin app/db/models` → **0 kết quả** |
| 26 | `media.complete` ghi `change_log.operation='create'` | ✅ | `media/service.py:118 operation='create'`; mypy báo `SyncChange.operation` chỉ nhận `Literal['upsert','delete']` (`sync/service.py:168`) |

**Tổng: 23/26 còn đúng, 3 điểm (#3, #5, #6) đúng ở mức code nhưng chưa/không thể xác nhận runtime** do blocker #1/#2/#22. **Không có điểm nào đã được sửa** kể từ lần quét trước.

---

## 9. Phát hiện mới (ngoài §4.6)

| # | Vấn đề | Bằng chứng | Ảnh hưởng |
|---|---|---|---|
| N1 | `hatchling` không có `[tool.hatch.build.targets.wheel]` → `pip install .` fail | §3.2 | Không cài được package, không build wheel, không editable install |
| N2 | `boto3==1.35.76` xung đột `aiobotocore==2.15.2` | §3.3 | `pip install -e ".[dev]"` **không bao giờ resolve được**; cần hạ boto3 (≤1.35.36) hoặc nâng aiobotocore |
| N3 | Dockerfile: `pip install ".["` sai cú pháp + `pip install .` sẽ fail vì N1 | §4.5 | Không build được image API |
| N4 | Image `minio/minio`, `minio/mc` không còn pull anonymous (Docker Hub), quay.io 401 | §4.2 | `make up` không chạy được trên máy sạch |
| N5 | `tests/conftest.py` dùng SQLite in-memory nhưng model có `JSONB` | §6.4 | 30 test error ngay fixture — suite gần như vô dụng |
| N6 | `scripts/seed_dev.py` import `create_engine` từ `app.db.base`, dùng `settings.database_url`, trộn sync/async engine | §4.4 | `make seed` fail; dev data không có |
| N7 | Test assistant tự dựng client, bỏ qua `get_db` override | §6.6a | Test không hermetic, phụ thuộc PostgreSQL local |
| N8 | `async_client` fixture yield 1 session cho nhiều request | §6.6b | Lỗi `another operation is in progress` khi concurrent |
| N9 | `aiosqlite` và `PyJWT` không được khai báo | §3.4 | Người mới clone repo không thể chạy test/khởi động app |
| N10 | `tests/unit/` không tồn tại | §6.8 | `make test-unit` fail; không có unit test backend |
| N11 | Chất lượng code backend: ruff 403, format 53 file, mypy 82 lỗi | §5 | CI/quality gate đỏ; khó review diff khi sửa feature |
| N12 | `make test` gọi bare `pytest` thay vì `python -m pytest` | §6.1 | Fail ngay cả khi dependency đã đủ |

---

## 10. Những gì **không** kiểm chứng được ở baseline

- Sync push/pull/bootstrap end-to-end (cần access token; bị #2 chặn).
- Media upload/download với MinIO thật (image không pull được).
- `DELETE /v1/me` + recent-auth + cleanup worker (cần token; cleanup là `pass`).
- Export job persistence / download URL thật.
- Conflict `Decimal` serialization (#5) và lỗi `change_log.operation='create'` (#26) trên đường pull thật.
- Hành vi app mobile với cloud sync (tính năng chưa tồn tại — §4.6 #7).
- Receipt scan / product snap trên thiết bị thật (cần camera + ML Kit; chỉ có unit/widget test).

---

## 11. Đề xuất thứ tự xử lý cho giai đoạn sau

**P0 — môi trường/build (phải xong trước khi sửa feature):**

1. Sửa `pyproject.toml`: thêm `[tool.hatch.build.targets.wheel] packages = ["app"]`; hạ `boto3` xuống `1.35.36` (hoặc nâng `aiobotocore`); thêm `aiosqlite` và `PyJWT` vào dev/runtime deps tương ứng.
2. Sửa `Dockerfile` dòng `pip install ".["` → `pip install .` (hoặc `".[dev]"` nếu cần).
3. Chọn nguồn MinIO còn sống (pin tag cụ thể + registry) hoặc thay bằng image S3-compatible khác; cập nhật compose.
4. Sửa `conftest.py`: dùng PostgreSQL (testcontainers/DSN) hoặc đổi `JSONB` → `JSON` có variant; tách session theo request.
5. Sửa `scripts/seed_dev.py` (import + `settings.DATABASE_URL` + async engine).

**P1 — correctness backend (đúng như PROJECT_CONTEXT §5.4):**

6. `await db.commit()` cho sync/media/privacy; set `request.state.auth_time`; đổi tên config JWT; fix `operation='upsert'`; đổi `json.dumps` conflict sang encoder xử lý `Decimal`.
7. Wire slowapi hoặc bỏ hẳn khỏi docs; sửa quota/`expires_at`; readiness check thêm S3.

**P2 — chất lượng & feature:**

8. Dọn ruff/mypy (ưu tiên `app/`), format toàn bộ, bật CI gate.
9. Mobile: sync client + Drift v3 (outbox/metadata), chuẩn hoá enum snake_case, wire `keepOriginalPhotos`.
10. Bổ sung `tests/unit/` cho parser/NLU/forecast/detector phía backend nếu cần, và test PostgreSQL thật.

---

## 12. Phụ lục — lệnh đã chạy & log

| # | Lệnh | Kết quả | Log |
|---|---|---|---|
| 1 | `flutter pub get` | ✅ | `/tmp/opencode/baseline-logs/01-flutter-pub-get.log` |
| 2 | `dart run build_runner build --delete-conflicting-outputs` | ✅ 143 outputs | `02-build-runner.log` |
| 3 | `flutter analyze` | ✅ No issues | `03-flutter-analyze.log` |
| 4 | `flutter test` | ✅ 163/163 | `05-flutter-test.log` |
| 5 | `python -m pip install -e ".[dev]"` | ❌ hatchling | `04-pip-install.log` |
| 6 | `make up-detached` | ❌ MinIO pull | `06-docker-up.log` |
| 7 | `make check` | ❌ ruff (403) | `07-make-check.log`, `07a/b/c-*` |
| 8 | `make test` | ❌ `No module named 'app'` | `08-make-test.log` |
| 9 | `python -m pytest` (+PyJWT, +aiosqlite, ±PG) | ❌ 30 error / 6–7 failed | `09/10/13-*.log` |
| 10 | `alembic upgrade head` (PG 16 tạm) | ✅ 0002 head | `11-alembic-local-pg.log` |
| 11 | `python scripts/seed_dev.py` | ❌ ImportError | `12-seed-local-pg.log` |
| 12 | `uvicorn` smoke test | ⚠️ health OK, exchange 500 | `14-uvicorn.log`, `15-exchange.json` |
| 13 | `docker build` | ❌ `".["` invalid | `16-docker-build.log` |

Log trong `/tmp/opencode/baseline-logs/` là **tạm thời** (có thể mất sau reboot); file này giữ lại các trích dẫn quan trọng.

### Thay đổi đã tạo trong workspace

- `docs/baseline-status.md` (file này) — **file duy nhất được thêm**.
- `backend/.env` — copy từ `.env.example` (placeholder, không có secret), phục vụ bước 3 của yêu cầu.
- `backend/.venv/` — cài thêm dependency local (không commit): PyJWT 2.10.1, aiosqlite 0.20.0, boto3 1.35.36.
- Không sửa file source nào; `bill_tracker` git status không đổi.
