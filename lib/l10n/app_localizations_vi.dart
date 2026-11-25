// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'BillTracker';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get delete => 'Xóa';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get retry => 'Thử lại';

  @override
  String get loading => 'Đang tải...';

  @override
  String get errorUnknown => 'Có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get navFeed => 'Giao dịch';

  @override
  String get navBudget => 'Ngân sách';

  @override
  String get navReports => 'Báo cáo';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get addTransaction => 'Thêm giao dịch';

  @override
  String get productSnap => 'Chụp sản phẩm';

  @override
  String get receiptScan => 'Quét hóa đơn';

  @override
  String get manualEntry => 'Nhập thủ công';

  @override
  String get amount => 'Số tiền';

  @override
  String get amountHint => 'Nhập số tiền';

  @override
  String get amountRequired => 'Vui lòng nhập số tiền';

  @override
  String get category => 'Danh mục';

  @override
  String get merchant => 'Cửa hàng';

  @override
  String get merchantHint => 'Tên cửa hàng';

  @override
  String get note => 'Ghi chú';

  @override
  String get noteHint => 'Thêm ghi chú...';

  @override
  String get date => 'Ngày';

  @override
  String get paymentMethod => 'Hình thức thanh toán';

  @override
  String get catFoodDrinks => 'Ăn uống';

  @override
  String get catTransport => 'Di chuyển';

  @override
  String get catShopping => 'Mua sắm';

  @override
  String get catEntertainment => 'Giải trí';

  @override
  String get catHealth => 'Sức khỏe';

  @override
  String get catEducation => 'Giáo dục';

  @override
  String get catBills => 'Hóa đơn';

  @override
  String get catWork => 'Công việc';

  @override
  String get catTravel => 'Du lịch';

  @override
  String get catOther => 'Khác';

  @override
  String get paymentCash => 'Tiền mặt';

  @override
  String get paymentCard => 'Thẻ';

  @override
  String get paymentTransfer => 'Chuyển khoản';

  @override
  String get paymentEwallet => 'Ví điện tử';

  @override
  String get aiSuggested => 'AI đề xuất';

  @override
  String get aiLowConfidence => 'Độ chính xác thấp — vui lòng kiểm tra';

  @override
  String get editBeforeSave => 'Kiểm tra và chỉnh sửa trước khi lưu';

  @override
  String get biometricPrompt => 'Xác thực để mở BillTracker';

  @override
  String get biometricSubtitle => 'Dùng vân tay hoặc khuôn mặt';

  @override
  String get pinEnter => 'Nhập mã PIN';

  @override
  String get pinForgot => 'Quên PIN?';

  @override
  String get budgetLimit => 'Hạn mức';

  @override
  String get budgetSpent => 'Đã chi';

  @override
  String get budgetRemaining => 'Còn lại';

  @override
  String get budgetExceeded => 'Vượt ngân sách';

  @override
  String budgetWarning80(String category) {
    return 'Đã dùng 80% ngân sách $category';
  }

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get thisMonth => 'Tháng này';

  @override
  String get lastMonth => 'Tháng trước';

  @override
  String get settingsTitle => 'Cài đặt & Dữ liệu';

  @override
  String get settingsAssistantSection => 'Trợ lý chi tiêu';

  @override
  String get settingsAssistantConfig => 'Cấu hình trợ lý';

  @override
  String get settingsAssistantSubtitle =>
      'Mặc định offline · Cloud AI là tuỳ chọn (BYO key)';

  @override
  String get settingsSecuritySection => 'Bảo mật & Quyền riêng tư';

  @override
  String get settingsBiometricLock => 'Khóa sinh trắc học / PIN';

  @override
  String get settingsBiometricSubtitle => 'Yêu cầu Face ID/Vân tay khi mở app';

  @override
  String get settingsResetPin => 'Thiết lập lại mã PIN';

  @override
  String get settingsResetPinSubtitle => 'Đổi mã PIN 4 chữ số bảo mật';

  @override
  String get settingsKeepOriginalPhotos => 'Lưu ảnh gốc vào thư viện';

  @override
  String get settingsKeepOriginalSubtitle =>
      'Mặc định chỉ lưu ảnh nén tối ưu (2048px) để tiết kiệm bộ nhớ';

  @override
  String get settingsStorageSection => 'Dung lượng & Sao lưu';

  @override
  String get settingsStorageUsed => 'Bộ nhớ đã sử dụng';

  @override
  String get settingsExportCsv => 'Xuất dữ liệu Excel / CSV';

  @override
  String get settingsExportCsvSubtitle => 'Mở bằng Excel hoặc Google Sheets';

  @override
  String get settingsExportJson => 'Sao lưu toàn bộ (JSON)';

  @override
  String get settingsExportJsonSubtitle =>
      'Xuất toàn bộ giao dịch, danh mục, ngân sách';

  @override
  String get settingsImportJson => 'Khôi phục từ file sao lưu';

  @override
  String get settingsImportJsonSubtitle => 'Nhập dữ liệu từ bản sao lưu JSON';

  @override
  String get settingsCloudSyncSection => 'Đồng bộ hóa đám mây (Tùy chọn)';

  @override
  String get settingsLocalFirstTitle => 'Chế độ Local-first an toàn';

  @override
  String get settingsLocalFirstSubtitle =>
      'Mọi dữ liệu chi tiêu và hình ảnh được lưu trữ an toàn 100% trên thiết bị của bạn. Ứng dụng hoạt động mượt mà hoàn toàn không cần Internet.';

  @override
  String get settingsEnableCloudSync => 'Bật đồng bộ đám mây';

  @override
  String get settingsEnableCloudSyncSubtitle =>
      'Tùy chọn: Đồng bộ đa thiết bị khi có kết nối';

  @override
  String get settingsDangerZone => 'Vùng nguy hiểm';

  @override
  String get settingsDeleteAll => 'Xóa toàn bộ dữ liệu';

  @override
  String get settingsDeleteAllSubtitle =>
      'Xóa sạch mọi giao dịch, hình ảnh và ngân sách khỏi máy';
}
