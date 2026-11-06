# BillTracker App (Flutter)

Ứng dụng di động **Visual Expense Tracker & Smart Receipt Scanner**: chụp món đồ hoặc quét hóa đơn để ghi giao dịch chi tiêu bằng hình ảnh. Hoạt động **offline hoàn toàn** (local-first) — không cần backend để dùng các luồng cốt lõi.

> Tổng quan toàn dự án và backend: [`../README.md`](../README.md) · Yêu cầu sản phẩm: [`../PRD.md`](../PRD.md)

## Tính năng

| Module | Mô tả |
|---|---|
| **Product Snap** | Chụp ảnh sản phẩm → AI (ML Kit Image Labeling) gợi ý danh mục, OCR đọc giá từ nhãn/menu → nhập số tiền qua numpad → lưu |
| **Receipt Scan** | Quét hóa đơn → ML Kit Text Recognition + parser tiếng Việt đọc merchant/ngày/tổng tiền/line items → màn hình Review để sửa trước khi lưu |
| **Visual Feed** | Lịch sử chi tiêu dạng Photo Grid / Feed theo ngày / List View, lọc theo danh mục & thời gian, tìm kiếm |
| **Budget** | Ngân sách tháng theo danh mục, cảnh báo vượt ngưỡng, dự báo chi tiêu |
| **Reports** | Donut chart theo danh mục, top khoản chi, xu hướng tháng hiện tại vs tháng trước |
| **Transaction** | Tạo/sửa/xem/xóa giao dịch, danh mục (kèm danh mục con), trùng lặp detection, tìm kiếm tiếng Việt |
| **Auth / Lock** | Khóa ứng dụng bằng sinh trắc học (`local_auth`) + PIN dự phòng, secure storage |

## Cấu trúc code

```text
lib/
├── main.dart
├── core/                     # dùng chung
│   ├── ai/                   # ML Kit classifier + OCR + Vietnamese receipt parser
│   ├── database/             # Drift/SQLite + 7 bảng (transactions, medias, categories, budgets, receipt_*, ai_inferences)
│   ├── camera/ · storage/    # nén ảnh, thumbnail, lưu file local
│   ├── security/             # sinh trắc học + PIN + secure storage
│   ├── router/ · di/ · theme/ · notifications/ · analytics/
│   └── utils/ · extensions/ · widgets/
├── features/                 # theo tính năng (Clean Architecture: domain / data / presentation)
│   ├── auth/ · budget/ · feed/ · product_snap/ · receipt_scan/
│   ├── reports/ · settings/ · transaction/ · visual_feed/
└── l10n/                     # i18n (flutter gen-l10n)
```

## Chạy app

Yêu cầu: Flutter SDK tương thích Dart `>=3.6.0 <4.0.0` (xem `pubspec.yaml`).

```bash
cd bill_tracker
flutter pub get

# Sinh code (Drift + l10n) — bắt buộc sau lần clone/checkout mới
dart run build_runner build --delete-conflicting-outputs

flutter devices    # xem thiết bị khả dụng (Android/iOS/Chrome…)
flutter run        # chạy, chọn thiết bị khi được hỏi
```

> Camera cần thiết bị thật (emulator thường không có camera tốt để test Product Snap/Receipt Scan). Chụp hóa đơn đẹp nhất khi đủ sáng, hóa đơn phẳng, chữ rõ.

## Kiểm tra & chất lượng

```bash
flutter analyze    # lint (very_good_analysis + flutter_lints)
flutter test       # unit/widget test trong test/
flutter test --coverage
```

## Lưu ý quan trọng

- **Offline-first:** tạo/sửa/xóa giao dịch không cần Internet. Cloud Sync (backend ở `../backend/`) là opt-in — app chưa bật sync thì không gửi request nào ra ngoài.
- **Ảnh:** mặc định chỉ lưu bản nén + thumbnail (bản gốc chỉ giữ khi người dùng bật tùy chọn riêng trong Settings).
- **Kết quả AI không tự xác nhận:** giá/danh mục AI gợi ý luôn hiển thị để người dùng kiểm tra/sửa trước khi lưu; confidence thấp → đánh dấu cần review hoặc về danh mục "Khác".
