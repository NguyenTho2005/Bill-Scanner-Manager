import 'package:bill_tracker/core/security/local_security_service.dart';
import 'package:bill_tracker/core/security/security_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/types/auth_messages.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _storage[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }
}

class FakeLocalAuth extends Fake implements LocalAuthentication {
  bool canCheck = true;
  bool isSupported = true;
  bool authResult = true;

  @override
  Future<bool> get canCheckBiometrics async => canCheck;

  @override
  Future<bool> isDeviceSupported() async => isSupported;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[],
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async =>
      authResult;
}

void main() {
  late FakeSecureStorage fakeStorage;
  late FakeLocalAuth fakeAuth;
  late LocalSecurityService securityService;

  setUp(() {
    fakeStorage = FakeSecureStorage();
    fakeAuth = FakeLocalAuth();
    securityService = LocalSecurityService(
      localAuth: fakeAuth,
      secureStorage: fakeStorage,
    );
  });

  group('LocalSecurityService', () {
    test(
      'isBiometricAvailable returns true when supported and can check',
      () async {
        expect(await securityService.isBiometricAvailable, isTrue);

        fakeAuth.canCheck = false;
        expect(await securityService.isBiometricAvailable, isFalse);
      },
    );

    test('PIN lifecycle: set, verify correct, verify wrong, clear', () async {
      expect(await securityService.isPinSet, isFalse);

      final noPinResult = await securityService.verifyPin('1234');
      expect(noPinResult, isA<AuthFailed>());

      await securityService.setPin('1234');
      expect(await securityService.isPinSet, isTrue);

      final successResult = await securityService.verifyPin('1234');
      expect(successResult, isA<AuthSuccess>());
      if (successResult is AuthSuccess) {
        expect(successResult.method, AuthMethod.pin);
      }

      final wrongResult = await securityService.verifyPin('0000');
      expect(wrongResult, isA<AuthFailed>());

      await securityService.clearPin();
      expect(await securityService.isPinSet, isFalse);
    });

    test('biometric authentication success and failure', () async {
      final success = await securityService.authenticateWithBiometric();
      expect(success, isA<AuthSuccess>());

      fakeAuth.authResult = false;
      final cancelled = await securityService.authenticateWithBiometric();
      expect(cancelled, isA<AuthCancelled>());

      fakeAuth.isSupported = false;
      final unsupported = await securityService.authenticateWithBiometric();
      expect(unsupported, isA<AuthFailed>());
    });

    test('lock enablement and auto-lock timeout config', () async {
      await securityService.setLockEnabled(enabled: true);
      expect(await securityService.isLockEnabled, isTrue);

      await securityService.setLockEnabled(enabled: false);
      expect(await securityService.isLockEnabled, isFalse);

      await securityService.setAutoLockTimeout(const Duration(seconds: 120));
      expect(
        await securityService.autoLockTimeout,
        const Duration(seconds: 120),
      );
    });
  });
}
