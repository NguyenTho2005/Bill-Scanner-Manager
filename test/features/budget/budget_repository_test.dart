import 'package:bill_tracker/core/analytics/analytics_service.dart';
import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart';
import 'package:bill_tracker/core/notifications/notification_service.dart';
import 'package:bill_tracker/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNotificationService implements NotificationService {
  final List<Map<String, dynamic>> alerts = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    alerts.add({'id': id, 'title': title, 'body': body});
  }
}

class FakeAnalyticsService implements AnalyticsService {
  final List<Map<String, dynamic>> events = [];

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    events.add({'name': name, 'parameters': parameters});
  }

  @override
  Future<void> setUserId(String? userId) async {}
}

void main() {
  late AppDatabase db;
  late FakeNotificationService notificationService;
  late FakeAnalyticsService analyticsService;
  late BudgetRepositoryImpl budgetRepo;
  late TransactionRepositoryImpl txRepo;

  final now = DateTime.now();
  final periodStart = DateTime(now.year, now.month);
  final periodEnd = DateTime(now.year, now.month + 1)
      .subtract(const Duration(milliseconds: 1));

  setUp(() async {
    db = DatabaseConnection.inMemory();
    notificationService = FakeNotificationService();
    analyticsService = FakeAnalyticsService();
    budgetRepo = BudgetRepositoryImpl(
      db: db,
      notificationService: notificationService,
      analyticsService: analyticsService,
    );
    txRepo = TransactionRepositoryImpl(db, budgetRepo);
  });

  tearDown(() async {
    await db.close();
  });

  group('BudgetRepositoryImpl', () {
    test(
        'saveBudget inserts budget and getAllBudgets retrieves it with Category',
        () async {
      final budget = Budget(
        id: 'bg_food',
        categoryId: 'food_drinks',
        amountLimit: 3000000,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );

      await budgetRepo.saveBudget(budget);

      final budgets = await budgetRepo.getAllBudgets();
      expect(budgets.length, 1);
      expect(budgets.first.id, 'bg_food');
      expect(budgets.first.categoryId, 'food_drinks');
      expect(budgets.first.amountLimit, 3000000);
      expect(budgets.first.category, isNotNull);
      expect(budgets.first.category!.name, 'Ăn uống');

      // Verify analytics event logged
      expect(
        analyticsService.events
            .any((e) => e['name'] == AnalyticsEvents.budgetCreated),
        isTrue,
      );
    });

    test(
        'watchBudgetProgressList emits reactive progress as expenses are added',
        () async {
      final budget = Budget(
        id: 'bg_food',
        categoryId: 'food_drinks',
        amountLimit: 3000000,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      await budgetRepo.saveBudget(budget);

      // Initial progress: 0 spent
      var progressList = await budgetRepo.watchBudgetProgressList().first;
      expect(progressList.length, 1);
      expect(progressList.first.spentAmount, 0.0);
      expect(progressList.first.remainingAmount, 3000000.0);
      expect(progressList.first.progressRatio, 0.0);
      expect(progressList.first.isNearLimit, isFalse);
      expect(progressList.first.isExceeded, isFalse);

      // Add expense transaction: 1.500.000đ (50%)
      final tx1 = Transaction(
        id: 'tx_1',
        type: TransactionType.expense,
        amount: 1500000,
        currency: 'VND',
        categoryId: 'food_drinks',
        occurredAt: now,
        source: TransactionSource.manual,
        status: TransactionStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      );
      await txRepo.createTransaction(tx1);

      progressList = await budgetRepo.watchBudgetProgressList().first;
      expect(progressList.first.spentAmount, 1500000.0);
      expect(progressList.first.remainingAmount, 1500000.0);
      expect(progressList.first.percent, 50);
      expect(progressList.first.isNearLimit, isFalse);
      expect(progressList.first.isExceeded, isFalse);
    });

    test('Scenario: Cảnh báo gần vượt ngân sách tại 80% (PRD BR-02)', () async {
      final budget = Budget(
        id: 'bg_food',
        categoryId: 'food_drinks',
        amountLimit: 3000000,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      await budgetRepo.saveBudget(budget);

      // When tổng chi Ăn uống đạt 2.400.000đ (80% của 3.000.000đ)
      final tx = Transaction(
        id: 'tx_warning',
        type: TransactionType.expense,
        amount: 2400000,
        currency: 'VND',
        categoryId: 'food_drinks',
        occurredAt: now,
        source: TransactionSource.manual,
        status: TransactionStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      );
      await txRepo.createTransaction(tx);

      // Then ứng dụng phải gửi thông báo cảnh báo 80%
      expect(notificationService.alerts.length, 1);
      expect(
        notificationService.alerts.first['title'],
        contains('Cảnh báo ngân sách'),
      );
      expect(
        notificationService.alerts.first['body'],
        contains('80%'),
      );

      // And phải ghi nhận sự kiện analytics budget_threshold_reached với threshold 0.8
      expect(
        analyticsService.events.any(
          (e) =>
              e['name'] == AnalyticsEvents.budgetThresholdReached &&
              (e['parameters'] as Map)['threshold'] == 0.8,
        ),
        isTrue,
      );

      // And alertSentAt80 phải được cập nhật thành true
      final updatedBudget = await budgetRepo.getBudgetById('bg_food');
      expect(updatedBudget!.alertSentAt80, isTrue);

      // Scenario: Gửi cảnh báo một lần trong chu kỳ (không spam nếu gọi lại)
      notificationService.alerts.clear();
      await budgetRepo.checkAndTriggerAlerts();
      expect(notificationService.alerts.isEmpty, isTrue);
    });

    test('Scenario: Vượt ngân sách 100% (PRD BR-02 & Module 4 AC)', () async {
      final budget = Budget(
        id: 'bg_shopping',
        categoryId: 'shopping',
        amountLimit: 2000000,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      await budgetRepo.saveBudget(budget);

      // Expense reaches 2.500.000đ (> 2.000.000đ)
      final tx = Transaction(
        id: 'tx_exceed',
        type: TransactionType.expense,
        amount: 2500000,
        currency: 'VND',
        categoryId: 'shopping',
        occurredAt: now,
        source: TransactionSource.manual,
        status: TransactionStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      );
      await txRepo.createTransaction(tx);

      // Then ứng dụng hiển thị thông báo vượt ngân sách
      expect(notificationService.alerts.length, 1);
      expect(
        notificationService.alerts.first['title'],
        contains('Vượt ngân sách'),
      );

      // And phải ghi nhận sự kiện analytics budget_exceeded và threshold 1.0
      expect(
        analyticsService.events
            .any((e) => e['name'] == AnalyticsEvents.budgetExceeded),
        isTrue,
      );
      expect(
        analyticsService.events.any(
          (e) =>
              e['name'] == AnalyticsEvents.budgetThresholdReached &&
              (e['parameters'] as Map)['threshold'] == 1.0,
        ),
        isTrue,
      );

      // And model progress reflects isExceeded
      final progressList = await budgetRepo.watchBudgetProgressList().first;
      final shoppingProgress =
          progressList.firstWhere((p) => p.budget.id == 'bg_shopping');
      expect(shoppingProgress.isExceeded, isTrue);
      expect(shoppingProgress.remainingAmount, -500000.0);
    });

    test('deleteBudget removes budget from database', () async {
      final budget = Budget(
        id: 'bg_to_delete',
        categoryId: 'health',
        amountLimit: 1000000,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      await budgetRepo.saveBudget(budget);
      expect((await budgetRepo.getAllBudgets()).length, 1);

      await budgetRepo.deleteBudget('bg_to_delete');
      expect((await budgetRepo.getAllBudgets()).isEmpty, isTrue);
    });
  });
}
