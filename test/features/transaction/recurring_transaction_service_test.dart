import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart';
import 'package:bill_tracker/core/notifications/notification_service.dart';
import 'package:bill_tracker/features/transaction/data/repositories/recurring_transaction_repository_impl.dart';
import 'package:bill_tracker/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bill_tracker/features/transaction/data/services/recurring_transaction_service_impl.dart';
import 'package:bill_tracker/features/transaction/domain/entities/recurring_rule.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNotificationService implements NotificationService {
  final List<Map<String, Object?>> alerts = [];

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
  }) async {
    alerts.add({'title': title, 'payload': payload});
  }
}

void main() {
  late AppDatabase db;
  late RecurringTransactionServiceImpl service;
  late RecurringTransactionRepositoryImpl repo;
  late TransactionRepositoryImpl txRepo;
  final fakeNotif = FakeNotificationService();

  setUp(() {
    db = DatabaseConnection.inMemory();
    repo = RecurringTransactionRepositoryImpl(db);
    txRepo = TransactionRepositoryImpl(db);
    service = RecurringTransactionServiceImpl(
      recurringRepo: repo,
      txRepo: txRepo,
      notificationService: fakeNotif,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('creates multiple transactions when several periods elapsed', () async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 100));
    final nextRunAt = startDate.subtract(const Duration(days: 20));
    await repo.save(
      RecurringRule(
        id: 'r_monthly',
        amount: 500000,
        type: TransactionType.expense,
        currency: 'VND',
        categoryId: 'bills',
        frequency: RecurringFrequency.monthly,
        dayOfMonth: 15,
        startDate: startDate,
        nextRunAt: nextRunAt,
      ),
    );

    final created = await service.checkAndRunDueRules();
    expect(created, greaterThanOrEqualTo(2));

    final txs = await txRepo.getTransactions(
      filter: TransactionFilter(
        startDate: now.subtract(const Duration(days: 200)),
      ),
    );
    expect(
      txs.every((tx) => tx.source == TransactionSource.recurring),
      isTrue,
    );
    expect(txs.length, greaterThanOrEqualTo(created));

    final rule = (await repo.getById('r_monthly'))!;
    expect(rule.nextRunAt.isAfter(DateTime.now()), isTrue);
  });

  test('no transactions when nextRunAt is in the future', () async {
    await repo.save(
      RecurringRule(
        id: 'r_future',
        amount: 1000,
        type: TransactionType.expense,
        currency: 'VND',
        categoryId: 'bills',
        frequency: RecurringFrequency.weekly,
        dayOfWeek: 3,
        startDate: DateTime.now().add(const Duration(days: 30)),
        nextRunAt: DateTime.now().add(const Duration(days: 30)),
      ),
    );
    expect(await service.checkAndRunDueRules(), 0);
  });
}
