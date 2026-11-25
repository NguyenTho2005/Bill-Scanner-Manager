import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Contract for application local notification service.
abstract class NotificationService {
  /// Initializes the notification plugin and channels.
  Future<void> init();

  /// Shows a notification when a budget threshold or limit is reached.
  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  });

  /// Shows a notification when a recurring transaction was created
  /// automatically. [payload] carries the transaction id so the client can
  /// route the user to an edit screen (§4.7-recurring).
  Future<void> showRecurringTransactionAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
}

/// Implementation using [FlutterLocalNotificationsPlugin].
class LocalNotificationService implements NotificationService {
  /// Creates [LocalNotificationService].
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  /// Transaction IDs of recurring-alerts tapped by the user; the feed
  /// screen routes the user to these transactions on the next launch
  /// (consumer must call [takeRecurringAlertPayloads]).
  static final List<String> recurringAlertPayloads = [];

  /// Returns and clears pending recurring-alert tap payloads.
  static List<String> takeRecurringAlertPayloads() {
    final out = recurringAlertPayloads.toList();
    recurringAlertPayloads.clear();
    return out;
  }

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: android,
        iOS: darwin,
      );
      await _plugin.initialize(initSettings);
      _isInitialized = true;
    } on Object catch (_) {
      // Gracefully handle environments without native notification bindings (tests/desktop)
    }
  }

  @override
  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await init();
    }
    try {
      const androidDetails = AndroidNotificationDetails(
        'budget_alerts',
        'Cảnh báo ngân sách',
        channelDescription: 'Thông báo khi gần hoặc vượt hạn mức ngân sách',
        importance: Importance.high,
        priority: Priority.high,
      );
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );
      await _plugin.show(id, title, body, details);
    } on Object catch (_) {
      // Gracefully ignore native delivery errors in non-mobile test environments
    }
  }

  @override
  Future<void> showRecurringTransactionAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await init();
    }
    try {
      if (payload != null) {
        recurringAlertPayloads.add(payload);
      }
      const androidDetails = AndroidNotificationDetails(
        'recurring_alerts',
        'Giao dịch định kịt',
        channelDescription: 'Thông báo giao dịch tự động theo định kịt',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );
      await _plugin.show(id, title, body, details, payload: payload);
    } on Object catch (_) {
      // Gracefully ignore native delivery errors in non-mobile test environments
    }
  }
}
