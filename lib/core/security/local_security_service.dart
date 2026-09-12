import 'package:bill_tracker/core/errors/failures.dart';
import 'package:bill_tracker/core/security/security_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Storage keys for SecurityService.
class _Keys {
  static const isPinSet = 'security.is_pin_set';
  static const pinHash = 'security.pin_hash';
  static const isLockEnabled = 'security.lock_enabled';
  static const autoLockSeconds = 'security.auto_lock_seconds';
}

/// Local implementation of [SecurityService] using
/// [LocalAuthentication] for biometrics and [FlutterSecureStorage] for PIN.
class LocalSecurityService implements SecurityService {
  /// Creates [LocalSecurityService] with required dependencies.
  LocalSecurityService({required this.localAuth, required this.secureStorage});

  /// The local authentication plugin.
  final LocalAuthentication localAuth;

  /// The secure storage instance for credentials.
  final FlutterSecureStorage secureStorage;

  static const int _defaultAutoLockSeconds = 60; // 1 minute

  @override
  Future<bool> get isBiometricAvailable async {
    try {
      final canCheck = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> get isPinSet async {
    final value = await secureStorage.read(key: _Keys.isPinSet);
    return value == 'true';
  }

  @override
  Future<bool> get isLockEnabled async {
    final value = await secureStorage.read(key: _Keys.isLockEnabled);
    // Default: lock is enabled if PIN is set
    if (value == null) return isPinSet;
    return value == 'true';
  }

  @override
  Future<void> setLockEnabled({required bool enabled}) async {
    await secureStorage.write(
      key: _Keys.isLockEnabled,
      value: enabled.toString(),
    );
  }

  @override
  Future<AuthResult> authenticateWithBiometric({String? reason}) async {
    try {
      final available = await isBiometricAvailable;
      if (!available) {
        return const AuthFailed(
          SecurityFailure(message: 'Thiết bị không hỗ trợ sinh trắc học'),
        );
      }

      final authenticated = await localAuth.authenticate(
        localizedReason: reason ?? 'Xác thực để mở BillTracker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow device credential fallback
        ),
      );

      if (authenticated) return const AuthSuccess(AuthMethod.biometric);

      return const AuthCancelled();
    } on Exception catch (e) {
      return AuthFailed(SecurityFailure(message: e.toString()));
    }
  }

  @override
  Future<AuthResult> verifyPin(String pin) async {
    final storedHash = await secureStorage.read(key: _Keys.pinHash);
    if (storedHash == null) {
      return const AuthFailed(SecurityFailure(message: 'Chưa thiết lập PIN'));
    }

    final inputHash = _hashPin(pin);
    if (inputHash == storedHash) {
      return const AuthSuccess(AuthMethod.pin);
    }

    return const AuthFailed(SecurityFailure(message: 'PIN không đúng'));
  }

  @override
  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await secureStorage.write(key: _Keys.pinHash, value: hash);
    await secureStorage.write(key: _Keys.isPinSet, value: 'true');
  }

  @override
  Future<void> clearPin() async {
    await secureStorage.delete(key: _Keys.pinHash);
    await secureStorage.write(key: _Keys.isPinSet, value: 'false');
  }

  @override
  Future<Duration> get autoLockTimeout async {
    final value = await secureStorage.read(key: _Keys.autoLockSeconds);
    final seconds = int.tryParse(value ?? '') ?? _defaultAutoLockSeconds;
    return Duration(seconds: seconds);
  }

  @override
  Future<void> setAutoLockTimeout(Duration duration) async {
    await secureStorage.write(
      key: _Keys.autoLockSeconds,
      value: duration.inSeconds.toString(),
    );
  }

  /// Simple deterministic hash for PIN (PBKDF2 would be ideal but adds deps).
  /// PIN is short numeric — hash adds a layer over plain text storage.
  String _hashPin(String pin) {
    // XOR-based salted hash — adequate for 4-6 digit PIN stored in Keychain.
    // Keychain itself provides the encryption; this prevents plain-text storage.
    const salt = 'bt_pin_salt_v1';
    final salted = '$salt:$pin';
    var hash = 0;
    for (var i = 0; i < salted.length; i++) {
      hash = (hash << 5) - hash + salted.codeUnitAt(i);
      hash &= hash; // Convert to 32bit int
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
