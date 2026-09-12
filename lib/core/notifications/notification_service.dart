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
}

/// Implementation using [FlutterLocalNotificationsPlugin].
class LocalNotificationService implements NotificationService {
  /// Creates [LocalNotificationService].
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

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
}
