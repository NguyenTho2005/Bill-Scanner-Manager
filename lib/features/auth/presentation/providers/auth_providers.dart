import 'package:bill_tracker/core/security/security_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the current app lock state for GoRouter redirect.
class AppLockNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Start locked — will be set to true after successful auth.
    // If lock is not enabled by user, we skip to authenticated.
    _checkInitialLockState();
    return false; // locked until checked
  }

  void _checkInitialLockState() {
    final security = ref.read(securityServiceProvider);
    security.isLockEnabled.then((enabled) {
      if (!enabled) {
        // Lock disabled — allow through immediately
        state = true;
      }
      // If enabled, wait for user to authenticate
    });
  }

  /// Called after successful biometric or PIN auth.
  void unlock() => state = true;

  /// Called when the app goes to background / times out.
  void lock() => state = false;
}

/// Provider for [AppLockNotifier].
final appLockProvider = NotifierProvider<AppLockNotifier, bool>(
  AppLockNotifier.new,
);

/// Provider for [SecurityService] — override in tests with a mock.
final securityServiceProvider = Provider<SecurityService>(
  (ref) => throw UnimplementedError(
    'securityServiceProvider must be overridden. '
    'Register LocalSecurityService in your ProviderScope overrides.',
  ),
);
