import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('vi')];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'BillTracker'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In vi, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get loading;

  /// No description provided for @errorUnknown.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi xảy ra. Vui lòng thử lại.'**
  String get errorUnknown;

  /// No description provided for @navFeed.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch'**
  String get navFeed;

  /// No description provided for @navBudget.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách'**
  String get navBudget;

  /// No description provided for @navReports.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get navSettings;

  /// No description provided for @addTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Thêm giao dịch'**
  String get addTransaction;

  /// No description provided for @productSnap.
  ///
  /// In vi, this message translates to:
  /// **'Chụp sản phẩm'**
  String get productSnap;

  /// No description provided for @receiptScan.
  ///
  /// In vi, this message translates to:
  /// **'Quét hóa đơn'**
  String get receiptScan;

  /// No description provided for @manualEntry.
  ///
  /// In vi, this message translates to:
  /// **'Nhập thủ công'**
  String get manualEntry;

  /// No description provided for @amount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get amount;

  /// No description provided for @amountHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tiền'**
  String get amountHint;

  /// No description provided for @amountRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số tiền'**
  String get amountRequired;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get category;

  /// No description provided for @merchant.
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng'**
  String get merchant;

  /// No description provided for @merchantHint.
  ///
  /// In vi, this message translates to:
  /// **'Tên cửa hàng'**
  String get merchantHint;

  /// No description provided for @note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ghi chú...'**
  String get noteHint;

  /// No description provided for @date.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get date;

  /// No description provided for @paymentMethod.
  ///
  /// In vi, this message translates to:
  /// **'Hình thức thanh toán'**
  String get paymentMethod;

  /// No description provided for @catFoodDrinks.
  ///
  /// In vi, this message translates to:
  /// **'Ăn uống'**
  String get catFoodDrinks;

  /// No description provided for @catTransport.
  ///
  /// In vi, this message translates to:
  /// **'Di chuyển'**
  String get catTransport;

  /// No description provided for @catShopping.
  ///
  /// In vi, this message translates to:
  /// **'Mua sắm'**
  String get catShopping;

  /// No description provided for @catEntertainment.
  ///
  /// In vi, this message translates to:
  /// **'Giải trí'**
  String get catEntertainment;

  /// No description provided for @catHealth.
  ///
  /// In vi, this message translates to:
  /// **'Sức khỏe'**
  String get catHealth;

  /// No description provided for @catEducation.
  ///
  /// In vi, this message translates to:
  /// **'Giáo dục'**
  String get catEducation;

  /// No description provided for @catBills.
  ///
  /// In vi, this message translates to:
  /// **'Hóa đơn'**
  String get catBills;

  /// No description provided for @catWork.
  ///
  /// In vi, this message translates to:
  /// **'Công việc'**
  String get catWork;

  /// No description provided for @catTravel.
  ///
  /// In vi, this message translates to:
  /// **'Du lịch'**
  String get catTravel;

  /// No description provided for @catOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get catOther;

  /// No description provided for @paymentCash.
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt'**
  String get paymentCash;

  /// No description provided for @paymentCard.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ'**
  String get paymentCard;

  /// No description provided for @paymentTransfer.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển khoản'**
  String get paymentTransfer;

  /// No description provided for @paymentEwallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví điện tử'**
  String get paymentEwallet;

  /// No description provided for @aiSuggested.
  ///
  /// In vi, this message translates to:
  /// **'AI đề xuất'**
  String get aiSuggested;

  /// No description provided for @aiLowConfidence.
  ///
  /// In vi, this message translates to:
  /// **'Độ chính xác thấp — vui lòng kiểm tra'**
  String get aiLowConfidence;

  /// No description provided for @editBeforeSave.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra và chỉnh sửa trước khi lưu'**
  String get editBeforeSave;

  /// No description provided for @biometricPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực để mở BillTracker'**
  String get biometricPrompt;

  /// No description provided for @biometricSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Dùng vân tay hoặc khuôn mặt'**
  String get biometricSubtitle;

  /// No description provided for @pinEnter.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã PIN'**
  String get pinEnter;

  /// No description provided for @pinForgot.
  ///
  /// In vi, this message translates to:
  /// **'Quên PIN?'**
  String get pinForgot;

  /// No description provided for @budgetLimit.
  ///
  /// In vi, this message translates to:
  /// **'Hạn mức'**
  String get budgetLimit;

  /// No description provided for @budgetSpent.
  ///
  /// In vi, this message translates to:
  /// **'Đã chi'**
  String get budgetSpent;

  /// No description provided for @budgetRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn lại'**
  String get budgetRemaining;

  /// No description provided for @budgetExceeded.
  ///
  /// In vi, this message translates to:
  /// **'Vượt ngân sách'**
  String get budgetExceeded;

  /// No description provided for @budgetWarning80.
  ///
  /// In vi, this message translates to:
  /// **'Đã dùng 80% ngân sách {category}'**
  String budgetWarning80(String category);

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm qua'**
  String get yesterday;

  /// No description provided for @thisMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng trước'**
  String get lastMonth;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
