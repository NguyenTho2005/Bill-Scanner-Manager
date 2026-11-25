# PRD bổ sung — Backend & Cloud Sync cho BillTracker

> Tài liệu này bổ sung cho [PRD.md](PRD.md). Backend là **P1 / opt-in**, không thay đổi cam kết local-first của MVP: người dùng có thể dùng toàn bộ luồng ghi chép cốt lõi khi không có mạng và không tạo tài khoản.

## 1. Bối cảnh và vấn đề cần giải quyết

Ứng dụng hiện lưu toàn bộ dữ liệu trong SQLite/Drift trên từng thiết bị. Đây là nền tảng offline tốt, nhưng chưa có các năng lực sau:

| Khoảng trống | Hệ quả hiện tại |
|---|---|
| Danh tính người dùng và thiết bị | Không thể liên kết dữ liệu giữa điện thoại mới/cũ hoặc nhiều thiết bị. |
| Kho lưu trữ cloud | Ảnh, hóa đơn và CSDL mất khi người dùng mất/xóa thiết bị. |
| Đồng bộ tăng dần, tombstone và giải quyết xung đột | Công tắc “Cloud sync” trong app chưa thực hiện đồng bộ nào. |
| API bảo mật và quyền truy cập | Không có lớp xác thực, giới hạn tốc độ, audit log hay kiểm soát dữ liệu theo user. |
| Hàng đợi xử lý AI cloud | Không có fallback cho hóa đơn khó hoặc khả năng theo dõi trạng thái xử lý. |
| Vận hành production | Không có backup, monitoring, cảnh báo, migration hay quy trình xử lý sự cố. |

## 2. Mục tiêu, không mục tiêu và nguyên tắc

### 2.1. Mục tiêu

1. Cho phép người dùng **tự nguyện** sao lưu và đồng bộ dữ liệu giữa các thiết bị.
2. Bảo đảm dữ liệu offline vẫn hoạt động khi API không khả dụng; sync tự tiếp tục an toàn khi có mạng.
3. Đồng bộ giao dịch, danh mục, ngân sách, kết quả OCR và metadata ảnh; lưu file ảnh trên object storage riêng theo user.
4. Cung cấp cloud OCR/AI theo cơ chế fallback, minh bạch và có sự đồng ý rõ ràng trước khi gửi ảnh lên cloud.
5. Cho phép export và xóa hoàn toàn dữ liệu cloud theo yêu cầu người dùng.

### 2.2. Không mục tiêu của bản P1

- Liên kết/tự động nhập giao dịch ngân hàng, ví điện tử hoặc thẻ.
- Chia sẻ ví gia đình, phân quyền nhiều người, thanh toán hoặc subscription.
- Đồng bộ realtime bắt buộc bằng WebSocket.
- Dùng ảnh/hóa đơn của người dùng để huấn luyện mô hình khi chưa có opt-in riêng.

### 2.3. Nguyên tắc bắt buộc

- **Offline-first:** local DB là nguồn dữ liệu để UI đọc/ghi; server chỉ là bản sao đồng bộ.
- **Opt-in và có thể đảo ngược:** không tạo tài khoản hay upload dữ liệu cho tới khi người dùng bật Cloud Sync và xác nhận.
- **Least data:** chỉ upload ảnh gốc khi người dùng chọn giữ/backup ảnh gốc; mặc định upload ảnh nén và thumbnail nếu bật backup media.
- **Idempotent:** gửi lại cùng một thay đổi không được tạo bản ghi trùng.
- **Không tin client:** mọi truy vấn phải giới hạn theo `user_id` lấy từ access token, không nhận `userId` từ body.

## 3. Personas và user stories

| ID | User story | Ưu tiên |
|---|---|---:|
| BE-01 | Là người dùng, tôi muốn đăng nhập để khôi phục dữ liệu khi đổi điện thoại. | P1 |
| BE-02 | Tôi muốn bật/tắt sync và chọn có backup ảnh gốc hay không. | P1 |
| BE-03 | Tôi muốn tạo/sửa/xóa giao dịch khi offline; app tự đồng bộ khi có mạng. | P1 |
| BE-04 | Tôi muốn biết lần sync gần nhất, lỗi nào đang chờ và có thể thử lại. | P1 |
| BE-05 | Tôi muốn xóa tài khoản cùng toàn bộ dữ liệu cloud không quá 30 ngày. | P1 |
| BE-06 | Tôi muốn gửi hóa đơn khó lên cloud OCR chỉ sau khi được giải thích rõ dữ liệu nào sẽ được gửi. | P2 |
| BE-07 | Là vận hành viên, tôi muốn theo dõi lỗi sync/OCR mà không xem nội dung tài chính hoặc ảnh thô. | P1 |

## 4. Phạm vi phát hành backend

### Release P1 — Cloud Backup & Sync

- Auth: Sign in with Apple (iOS), Google (Android), email magic link tùy thị trường; có thể ẩn auth hoàn toàn nếu người dùng chọn local-only.
- Đăng ký thiết bị và quản lý session/refresh token.
- Đồng bộ một chiều hai pha: client push thay đổi cục bộ, rồi pull thay đổi từ server theo cursor.
- Object storage bằng pre-signed URL cho ảnh nén/thumbnail và ảnh gốc khi có consent.
- Xung đột last-write-wins theo `updated_at_server`; xóa dùng tombstone.
- Trang trạng thái sync trong app: last successful sync, số thay đổi chờ, retry, lỗi có thể hiểu được.
- Export cloud và xoá tài khoản/dữ liệu.

### Release P2 — Cloud OCR/AI fallback

- Tạo job OCR async từ file media đã upload; trả `jobId`, client poll trạng thái.
- Cache kết quả theo hash + model version, nhưng chỉ trong phạm vi cùng user trừ khi có opt-in dữ liệu riêng.
- Confidence, model version, latency và cờ `requiresReview`; kết quả AI không được tự ghi đè trường người dùng đã sửa.

### Release P3 — Tối ưu vận hành

- Push notification đa thiết bị cho cảnh báo ngân sách.
- Realtime sync tùy chọn, quota/storage plan, dashboard support đã che/mã hóa dữ liệu nhạy cảm.

## 5. Kiến trúc đề xuất

```text
Flutter app (Drift local DB + outbox) ── HTTPS/OAuth ── API service
           │                                               ├─ PostgreSQL (metadata + sync log)
           │                                               ├─ Object storage (ảnh mã hóa)
           │                                               ├─ Queue/worker (OCR, thumbnail, cleanup)
           │                                               └─ Observability (logs, metrics, traces)
           └──────── pre-signed upload/download URL ──────┘
```

| Thành phần | Trách nhiệm | Yêu cầu tối thiểu |
|---|---|---|
| API service | Auth middleware, sync, metadata media, account/privacy endpoints | REST JSON, version `/v1`, validation schema, rate limit. |
| PostgreSQL | Dữ liệu tài khoản, entity canonical, revision/sync log, tombstone, job state | Managed DB, migration có version, encrypted at rest, backup point-in-time. |
| Object storage | File nén, thumbnail, ảnh gốc nếu được phép | Bucket private, SSE/KMS, pre-signed URL ngắn hạn, lifecycle deletion. |
| Queue/worker | OCR cloud và các tác vụ chậm | Retry có backoff, dead-letter queue, idempotency key. |
| Identity provider | OIDC/OAuth và token rotation | Xác thực Apple/Google server-side; không tin token từ client nếu chưa verify. |
| Monitoring | Vận hành mà không thu raw financial data | Sentry/OTel, metric aggregate, alert lỗi/latency/quota. |

Có thể bắt đầu bằng modular monolith (một API service + một worker) thay vì tách microservice. Tách Media/OCR/Sync chỉ khi tải và đội ngũ đòi hỏi; API contract không thay đổi.

## 6. Mô hình dữ liệu cloud và thay đổi bắt buộc ở local DB

### 6.1. Bảng cloud cốt lõi

| Bảng | Trường chính | Ghi chú |
|---|---|---|
| `users` | `id`, `created_at`, `deleted_at` | Không lưu thông tin profile không cần thiết. |
| `auth_identities` | `user_id`, `provider`, `provider_subject` | Unique `(provider, provider_subject)`. |
| `devices` | `id`, `user_id`, `name`, `platform`, `last_seen_at`, `revoked_at` | Không dùng hardware identifier ổn định. |
| `transactions`, `categories`, `budgets` | `id`, `user_id`, payload domain, `revision`, `updated_at`, `deleted_at` | Mỗi bảng phải có `user_id`; xoá mềm phục vụ sync. |
| `media` | `id`, `user_id`, `transaction_id`, `object_key`, `content_hash`, `size_bytes`, `state` | Không public object key/URL lâu dài. |
| `receipt_extractions`, `receipt_line_items`, `ai_inferences` | IDs domain, `user_id`, `revision`, `updated_at`, `deleted_at` | Result AI có provenance/model version. |
| `change_log` | `sequence`, `user_id`, `entity_type`, `entity_id`, `operation`, `revision`, `changed_at` | Nguồn cho pull theo cursor; index `(user_id, sequence)`. |
| `sync_idempotency` | `user_id`, `device_id`, `operation_id`, `response_hash`, `expires_at` | Ngăn duplicate khi retry. |
| `ocr_jobs` | `id`, `user_id`, `media_id`, `status`, `attempt`, `error_code` | Không đưa raw image/OCR text vào log. |

### 6.2. Migration local DB cần thêm

Schema Drift hiện có `createdAt`/`updatedAt` ở `Transactions`, nhưng các entity khác chưa đủ metadata sync và không có tombstone/outbox. Bản migration tiếp theo cần thêm vào **mọi entity đồng bộ**:

```text
sync_revision       INTEGER NOT NULL DEFAULT 0
sync_updated_at     DATETIME NOT NULL
sync_deleted_at     DATETIME NULL
sync_state          TEXT NOT NULL  -- clean | pending | syncing | failed | conflict
last_synced_at      DATETIME NULL
```

Thêm hai bảng local:

- `sync_outbox`: `operation_id`, `entity_type`, `entity_id`, `operation`, `payload_json`, `base_revision`, `created_at`, `retry_count`, `last_error`.
- `sync_metadata`: `device_id`, `cursor`, `last_success_at`, `last_error`, `media_backup_policy`, `cloud_sync_consent_at`.

Mỗi mutation local phải ghi entity **và** outbox trong cùng transaction Drift. Không gọi network trực tiếp từ màn hình UI.

## 7. Quy tắc đồng bộ và xung đột

1. Client tạo UUID v7/ULID cho entity và `operationId` bất biến trước khi ghi local.
2. Khi online: gửi batch outbox theo thứ tự tạo, tối đa 100 operation hoặc 1 MB/batch.
3. Server xác thực token, quyền user/device, idempotency và `baseRevision`; ghi entity + `change_log` trong một DB transaction.
4. Client đánh dấu operation đã acknowledge; tiếp tục pull từ `cursor` gần nhất cho tới khi trống.
5. Khi `baseRevision` cũ: server trả `409 sync_conflict` với bản server và revision. Client tự áp dụng quy tắc hoặc mở UI review.

| Loại thay đổi | Quy tắc P1 |
|---|---|
| Sửa các field đơn giản của transaction/budget/category | Last-write-wins theo server receive time; client hiển thị thông báo nếu bản local bị thay. |
| Hai thiết bị sửa field khác nhau | P2 mới làm field-level merge; P1 dùng whole-record LWW để đơn giản và có audit. |
| Xóa entity | Tombstone thắng update cũ hơn; giữ tối thiểu 30 ngày trước purge. |
| Khôi phục entity | Tạo operation `upsert` mới với revision cao hơn; không âm thầm hồi sinh tombstone cũ. |
| File media | Content-addressable theo hash trong user scope; upload idempotent; metadata chỉ `ready` sau khi object xác nhận tồn tại. |

## 8. API contract P1

Tất cả endpoint trừ auth callback dùng `Authorization: Bearer <access_token>`, JSON UTF-8, UTC ISO-8601, và trả lỗi chuẩn:

```json
{
  "error": {
    "code": "sync_conflict",
    "message": "The item changed on another device.",
    "requestId": "req_...",
    "retryable": false
  }
}
```

### 8.1. Account và device

| Method | Path | Mục đích |
|---|---|---|
| `POST` | `/v1/auth/exchange` | Đổi authorization code/token của IdP lấy session app. |
| `POST` | `/v1/devices` | Đăng ký logical device; trả `deviceId`. |
| `DELETE` | `/v1/devices/{deviceId}` | Thu hồi thiết bị/session. |
| `GET` | `/v1/me/export` | Tạo export job hoặc pre-signed download URL. |
| `DELETE` | `/v1/me` | Yêu cầu xóa cloud account và dữ liệu; yêu cầu re-auth. |

### 8.2. Sync

`POST /v1/sync/push`

```json
{
  "deviceId": "dev_01J...",
  "operations": [
    {
      "operationId": "op_01J...",
      "entityType": "transaction",
      "entityId": "tx_01J...",
      "operation": "upsert",
      "baseRevision": 4,
      "occurredAt": "2026-09-12T08:30:00Z",
      "payload": {
        "type": "expense",
        "amount": 45000,
        "currency": "VND",
        "categoryId": "food_drinks",
        "merchant": "Highlands Coffee",
        "note": "Cà phê sáng",
        "status": "confirmed"
      }
    }
  ]
}
```

```json
{
  "acknowledged": [
    { "operationId": "op_01J...", "entityId": "tx_01J...", "revision": 5 }
  ],
  "conflicts": [],
  "serverCursor": "seq_000000000291"
}
```

`GET /v1/sync/pull?cursor=seq_000000000291&limit=200`

```json
{
  "changes": [
    {
      "entityType": "budget",
      "entityId": "budget_01J...",
      "operation": "upsert",
      "revision": 3,
      "updatedAt": "2026-09-12T09:00:00Z",
      "payload": { "categoryId": "food_drinks", "amountLimit": 3000000 }
    }
  ],
  "nextCursor": "seq_000000000292",
  "hasMore": false
}
```

`GET /v1/sync/bootstrap` trả snapshot đã phân trang cho thiết bị mới. Không dùng cursor rỗng để tải toàn bộ dữ liệu vô hạn.

### 8.3. Media

| Method | Path | Mục đích |
|---|---|---|
| `POST` | `/v1/media/upload-intents` | Validate metadata/quota, tạo media record và pre-signed PUT URL. |
| `POST` | `/v1/media/{id}/complete` | Xác nhận upload, kiểm MIME/size/hash server-side và đưa media vào sync. |
| `GET` | `/v1/media/{id}/download-intent` | Cấp URL tải private, hết hạn ngắn. |
| `DELETE` | `/v1/media/{id}` | Tombstone metadata, xếp job xóa object. |

Client không được gửi ảnh nhị phân qua API app server nếu pre-signed upload khả dụng. Server giới hạn MIME `image/jpeg`, `image/png`, `image/heic`, kích cỡ theo plan và quét magic bytes, không chỉ tin Content-Type.

### 8.4. OCR cloud P2

| Method | Path | Mục đích |
|---|---|---|
| `POST` | `/v1/ocr/jobs` | Tạo job từ `mediaId`, sau consent. |
| `GET` | `/v1/ocr/jobs/{id}` | Poll `queued`, `processing`, `completed`, `failed`. |
| `DELETE` | `/v1/ocr/jobs/{id}` | Hủy khi chưa chạy. |

## 9. Bảo mật, privacy và compliance

| Chủ đề | Yêu cầu acceptance |
|---|---|
| Transport | TLS 1.2+; HSTS; không log access token, pre-signed URL hoặc payload OCR thô. |
| Authorization | Server áp row-level ownership check cho mọi `entityId`, object key và job; test IDOR bắt buộc. |
| Encryption | Managed encryption at rest cho Postgres/object storage; secret trong KMS/secret manager, không commit `.env`. |
| Token | Access token ngắn hạn, refresh token rotation và revoke khi logout/xóa device. |
| Media | Bucket private; URL time-limited; validate file, quota và chống upload bomb; lifecycle cleanup. |
| Consent | Tách consent: cloud sync, backup media, backup ảnh gốc, cloud OCR/AI, analytics. Ghi thời điểm/policy version. |
| Deletion | Xóa tài khoản xóa token ngay; xóa metadata/object/backup tối đa 30 ngày trừ khi luật áp dụng yêu cầu khác; tombstone sync không được public. |
| Data residency | Chọn region và công bố trong privacy policy trước launch. |
| Abuse | Rate limit theo user/device/IP, WAF, CAPTCHA/challenge phù hợp trên endpoint auth. |

Không có cloud account thì không có lý do để thu email, analytics định danh hay identifier quảng cáo. Nếu tích hợp SDK analytics/crash reporting, cập nhật Privacy Policy, App Store Privacy và Google Play Data Safety trước release.

## 10. Non-functional requirements và SLO

| Hạng mục | Mục tiêu P1 |
|---|---:|
| API sync availability | 99.9%/tháng, không tính planned maintenance đã báo trước. |
| `push` p95 | < 500 ms với batch <= 100 operations, không gồm upload media. |
| `pull` p95 | < 700 ms với 200 changes. |
| Upload | Resume/retry ở client; URL hết hạn <= 15 phút. |
| RPO / RTO | RPO <= 24 giờ, RTO <= 4 giờ ở launch; kiểm tra restore mỗi quý. |
| OCR P2 | 95% job hoàn thành <= 15 giây với hóa đơn rõ; trả lỗi cụ thể khi không thể xử lý. |
| Observability | 100% request có request ID; dashboard error rate, latency, queue depth, sync conflict rate, storage usage. |

## 11. Acceptance criteria

```gherkin
Scenario: Đồng bộ khi offline rồi online
  Given người dùng đã bật Cloud Sync trên hai thiết bị
  And thiết bị A đang offline
  When người dùng tạo một giao dịch confirmed trên thiết bị A
  And thiết bị A có Internet trở lại
  Then giao dịch phải được đẩy từ outbox với một operationId bất biến
  And thiết bị B phải thấy giao dịch sau lần pull tiếp theo
  And gửi lại cùng operationId không được tạo giao dịch trùng

Scenario: Xóa không bị hồi sinh
  Given giao dịch T đã được đồng bộ ở revision 5
  When thiết bị A xóa T khi online và server tạo tombstone revision 6
  And thiết bị B sau đó push bản sửa offline dựa trên revision 5
  Then server phải trả sync_conflict hoặc áp tombstone
  And T không được tự xuất hiện lại trên thiết bị A

Scenario: Local-only
  Given người dùng chưa đồng ý Cloud Sync
  When người dùng tạo giao dịch và chụp hóa đơn
  Then không có request auth, sync, upload media hay cloud OCR nào được gửi

Scenario: Xóa tài khoản
  Given người dùng đã re-authenticate thành công
  When người dùng xác nhận xóa account
  Then session và pre-signed URLs phải bị thu hồi ngay
  And dữ liệu cloud phải được xếp hàng xóa và hoàn tất trong SLA công bố
```

## 12. Kế hoạch triển khai và Definition of Done

| Sprint | Deliverables |
|---|---|
| 0 — Foundation | Chọn cloud/region, threat model, OpenAPI, IaC, CI/CD, environments dev/staging/prod. |
| 1 — Identity & schema | Auth provider, users/devices, Postgres migrations, token middleware, ownership tests. |
| 2 — Sync core | Local migration/outbox, push/pull/bootstrap, idempotency, cursor, tombstone, conflict UI. |
| 3 — Media & privacy | Private storage, upload intent/complete/download, quota, consent UX, export/delete account. |
| 4 — Reliability | Worker/queue, backups/restore drill, monitoring/alerting, load/security tests, closed beta. |
| 5 — OCR P2 | Async cloud OCR, consent gate, job state/retry, quality and cost monitoring. |

Backend P1 chỉ được coi là hoàn thành khi:

- Tất cả thao tác CRUD đồng bộ được từ hai thiết bị thật, qua offline/retry/duplicate request/xung đột/xóa.
- Không tồn tại cross-user data access trong automated authorization test.
- Một user có thể export và yêu cầu xoá dữ liệu cloud mà không cần support can thiệp.
- Dashboard, alert, backup và restore drill đã được chạy ở staging trước beta.
- Mobile hiển thị đúng trạng thái sync; không hiển thị “đã đồng bộ” nếu outbox còn lỗi/chờ.
