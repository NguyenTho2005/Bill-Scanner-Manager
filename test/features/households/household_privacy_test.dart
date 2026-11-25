import 'package:bill_tracker/core/analytics/analytics_service.dart';
import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart';
import 'package:bill_tracker/core/notifications/notification_service.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/households/data/repositories/household_repository_impl.dart';
import 'package:bill_tracker/features/households/domain/entities/household.dart';
import 'package:bill_tracker/features/households/domain/repositories/household_repository.dart';
import 'package:bill_tracker/features/households/presentation/providers/household_providers.dart';
import 'package:bill_tracker/features/households/presentation/screens/household_budget_screen.dart';
import 'package:bill_tracker/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bill_tracker/features/transaction/data/sync/entity_serializer.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoopNotificationService implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> showRecurringTransactionAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {}
}

class _FakeHouseholdRepository implements HouseholdRepository {
  _FakeHouseholdRepository({
    required this.households,
    required this.budgets,
    required this.transactions,
  });

  final List<Household> households;
  final List<SharedBudgetSummary> budgets;
  final List<SharedExpenseItem> transactions;

  @override
  Future<Household> acceptInvite({
    required String code,
    String? displayName,
  }) async =>
      households.first;

  @override
  Future<Household> createHousehold({
    required String name,
    String? displayName,
  }) async =>
      households.first;

  @override
  Future<HouseholdInvite> createInvite({
    required String householdId,
    int expiresInHours = 72,
  }) async {
    final now = DateTime(2026, 11, 25);
    return HouseholdInvite(
      id: 'inv_1',
      householdId: householdId,
      code: 'BT-TEST12',
      inviteLink: 'billtracker://household/join?code=BT-TEST12',
      expiresAt: now.add(const Duration(hours: 72)),
      createdAt: now,
    );
  }

  @override
  Future<SharedBudgetSummary> createSharedBudget({
    required String householdId,
    required String categoryId,
    required double amountLimit,
    required DateTime periodStart,
    required DateTime periodEnd,
    String period = 'monthly',
  }) async =>
      budgets.first;

  @override
  Future<List<Household>> getHouseholds() async => households;

  @override
  Future<List<SharedBudgetSummary>> getSharedBudgets(
    String householdId,
  ) async =>
      budgets;

  @override
  Future<List<SharedExpenseItem>> getSharedTransactions(
    String householdId,
  ) async =>
      transactions;

  @override
  Future<void> removeMember({
    required String householdId,
    required String userId,
  }) async {}
}

void main() {
  group('Household & isShared privacy', () {
    late AppDatabase db;
    late TransactionRepositoryImpl txRepo;
    late BudgetRepositoryImpl budgetRepo;
    late HouseholdRepositoryImpl hhRepo;

    setUp(() {
      db = DatabaseConnection.inMemory();
      budgetRepo = BudgetRepositoryImpl(
        db: db,
        notificationService: _NoopNotificationService(),
        analyticsService: ConsoleAnalyticsService(),
      );
      txRepo = TransactionRepositoryImpl(db, budgetRepo);
      hhRepo = HouseholdRepositoryImpl(db: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Transaction defaults to private (isShared = false)', () {
      final now = DateTime(2026, 11, 25, 10);
      final tx = Transaction(
        id: 'tx_def_1',
        type: TransactionType.expense,
        amount: 50000,
        currency: 'VND',
        categoryId: 'food_drinks',
        occurredAt: now,
        source: TransactionSource.manual,
        status: TransactionStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      );
      expect(tx.isShared, isFalse);
      expect(tx.householdId, isNull);
    });

    test('Shared budget ignores private transactions (isShared=false)',
        () async {
      final hh = await hhRepo.createHousehold(
        name: 'Gia đình',
        displayName: 'Minh',
      );
      final now = DateTime.now();
      final start = DateTime(now.year, now.month);
      final end = DateTime(now.year, now.month + 1)
          .subtract(const Duration(milliseconds: 1));

      await hhRepo.createSharedBudget(
        householdId: hh.id,
        categoryId: 'food_drinks',
        amountLimit: 3000000,
        periodStart: start,
        periodEnd: end,
      );

      // Private tx even with householdId should NOT be shared or counted
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_private',
          type: TransactionType.expense,
          amount: 500000,
          currency: 'VND',
          categoryId: 'food_drinks',
          merchant: 'Bí mật',
          occurredAt: now,
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: now,
          updatedAt: now,
          isShared: false,
          householdId: hh.id,
        ),
      );

      // Shared tx MUST be counted and returned
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_shared',
          type: TransactionType.expense,
          amount: 120000,
          currency: 'VND',
          categoryId: 'food_drinks',
          merchant: 'Siêu thị',
          occurredAt: now,
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: now,
          updatedAt: now,
          isShared: true,
          householdId: hh.id,
        ),
      );

      final sharedBudgets = await hhRepo.getSharedBudgets(hh.id);
      expect(sharedBudgets.length, 1);
      expect(sharedBudgets.first.spentAmount, 120000);

      final sharedTxs = await hhRepo.getSharedTransactions(hh.id);
      expect(sharedTxs.map((t) => t.id).toList(), ['tx_shared']);
    });

    test('entity_serializer preserves is_shared, household_id, created_by_name',
        () {
      final now = DateTime(2026, 11, 25, 12);
      final tx = Transaction(
        id: 'tx_ser_1',
        type: TransactionType.expense,
        amount: 75000,
        currency: 'VND',
        categoryId: 'food_drinks',
        occurredAt: now,
        source: TransactionSource.manual,
        status: TransactionStatus.confirmed,
        createdAt: now,
        updatedAt: now,
        isShared: true,
        householdId: 'hh_1',
      );
      final payload = transactionPayload(tx);
      expect(payload['is_shared'], isTrue);
      expect(payload['household_id'], 'hh_1');
      expect(payload.containsKey('user_id'), isFalse);

      final roundTrip = transactionFromPayload({
        ...payload,
        'created_by_user_id': 'user_b',
        'created_by_name': 'Lan',
      });
      expect(roundTrip.isShared, isTrue);
      expect(roundTrip.householdId, 'hh_1');
      expect(roundTrip.createdByUserId, 'user_b');
      expect(roundTrip.createdByName, 'Lan');
    });

    testWidgets(
      'HouseholdBudgetScreen renders members, shared budget, and creator name',
      (tester) async {
        final now = DateTime(2026, 11, 25, 9);
        final fakeRepo = _FakeHouseholdRepository(
          households: [
            Household(
              id: 'hh_ui_1',
              name: 'Nhà A-B',
              createdBy: 'user_a',
              createdAt: now,
              members: [
                HouseholdMember(
                  householdId: 'hh_ui_1',
                  userId: 'user_a',
                  role: HouseholdRole.owner,
                  displayName: 'Minh',
                  joinedAt: now,
                ),
                HouseholdMember(
                  householdId: 'hh_ui_1',
                  userId: 'user_b',
                  role: HouseholdRole.member,
                  displayName: 'Lan',
                  joinedAt: now,
                ),
              ],
            ),
          ],
          budgets: [
            SharedBudgetSummary(
              budget: Budget(
                id: 'bg_1',
                householdId: 'hh_ui_1',
                categoryId: 'food_drinks',
                amountLimit: 2000000,
                periodStart: DateTime(2026, 11),
                periodEnd: DateTime(2026, 11, 30),
              ),
              spentAmount: 150000,
              progressRatio: 0.075,
            ),
          ],
          transactions: [
            SharedExpenseItem(
              id: 'tx_1',
              householdId: 'hh_ui_1',
              categoryId: 'food_drinks',
              amount: 150000,
              currency: 'VND',
              merchant: 'Co.opmart',
              occurredAt: now,
              createdByUserId: 'user_b',
              createdByName: 'Lan',
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              householdRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const HouseholdBudgetScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Thành viên (2)'), findsOneWidget);
        expect(find.textContaining('Minh (Chủ nhóm)'), findsOneWidget);
        expect(find.text('Lan'), findsOneWidget);
        expect(find.text('Co.opmart'), findsOneWidget);
        expect(find.textContaining('Người chi: Lan'), findsOneWidget);
      },
    );
  });
}
