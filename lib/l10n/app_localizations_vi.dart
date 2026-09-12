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
}
