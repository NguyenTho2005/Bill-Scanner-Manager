import 'package:bill_tracker/features/assistant/presentation/widgets/assistant_bubble.dart';
import 'package:bill_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:bill_tracker/features/auth/presentation/screens/lock_screen.dart';
import 'package:bill_tracker/features/budget/presentation/screens/budget_list_screen.dart';
import 'package:bill_tracker/features/budget/presentation/screens/create_edit_budget_screen.dart';
import 'package:bill_tracker/features/feed/presentation/screens/visual_feed_screen.dart';
import 'package:bill_tracker/features/households/presentation/screens/household_budget_screen.dart';
import 'package:bill_tracker/features/product_snap/presentation/screens/product_snap_screen.dart';
import 'package:bill_tracker/features/receipt_scan/presentation/screens/receipt_scan_screen.dart';
import 'package:bill_tracker/features/reports/presentation/screens/reports_screen.dart';
import 'package:bill_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/screens/create_edit_transaction_screen.dart';
import 'package:bill_tracker/features/transaction/presentation/screens/recurring_rule_edit_screen.dart';
import 'package:bill_tracker/features/transaction/presentation/screens/recurring_transaction_screen.dart';
import 'package:bill_tracker/features/transaction/presentation/screens/transaction_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'routes.dart';

/// App router factory — creates GoRouter with Riverpod-backed auth guard.
class AppRouter {
  AppRouter._();

  /// Creates [GoRouter] with auth guard driven by [appLockProvider].
  static GoRouter createRouter({required WidgetRef ref}) {
    return GoRouter(
      initialLocation: Routes.feed,
      debugLogDiagnostics: true,
      refreshListenable: _AppLockListenable(ref),
      redirect: (context, state) {
        final isAuthenticated = ref.read(appLockProvider);
        final isLockScreen = state.matchedLocation == Routes.lock;

        if (!isAuthenticated && !isLockScreen) return Routes.lock;
        if (isAuthenticated && isLockScreen) return Routes.feed;
        return null;
      },
      routes: _routes,
    );
  }

  static final List<RouteBase> _routes = [
    // ── Lock screen (full-screen, no shell) ───────────────────────────────
    GoRoute(
      path: Routes.lock,
      name: 'lock',
      builder: (_, __) => const LockScreen(),
    ),

    // ── Main shell with bottom navigation ─────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => _MainShell(child: child),
      routes: [
        GoRoute(
          path: Routes.feed,
          name: 'feed',
          builder: (_, __) => const VisualFeedScreen(),
          routes: [
            GoRoute(
              path: 'transaction/:id',
              name: 'transactionDetail',
              builder: (_, state) => TransactionDetailScreen(
                transactionId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: Routes.recurringRules,
              name: 'recurringRules',
              builder: (_, __) => const RecurringTransactionScreen(),
            ),
            GoRoute(
              path: '${Routes.recurringRuleEdit}/:ruleId',
              name: 'recurringRuleEdit',
              builder: (_, state) => RecurringRuleEditScreen(
                ruleId: state.pathParameters['ruleId'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: Routes.budget,
          name: 'budget',
          builder: (_, __) => const BudgetListScreen(),
        ),
        GoRoute(
          path: Routes.reports,
          name: 'reports',
          builder: (_, __) => const ReportsScreen(),
        ),
        GoRoute(
          path: Routes.settings,
          name: 'settings',
          builder: (_, __) => const SettingsScreen(),
        ),
      ],
    ),

    // ── Budget flows ──────────────────────────────────────────────────────
    GoRoute(
      path: Routes.createBudget,
      name: 'createBudget',
      builder: (_, __) => const CreateEditBudgetScreen(),
    ),
    GoRoute(
      path: '${Routes.editBudget}/:id',
      name: 'editBudget',
      builder: (_, state) => CreateEditBudgetScreen(
        budgetId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: Routes.households,
      name: 'households',
      builder: (_, __) => const HouseholdBudgetScreen(),
    ),

    // ── Camera flows (full-screen, no shell) ──────────────────────────────
    GoRoute(
      path: Routes.productSnap,
      name: 'productSnap',
      builder: (_, __) => const ProductSnapScreen(),
    ),
    GoRoute(
      path: Routes.receiptScan,
      name: 'receiptScan',
      builder: (_, __) => const ReceiptScanScreen(),
    ),

    // ── Transaction flows ─────────────────────────────────────────────────
    GoRoute(
      path: Routes.createTransaction,
      name: 'createTransaction',
      builder: (_, __) => const CreateEditTransactionScreen(),
    ),
    GoRoute(
      path: '${Routes.editTransaction}/:id',
      name: 'editTransaction',
      builder: (_, state) => _EditTransactionByIdScreen(
        transactionId: state.pathParameters['id']!,
      ),
    ),
  ];
}

/// Bridges Riverpod [appLockProvider] changes to GoRouter's [Listenable].
class _AppLockListenable extends ChangeNotifier {
  _AppLockListenable(WidgetRef ref) {
    ref.listen<bool>(appLockProvider, (_, __) => notifyListeners());
  }
}

/// Deep-link wrapper that resolves a transaction by ID before opening edit UI.
class _EditTransactionByIdScreen extends ConsumerWidget {
  const _EditTransactionByIdScreen({required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionDetailProvider(transactionId));
    return txAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Sửa giao dịch')),
        body: Center(child: Text('Lỗi: $err')),
      ),
      data: (tx) {
        if (tx == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sửa giao dịch')),
            body: const Center(child: Text('Không tìm thấy giao dịch')),
          );
        }
        return CreateEditTransactionScreen(initialTransaction: tx);
      },
    );
  }
}

class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexFromLocation(location);
    // The floating assistant is only shown on the four top-level tabs so it
    // never covers detail screens that carry their own bottom actions.
    final showAssistant = location == Routes.feed ||
        location == Routes.budget ||
        location == Routes.reports ||
        location == Routes.settings;

    return Scaffold(
      body: showAssistant ? AssistantBubbleHost(child: child) : child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onNavTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Ngân sách',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Báo cáo',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showAddTransactionSheet(context),
              tooltip: 'Thêm giao dịch',
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith(Routes.budget)) return 1;
    if (location.startsWith(Routes.reports)) return 2;
    if (location.startsWith(Routes.settings)) return 3;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.feed);
      case 1:
        context.go(Routes.budget);
      case 2:
        context.go(Routes.reports);
      case 3:
        context.go(Routes.settings);
    }
  }

  void _showAddTransactionSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag handle ─────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Thêm giao dịch mới',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // ── Option 1: Product Snap ────────────────────────────────
            _AddOptionCard(
              icon: Icons.camera_alt_rounded,
              iconColor: Colors.deepOrange,
              title: 'Chụp sản phẩm',
              subtitle: 'AI nhận diện danh mục tự động',
              onTap: () {
                Navigator.of(sheetCtx).pop();
                context.push(Routes.productSnap);
              },
            ),
            const SizedBox(height: 10),

            // ── Option 2: Receipt OCR ─────────────────────────────────
            _AddOptionCard(
              icon: Icons.receipt_long_rounded,
              iconColor: Colors.indigo,
              title: 'Quét hóa đơn',
              subtitle: 'OCR tự động đọc tổng tiền & cửa hàng',
              onTap: () {
                Navigator.of(sheetCtx).pop();
                context.push(Routes.receiptScan);
              },
            ),
            const SizedBox(height: 10),

            // ── Option 3: Manual Entry ────────────────────────────────
            _AddOptionCard(
              icon: Icons.edit_note_rounded,
              iconColor: Colors.teal,
              title: 'Nhập thủ công',
              subtitle: 'Tự điền số tiền & danh mục',
              onTap: () {
                Navigator.of(sheetCtx).pop();
                context.push(Routes.createTransaction);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A styled card tile used in the "Add Transaction" bottom sheet.
class _AddOptionCard extends StatelessWidget {
  const _AddOptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest.withAlpha(80),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
