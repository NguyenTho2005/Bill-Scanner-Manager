# PRD — Visual Expense Tracker & Smart Receipt Scanner

## 1. Tổng quan dự án

### 1.1. Tên sản phẩm

**Visual Expense Tracker & Smart Receipt Scanner**  
Ứng dụng di động quản lý tài chính cá nhân qua hình ảnh: chụp món đồ hoặc quét hóa đơn để ghi nhận giao dịch nhanh, trực quan và riêng tư.

### 1.2. Problem Statement

Người dùng thường bỏ sử dụng ứng dụng quản lý chi tiêu vì:

- Nhập giao dịch thủ công mất thời gian và gây gián đoạn sau mỗi lần mua sắm.
- Danh sách giao dịch dạng chữ/số khô khan, khó tạo cảm xúc và thói quen.
- Khi xem lại lịch sử, người dùng không nhớ rõ khoản chi đó dùng để mua gì.
- Hóa đơn và ảnh sản phẩm bị phân tán trong thư viện ảnh, khó đối soát.

### 1.3. Product Vision

Biến camera điện thoại thành cổng nhập liệu tài chính tức thì. Mỗi khoản chi được lưu bằng ảnh thực tế của món hàng hoặc hóa đơn, sau đó được AI tự động bóc tách, phân loại và trình bày như một nhật ký hình ảnh về dòng tiền.

### 1.4. Core Value Proposition

| Giá trị | Cam kết sản phẩm |
|---|---|
| Nhanh | Hoàn tất ghi nhận giao dịch phổ biến trong dưới 5 giây |
| Trực quan | Xem chi tiêu bằng Photo Grid/Visual Feed thay vì chỉ số liệu |
| Thông minh | AI tự gợi ý danh mục, số tiền, cửa hàng và sản phẩm |
| Riêng tư | Không bắt buộc liên kết tài khoản ngân hàng; hỗ trợ local-only |
| Hữu ích | Dễ nhớ mình đã mua gì, đối soát hóa đơn và kiểm soát ngân sách |

### 1.5. Phạm vi MVP

MVP tập trung vào các chức năng tạo thói quen ghi chi tiêu:

1. Chụp món đồ và tạo giao dịch.
2. Quét hóa đơn, bóc tách tổng tiền và thông tin cơ bản.
3. Visual Feed, lọc và tìm kiếm giao dịch.
4. Ngân sách theo danh mục và cảnh báo vượt ngưỡng.
5. Lưu local-first, khóa ứng dụng bằng sinh trắc học/PIN.

Ngoài phạm vi MVP:

- Đồng bộ tài khoản ngân hàng tự động.
- Chia sẻ ngân sách gia đình/nhóm.
- Đầu tư, vay nợ, quản lý tài sản.
- Tự động hạch toán kép hoặc hỗ trợ kế toán doanh nghiệp đầy đủ.

### 1.6. KPIs

| Nhóm | Chỉ số | Mục tiêu ban đầu |
|---|---|---:|
| Activation | Người dùng hoàn tất giao dịch đầu tiên | ≥ 65% người cài mới |
| Tốc độ | Median time-to-log | < 5 giây với Product Snap |
| AI | Độ chính xác danh mục top-1 | ≥ 80% |
| OCR | Độ chính xác tổng tiền sau xác thực | ≥ 90% |
| OCR | Tỷ lệ nhận diện đúng merchant/date/total | ≥ 80% |
| Engagement | Số giao dịch qua camera/WAU | ≥ 5 |
| Retention | D1 / D7 / D30 | 40% / 25% / 12% |
| Budget | Tỷ lệ người thiết lập ít nhất một ngân sách | ≥ 30% |

---

## 2. Personas và Use Cases

### Persona 1 — Người dùng trẻ, thiên về hình ảnh

**Tên mẫu:** Linh, 23 tuổi, nhân viên văn phòng.  
**Hành vi:** Mua cà phê, ăn ngoài, đặt đồ online, đi chơi cuối tuần.  
**Nhu cầu:** Nhập chi tiêu cực nhanh, xem lại “tháng này mình đã tiêu vào những gì”.  
**Pain point:** Không duy trì được việc nhập số liệu thủ công.

**Use cases:**

- Chụp ly cà phê, nhập nhanh 45.000đ, app tự gán “Ăn uống > Đồ uống”.
- Chụp ảnh một đôi giày mới mua, lưu thành giao dịch “Mua sắm”.
- Cuối tháng xem Photo Grid để nhận ra chi tiêu ăn ngoài quá nhiều.

### Persona 2 — Freelancer/người bán hàng nhỏ

**Tên mẫu:** Minh, 31 tuổi, freelancer thiết kế.  
**Hành vi:** Có nhiều chi phí dịch vụ, vật tư, đi lại và cần đối soát hóa đơn.  
**Nhu cầu:** Lưu hóa đơn, ảnh hàng hóa và tra cứu nhanh khi cần.  
**Pain point:** Hóa đơn giấy dễ mất, ảnh chụp nằm rải rác trong gallery.

**Use cases:**

- Quét hóa đơn internet, app trích xuất nhà cung cấp, ngày và tổng tiền.
- Lưu ảnh món hàng đã nhập để dễ đối chiếu về sau.
- Lọc toàn bộ “Công việc” hoặc “Dịch vụ” trong một tháng.

---

## 3. Mô hình dữ liệu cốt lõi

| Entity | Trường chính |
|---|---|
| `Transaction` | id, type, amount, currency, categoryId, merchant, occurredAt, note, paymentMethod, source, status |
| `TransactionMedia` | id, transactionId, type, originalPath, compressedPath, thumbnailPath, hash, metadata |
| `ReceiptExtraction` | transactionId, merchant, date, total, subtotal, tax, paymentMethod, confidence, rawText |
| `ReceiptLineItem` | id, transactionId, name, quantity, unitPrice, total, categorySuggestion |
| `Category` | id, parentId, name, icon, color, isSystem |
| `Budget` | id, categoryId, period, amountLimit, spentAmount, alertThreshold |
| `AIInference` | id, mediaId, modelVersion, labels, suggestedCategory, extractedAmounts, confidence |

**Nguồn giao dịch (`source`):** `product_snap`, `receipt_scan`, `manual`, `import`.  
**Trạng thái (`status`):** `draft`, `confirmed`, `needs_review`, `failed`.

---

## 4. Functional Requirements

## Module 1 — Product Snap to Expense

### Mục tiêu

Cho phép người dùng chụp ảnh món đồ, sản phẩm, menu hoặc nhãn giá để tạo giao dịch chi tiêu với số bước tối thiểu.

### User Stories

| ID | User Story | Ưu tiên |
|---|---|---|
| PS-01 | Là người dùng, tôi muốn chụp ảnh món đồ để tạo nhanh một khoản chi. | P0 |
| PS-02 | Tôi muốn app tự gợi ý danh mục từ ảnh để không phải chọn thủ công. | P0 |
| PS-03 | Tôi muốn nhập số tiền qua numpad ngay sau khi chụp. | P0 |
| PS-04 | Tôi muốn app tự đọc giá nếu ảnh có nhãn giá/menu. | P1 |
| PS-05 | Tôi muốn lưu ảnh chất lượng phù hợp nhưng không tốn nhiều dung lượng. | P0 |
| PS-06 | Tôi muốn sửa đề xuất AI trước khi lưu giao dịch. | P0 |

### Flow xử lý

1. Người dùng nhấn nút Camera/“Thêm giao dịch”.
2. Chọn **Chụp sản phẩm**.
3. Camera mở; người dùng chụp hoặc chọn ảnh từ thư viện.
4. Ứng dụng nén ảnh tại thiết bị, tạo thumbnail và chạy phân loại ảnh.
5. UI hiển thị preview, danh mục AI gợi ý, merchant gợi ý nếu có, và numpad nhập tiền.
6. Nếu phát hiện nhãn giá/menu, app điền số tiền với nhãn “AI đề xuất”.
7. Người dùng xác nhận/chỉnh sửa số tiền, danh mục, thời gian và ghi chú.
8. App lưu giao dịch local-first; đồng bộ cloud nếu người dùng bật Sync.

### Quy tắc nghiệp vụ

- Số tiền là trường bắt buộc để xác nhận giao dịch.
- Danh mục mặc định là `Khác` nếu confidence thấp hơn ngưỡng cấu hình, ví dụ 0.65.
- Giá AI đọc từ ảnh không được tự xác nhận; luôn hiển thị để người dùng kiểm tra.
- Ảnh gốc chỉ lưu nếu người dùng bật “Giữ ảnh gốc”; mặc định lưu bản nén.
- Một ảnh chỉ tạo một giao dịch trong MVP, nhưng có thể gắn thêm ảnh vào giao dịch hiện có.

### Acceptance Criteria

```gherkin
Scenario: Tạo giao dịch từ ảnh sản phẩm
  Given người dùng đã cho phép sử dụng camera
  When người dùng chụp một ảnh sản phẩm và nhập số tiền hợp lệ
  Then ứng dụng phải tạo một giao dịch ở trạng thái confirmed
  And giao dịch phải chứa ảnh thumbnail
  And giao dịch phải xuất hiện trong Visual Feed

Scenario: AI gợi ý danh mục
  Given ảnh sản phẩm đã được xử lý AI thành công
  When confidence của danh mục gợi ý lớn hơn hoặc bằng 0.65
  Then ứng dụng phải hiển thị danh mục được gợi ý
  And người dùng có thể thay đổi danh mục trước khi lưu

Scenario: Không nhận diện được giá
  Given AI không phát hiện số tiền đáng tin cậy trong ảnh
  When màn hình xác nhận giao dịch hiển thị
  Then numpad phải tự động được focus
  And người dùng vẫn có thể hoàn tất giao dịch thủ công
```

---

## Module 2 — Bill & Receipt OCR Scanner

### Mục tiêu

Quét hóa đơn giấy, hóa đơn điện tử hoặc ảnh chụp màn hình thanh toán để tạo giao dịch có dữ liệu cấu trúc.

### User Stories

| ID | User Story | Ưu tiên |
|---|---|---|
| OCR-01 | Tôi muốn app tự nhận diện viền hóa đơn và cắt ảnh. | P0 |
| OCR-02 | Tôi muốn app đọc tên cửa hàng, ngày và tổng tiền. | P0 |
| OCR-03 | Tôi muốn xem/sửa các trường AI nhận diện sai. | P0 |
| OCR-04 | Tôi muốn app đọc danh sách món hàng khi hóa đơn đủ rõ. | P1 |
| OCR-05 | Tôi muốn quét ảnh chụp màn hình chuyển khoản/e-receipt. | P1 |
| OCR-06 | Tôi muốn lưu ảnh hóa đơn để đối soát sau này. | P0 |

### Flow xử lý

1. Người dùng chọn **Quét hóa đơn**.
2. Camera nhận diện cạnh tài liệu theo thời gian thực.
3. Người dùng chụp; app tự crop, de-skew, tăng tương phản và giảm nhiễu.
4. OCR engine chạy on-device hoặc cloud theo mức độ phức tạp.
5. Parser chuẩn hóa dữ liệu: merchant, date, total, currency, line items, payment method.
6. Màn hình Review hiển thị overlay vùng OCR và form chỉnh sửa.
7. Người dùng chạm vào một trường để sửa trực tiếp hoặc chọn lại vùng ảnh.
8. Khi xác nhận, app tạo `Transaction` và các `ReceiptLineItem`.

### Quy tắc nghiệp vụ

- `total` là trường bắt buộc để lưu giao dịch OCR.
- Nếu nhiều số tiền được nhận diện, ưu tiên theo thứ tự: `Grand Total` > `Total` > số tiền lớn nhất gần cuối hóa đơn.
- Receipt OCR confidence thấp hơn 0.70 phải được đánh dấu `needs_review`.
- Với ảnh chụp màn hình chuyển khoản, app ưu tiên parse: người nhận, số tiền, thời gian, nội dung giao dịch.
- Line items chỉ lưu khi confidence từng dòng đủ cao hoặc người dùng xác nhận.

### Acceptance Criteria

```gherkin
Scenario: Quét hóa đơn rõ nét
  Given người dùng chụp hóa đơn có đủ ánh sáng
  When OCR hoàn tất
  Then hệ thống phải hiển thị merchant, ngày giao dịch và tổng tiền
  And người dùng phải có thể sửa từng trường trước khi xác nhận

Scenario: OCR có confidence thấp
  Given OCR không xác định được tổng tiền với confidence từ 0.70 trở lên
  When kết quả được trả về
  Then giao dịch không được tự động xác nhận
  And ứng dụng phải yêu cầu người dùng nhập hoặc xác thực tổng tiền

Scenario: Chỉnh sửa dữ liệu từ ảnh
  Given người dùng đang ở màn hình review hóa đơn
  When người dùng chạm vào trường tổng tiền
  Then ứng dụng phải cho phép sửa giá trị
  And giá trị đã sửa phải được dùng khi lưu giao dịch
```

---

## Module 3 — Visual Transaction Timeline

### Mục tiêu

Cung cấp trải nghiệm xem lịch sử giao dịch như một nhật ký hình ảnh, giúp người dùng nhớ rõ ngữ cảnh chi tiêu.

### User Stories

| ID | User Story | Ưu tiên |
|---|---|---|
| VF-01 | Tôi muốn xem giao dịch theo dạng lưới ảnh. | P0 |
| VF-02 | Tôi muốn chuyển giữa Visual Feed và List View. | P0 |
| VF-03 | Tôi muốn lọc theo danh mục, thời gian và loại ảnh. | P0 |
| VF-04 | Tôi muốn xem chi tiết khi chạm vào một ảnh. | P0 |
| VF-05 | Tôi muốn gắn giao dịch vào sự kiện như Du lịch/Sinh nhật. | P1 |
| VF-06 | Tôi muốn tìm lại giao dịch bằng merchant hoặc ghi chú. | P1 |

### Yêu cầu UI

- **Photo Grid:** 2–3 cột tùy kích thước màn hình; thumbnail vuông; hiển thị amount và icon danh mục.
- **Visual Feed:** timeline theo ngày; ảnh lớn hơn, hiển thị merchant, số tiền và danh mục.
- **List View:** fallback cho người dùng thích xem dạng bảng.
- Giao dịch không có ảnh hiển thị card màu danh mục và icon mặc định.
- Chạm vào item mở Transaction Detail: ảnh, metadata, OCR raw data, line items, lịch sử chỉnh sửa.

### Acceptance Criteria

```gherkin
Scenario: Lọc Visual Feed theo danh mục
  Given người dùng có giao dịch ở nhiều danh mục
  When người dùng chọn bộ lọc "Ăn uống"
  Then feed chỉ hiển thị các giao dịch thuộc danh mục Ăn uống và danh mục con

Scenario: Xem chi tiết giao dịch
  Given một giao dịch có ảnh hóa đơn
  When người dùng chạm vào giao dịch trong Photo Grid
  Then ứng dụng phải hiển thị ảnh, số tiền, ngày, merchant và danh mục
  And người dùng có thể chỉnh sửa hoặc xóa giao dịch
```

---

## Module 4 — Budget & Visual Reports

### Mục tiêu

Chuyển dữ liệu giao dịch thành insight dễ hiểu, gắn với hình ảnh và thói quen chi tiêu thực tế.

### User Stories

| ID | User Story | Ưu tiên |
|---|---|---|
| BR-01 | Tôi muốn đặt ngân sách tháng theo danh mục. | P0 |
| BR-02 | Tôi muốn nhận cảnh báo khi gần hoặc vượt ngân sách. | P0 |
| BR-03 | Tôi muốn xem top khoản chi lớn bằng hình ảnh. | P1 |
| BR-04 | Tôi muốn so sánh chi tiêu tháng hiện tại với tháng trước. | P1 |

### Yêu cầu báo cáo

- Tổng chi theo ngày/tuần/tháng.
- Donut chart theo danh mục.
- Top 5 giao dịch lớn nhất kèm thumbnail.
- Trend tháng hiện tại so với tháng trước.
- Tiến độ ngân sách: `đã chi / hạn mức`.
- Cảnh báo mặc định tại 80%, 100% và 120%; người dùng có thể tùy chỉnh.

### Acceptance Criteria

```gherkin
Scenario: Cảnh báo gần vượt ngân sách
  Given người dùng có ngân sách Ăn uống là 3.000.000đ mỗi tháng
  And mức cảnh báo là 80%
  When tổng chi Ăn uống đạt 2.400.000đ
  Then ứng dụng phải gửi thông báo cảnh báo một lần trong chu kỳ ngân sách

Scenario: Vượt ngân sách
  Given người dùng đã đặt ngân sách cho một danh mục
  When tổng chi vượt giới hạn ngân sách
  Then ứng dụng phải hiển thị trạng thái vượt ngân sách trong dashboard
  And phải ghi nhận sự kiện analytics budget_exceeded
```

---

## Module 5 — Storage, Privacy & Security

### Mục tiêu

Cho người dùng quyền kiểm soát dữ liệu tài chính và ảnh cá nhân.

### Chức năng

| Tính năng | Mô tả | Ưu tiên |
|---|---|---|
| Local-first | Toàn bộ dữ liệu hoạt động offline trên thiết bị. | P0 |
| Optional Cloud Sync | Đồng bộ đa thiết bị khi người dùng chủ động bật. | P1 |
| Biometric Lock | Face ID, Touch ID hoặc Android Biometric Prompt. | P0 |
| PIN fallback | PIN cục bộ khi sinh trắc học không khả dụng. | P0 |
| Export data | Xuất CSV/JSON và ảnh đính kèm theo phạm vi chọn. | P1 |
| Delete data | Xóa giao dịch, ảnh hoặc toàn bộ dữ liệu theo yêu cầu. | P0 |

### Acceptance Criteria

```gherkin
Scenario: Chế độ local-only
  Given người dùng chưa bật Cloud Sync
  When người dùng tạo giao dịch mới
  Then dữ liệu phải được lưu và truy xuất khi offline
  And không có yêu cầu đồng bộ dữ liệu tài chính lên cloud

Scenario: Khóa sinh trắc học
  Given người dùng đã bật khóa ứng dụng
  When ứng dụng được mở lại sau thời gian timeout
  Then ứng dụng phải yêu cầu xác thực sinh trắc học hoặc PIN
  And không được hiển thị số dư hay ảnh giao dịch trước khi xác thực thành công
```

---

## 5. API Specifications cơ bản

### 5.1. Tạo giao dịch

`POST /v1/transactions`

```json
{
  "type": "expense",
  "amount": 45000,
  "currency": "VND",
  "categoryId": "food_drinks",
  "merchant": "Highlands Coffee",
  "occurredAt": "2026-09-09T08:30:00+07:00",
  "paymentMethod": "cash",
  "source": "product_snap",
  "note": "Cà phê sáng",
  "mediaIds": ["media_123"]
}
```

### 5.2. Tải ảnh lên

`POST /v1/media/upload`

| Field | Kiểu | Bắt buộc | Ghi chú |
|---|---|---:|---|
| file | binary | Có | JPEG, HEIC, PNG |
| mediaType | enum | Có | `product`, `receipt`, `screenshot` |
| localHash | string | Có | Phục vụ chống upload trùng |
| keepOriginal | boolean | Không | Mặc định `false` |

### 5.3. Phân tích Product Snap

`POST /v1/vision/product-classify`

```json
{
  "mediaId": "media_123",
  "locale": "vi-VN"
}
```

```json
{
  "suggestedCategory": {
    "id": "food_drinks",
    "label": "Ăn uống / Đồ uống",
    "confidence": 0.88
  },
  "labels": [
    { "name": "coffee", "confidence": 0.94 }
  ],
  "detectedAmounts": [
    { "amount": 45000, "currency": "VND", "confidence": 0.71 }
  ]
}
```

### 5.4. Phân tích hóa đơn

`POST /v1/ocr/receipts`

```json
{
  "mediaId": "media_456",
  "documentType": "receipt",
  "locale": "vi-VN"
}
```

```json
{
  "merchant": { "value": "Co.opmart", "confidence": 0.92 },
  "transactionDate": { "value": "2026-09-08", "confidence": 0.89 },
  "total": { "value": 326500, "currency": "VND", "confidence": 0.95 },
  "paymentMethod": { "value": "cash", "confidence": 0.67 },
  "lineItems": [
    {
      "name": "Sữa tươi",
      "quantity": 2,
      "total": 72000,
      "confidence": 0.82
    }
  ],
  "requiresReview": false
}
```

### 5.5. Đồng bộ dữ liệu

`POST /v1/sync/changes`

- Client gửi các bản ghi thay đổi từ local database.
- Server trả về thay đổi mới nhất theo `cursor`.
- Chiến lược conflict: ưu tiên `updatedAt` mới hơn; với trường nhạy cảm như xóa giao dịch, áp dụng tombstone để tránh khôi phục ngoài ý muốn.

---

## 6. Kiến trúc kỹ thuật đề xuất

| Layer | Đề xuất |
|---|---|
| Mobile | Flutter hoặc React Native; native modules cho Camera, ML Kit, Biometric và image processing |
| Local storage | SQLite/Drift hoặc Realm; mã hóa dữ liệu cục bộ |
| On-device AI | ML Kit Text Recognition, image labeling/model TensorFlow Lite hoặc Core ML |
| Cloud AI | OCR/Vision API cho ảnh khó, parser hóa đơn tiếng Việt, phân loại nâng cao |
| Backend | REST API, service tách riêng Media, OCR, Transaction và Sync |
| Storage | Object storage mã hóa; lưu thumbnail, bản nén và ảnh gốc theo lựa chọn người dùng |
| Analytics | Event tracking tôn trọng consent, không gửi ảnh/hóa đơn thô vào analytics |

### Chiến lược AI phân tầng

1. **On-device trước:** edge detection, crop, compression, OCR cơ bản, image classification nhẹ.
2. **Cloud khi cần:** hóa đơn dài/phức tạp, ảnh mờ, line-item parsing, handwriting OCR cơ bản.
3. **Human-in-the-loop:** mọi dữ liệu tài chính AI trích xuất phải có thể chỉnh sửa rõ ràng trước khi lưu.

---

## 7. Non-Functional Requirements

| Nhóm | Yêu cầu |
|---|---|
| Camera | Mở camera trong < 0.5 giây trên thiết bị mục tiêu |
| Product AI | Gợi ý đầu tiên trong < 1.5 giây ở điều kiện mạng bình thường hoặc on-device |
| OCR | Kết quả cơ bản merchant/date/total trong < 2 giây cho hóa đơn rõ nét |
| Time-to-log | Luồng Product Snap hoàn tất median < 5 giây |
| App size | Binary download mục tiêu < 50 MB, không bao gồm cache người dùng |
| Image compression | Ảnh dài nhất tối đa 2.048 px; JPEG/WebP chất lượng thích ứng |
| Offline | Tạo, xem, sửa, xóa giao dịch không cần Internet |
| Availability | Cloud sync/API mục tiêu 99.9%/tháng |
| Accessibility | Hỗ trợ dynamic font, screen reader, contrast đạt chuẩn cơ bản |
| Privacy | Không dùng ảnh giao dịch để huấn luyện mô hình nếu chưa có opt-in riêng |

---

## 8. Rủi ro kỹ thuật và phương án giảm thiểu

| Rủi ro | Tác động | Giải pháp |
|---|---|---|
| Góc chụp xấu, ngược sáng, nền phức tạp | AI/OCR nhận diện sai | Hướng dẫn camera realtime; blur/glare detection; cho phép crop và chụp lại |
| Hóa đơn nhiệt mờ | Không đọc được total hoặc line items | Contrast enhancement, super-resolution có kiểm soát, fallback nhập tổng tiền |
| Sai phân loại món hàng | Giảm niềm tin vào AI | Hiển thị confidence; cho sửa nhanh; học từ lựa chọn người dùng theo thiết bị/tài khoản |
| Chi phí Cloud Vision | Khó mở rộng unit economics | On-device first, cache theo hash ảnh, chỉ gọi cloud cho ảnh confidence thấp |
| Ảnh chiếm dung lượng | Người dùng tắt ứng dụng | Thumbnail local, nén thích ứng, dọn cache, tùy chọn chỉ lưu ảnh nén |
| Dữ liệu nhạy cảm | Rủi ro pháp lý và uy tín | Mã hóa at-rest/in-transit, consent rõ ràng, local-only, xóa dữ liệu hoàn toàn |
| Không đồng nhất định dạng hóa đơn Việt Nam | OCR parser thiếu ổn định | Xây dựng merchant templates dần; parser dựa trên layout + LLM/Vision fallback |

---

## 9. Analytics Events

| Event | Thuộc tính chính |
|---|---|
| `camera_opened` | mode: product/receipt |
| `photo_captured` | mode, source: camera/gallery |
| `ai_inference_completed` | modelVersion, latencyMs, confidence |
| `ocr_completed` | latencyMs, totalConfidence, requiresReview |
| `transaction_created` | source, categoryId, amountBucket |
| `transaction_edited` | editedFields, source |
| `budget_created` | categoryId, period |
| `budget_threshold_reached` | threshold, categoryId |
| `feed_filter_applied` | filterType, filterValue |
| `sync_enabled` | storagePlan |

Không gửi ảnh, raw OCR text, merchant cụ thể hoặc số tiền chính xác vào analytics trừ khi người dùng đã đồng ý rõ ràng.

---

## 10. Roadmap đề xuất

| Giai đoạn | Thời lượng | Deliverables |
|---|---:|---|
| Discovery & Prototype | 2–3 tuần | User research, prototype camera-to-expense, test usability |
| MVP Foundation | 4 tuần | Local database, transaction CRUD, camera, nén ảnh, biometric lock |
| MVP AI & Visual Feed | 4–6 tuần | Product classification, receipt OCR cơ bản, review UI, Photo Grid |
| Budget & Quality | 3 tuần | Budgets, alerts, reports, analytics, performance tuning |
| Beta | 2–4 tuần | Closed beta, đo OCR accuracy, retention và time-to-log |
| Post-MVP | Liên tục | Cloud sync, line items nâng cao, sự kiện, export, personalization |

---

## 11. Định nghĩa thành công của MVP

MVP được coi là đạt mục tiêu khi:

- Người dùng có thể chụp món đồ và lưu giao dịch trong dưới 5 giây.
- Ít nhất 80% giao dịch Product Snap nhận được danh mục gợi ý hữu ích.
- Tổng tiền trên hóa đơn rõ nét được OCR chính xác từ 90% trở lên sau bước người dùng xác thực.
- Người dùng có thể xem lại lịch sử chi tiêu theo ảnh, lọc theo danh mục/thời gian, và nhận cảnh báo ngân sách.
- Toàn bộ luồng chính vẫn dùng được offline, không yêu cầu liên kết tài khoản ngân hàng.

## Module 6 — Trợ lý chi tiêu (Chatbox)

### Mục tiêu

Đưa BillTracker về gần người dùng hơn bằng một trợ lý nhẹ nhàng về chi tiêu: hỏi đáp dữ liệu hiện có, và ghi giao dịch nhanh bằng ngôn ngữ tự nhiên.

### Đặc điểm đi kèm

- **Bong bóng nổi (floating bubble):** trợ lý luôn sẵn sàng ở góc phải màn hình chính, kéo thả được và tự bám cạnh gần nhất; chạm để mở popup chat. Bubble hiển thị badge khi có câu trả lời mới trong lúc đóng popup.
- **Offline mặc định:** câu trả lời cho "tổng chi tháng này", "top 5 khoản chi", "chi tiêu theo danh mục", "ngân sách còn lại", "so với tháng trước" được tính trên thiết bị từ Drift/SQLite (Drift có `schemaVersion` 2, bảng `chat_messages` cho lịch sử hội thoại).
- **Tạo giao dịch qua chat:** `cà phê 45k` / `grab 60k hôm qua` → tạo draft với xác nhận; không tự động chạy mục tiêu an toàn.
- **Cloud AI tuỳ chọn:** bật trong popup trợ lý → Cấu hình, chấp nhận rủi ro theo hộp thoại, chỉ gửi bản tóm tắt chi tiêu gộp (không ảnh, không tên cửa hàng).
- **Hỗ trợ / phản hồi:** nhắn thẳng vào các phản hồi, đồng thời có kênh thông tin liên hệ kèm chẩn đoán trên thiết bị.

### Trạng thái

- Mobile: triển khai đầy đủ trong `lib/features/assistant/` (P0/P1).
- Backend (P2): endpoint `/v1/assistant/chat` proxy cho LLM (chạy khi `LLM_API_KEY` được cấu hình; ứng dụng định hướng người dùng thiết bị phải trả lời offline).

### Ưu tiên

| Tính năng | Mô tả | Ưu tiên |
|---|---|---|
| Trả lời offline có định dạng | Metrics, cards giao dịch/danh mục | P0 |
| Ghi giao dịch qua chat | Draft + xác nhận 1 nút | P0 |
| Cloud LLM proxy server-side | Tại /v1/assistant/chat, gọi khi người dùng opt-in | P2 |
| Nhắc nhở cho hội thoại trên thiết bị | Nhắn "thông báo xuống hệ thống" | P3 |
