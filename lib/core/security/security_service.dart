import 'package:bill_tracker/core/errors/failures.dart';

/// Authentication method used by the user.
enum AuthMethod { biometric, pin }

/// Result of an authentication attempt.
sealed class AuthResult {
  const AuthResult();
}

/// Authentication succeeded.
final class AuthSuccess extends AuthResult {
  /// Creates [AuthSuccess] with the method used.
  const AuthSuccess(this.method);

  /// The authentication method that succeeded.
  final AuthMethod method;
}

/// Authentication failed (wrong PIN, biometric not matched, etc.).
final class AuthFailed extends AuthResult {
  /// Creates [AuthFailed] with the failure detail.
  const AuthFailed(this.failure);

  /// Details about why authentication failed.
  final SecurityFailure failure;
}

/// User cancelled the authentication dialog.
final class AuthCancelled extends AuthResult {
  /// Creates [AuthCancelled].
  const AuthCancelled();
}

/// Abstract security service — biometric + PIN authentication.
abstract class SecurityService {
  /// Returns true if the device supports biometric authentication.
  Future<bool> get isBiometricAvailable;

  /// Returns true if the user has enrolled a PIN.
  Future<bool> get isPinSet;

  /// Returns true if the app lock is enabled by the user.
  Future<bool> get isLockEnabled;

  /// Enable or disable the biometric/PIN lock.
  Future<void> setLockEnabled({required bool enabled});

  /// Authenticate using biometrics (Face ID / fingerprint).
  /// Falls back to PIN if biometric fails or is not available.
  Future<AuthResult> authenticateWithBiometric({String? reason});

  /// Verify a PIN entered by the user.
  Future<AuthResult> verifyPin(String pin);

  /// Set or update the user's PIN.
  Future<void> setPin(String pin);

  /// Remove the stored PIN (disables PIN fallback).
  Future<void> clearPin();

  /// Duration in seconds after which the app auto-locks in background.
  Future<Duration> get autoLockTimeout;

  /// Update the auto-lock timeout duration.
  Future<void> setAutoLockTimeout(Duration duration);
}
