import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/core/router/app_router.dart';
import 'package:bill_tracker/core/security/local_security_service.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Flutter Local Notifications plugin instance.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Orientation lock (portrait only for MVP) ────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── System UI overlay style ─────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Local notifications init ────────────────────────────────────────────
  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false, // Request at runtime
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // ── Dependency injection ────────────────────────────────────────────────
  await configureDependencies(environment: Env.dev);

  // ── Security service (constructed once) ────────────────────────────────
  final securityService = LocalSecurityService(
    localAuth: LocalAuthentication(),
    secureStorage: const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        // Override the abstract securityServiceProvider with real implementation
        securityServiceProvider.overrideWithValue(securityService),
      ],
      child: const BillTrackerApp(),
    ),
  );
}

/// Root application widget.
class BillTrackerApp extends ConsumerStatefulWidget {
  /// Creates the root [BillTrackerApp].
  const BillTrackerApp({super.key});

  @override
  ConsumerState<BillTrackerApp> createState() => _BillTrackerAppState();
}

class _BillTrackerAppState extends ConsumerState<BillTrackerApp>
    with WidgetsBindingObserver {
  late final _router = AppRouter.createRouter(ref: ref);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Check if we should lock on background
      _maybeAutoLock();
    }
  }

  Future<void> _maybeAutoLock() async {
    final security = ref.read(securityServiceProvider);
    final isEnabled = await security.isLockEnabled;
    if (isEnabled) {
      ref.read(appLockProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BillTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,

      // ── Localization ──────────────────────────────────────────────────
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      locale: const Locale('vi', 'VN'),
    );
  }
}
