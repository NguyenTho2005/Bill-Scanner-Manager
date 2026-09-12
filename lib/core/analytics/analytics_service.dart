/// Abstract analytics service — swap between Console (dev) and real SDK (prod).
abstract class AnalyticsService {
  /// Logs an analytics event with optional parameters.
  Future<void> logEvent(String name, {Map<String, Object?>? parameters});

  /// Sets the current user ID for analytics tracking.
  Future<void> setUserId(String? userId);
}

/// Analytics event name constants (privacy-safe — no raw amounts or images).
class AnalyticsEvents {
  AnalyticsEvents._();

  /// Fired when camera is opened.
  static const cameraOpened = 'camera_opened';

  /// Fired when a photo is captured.
  static const photoCaptured = 'photo_captured';

  /// Fired when AI inference completes.
  static const aiInferenceCompleted = 'ai_inference_completed';

  /// Fired when OCR completes.
  static const ocrCompleted = 'ocr_completed';

  /// Fired when a transaction is created.
  static const transactionCreated = 'transaction_created';

  /// Fired when a transaction is edited.
  static const transactionEdited = 'transaction_edited';

  /// Fired when a budget is created.
  static const budgetCreated = 'budget_created';

  /// Fired when a budget threshold is reached.
  static const budgetThresholdReached = 'budget_threshold_reached';

  /// Fired when spending exceeds the budget limit.
  static const budgetExceeded = 'budget_exceeded';

  /// Fired when feed filter is applied.
  static const feedFilterApplied = 'feed_filter_applied';

  /// Fired when cloud sync is enabled.
  static const syncEnabled = 'sync_enabled';
}

/// Development analytics: logs to console, never sends data externally.
class ConsoleAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    // Console-only logging for development. No data leaves the device.
    // ignore: avoid_print
    print('[Analytics] $name ${parameters ?? {}}');
  }

  @override
  Future<void> setUserId(String? userId) async {
    // Console-only logging for development.
    // ignore: avoid_print
    print('[Analytics] userId: $userId');
  }
}
