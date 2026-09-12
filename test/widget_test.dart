import 'package:bill_tracker/core/security/security_service.dart';
import 'package:bill_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:bill_tracker/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSecurityService extends Fake implements SecurityService {
  @override
  Future<bool> get isLockEnabled async => false;

  @override
  Future<bool> get isBiometricAvailable async => false;

  @override
  Future<bool> get isPinSet async => false;

  @override
  Future<AuthResult> authenticateWithBiometric({String? reason}) async =>
      const AuthCancelled();
}

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          securityServiceProvider.overrideWithValue(MockSecurityService()),
        ],
        child: const BillTrackerApp(),
      ),
    );
    expect(find.byType(BillTrackerApp), findsOneWidget);
  });
}
