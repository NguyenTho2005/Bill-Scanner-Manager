import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:bill_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await configureDependencies(environment: Env.test);
  });

  testWidgets('SettingsScreen renders all sections properly via AppLocalizations',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('vi'),
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsScreen)),
    );

    // Verify section headers via AppLocalizations
    expect(find.text(l10n.settingsTitle), findsOneWidget);
    expect(find.text(l10n.settingsSecuritySection), findsOneWidget);
    expect(find.text(l10n.settingsStorageSection), findsOneWidget);
    expect(find.text(l10n.settingsCloudSyncSection), findsOneWidget);
    expect(find.text(l10n.settingsDangerZone), findsOneWidget);

    // Verify key action tiles
    expect(find.text(l10n.settingsBiometricLock), findsOneWidget);
    expect(find.text(l10n.settingsExportCsv), findsOneWidget);
    expect(find.text(l10n.settingsExportJson), findsOneWidget);
    expect(find.text(l10n.settingsDeleteAll), findsOneWidget);
    expect(find.text(l10n.settingsEnableCloudSync), findsOneWidget);
  });
}
