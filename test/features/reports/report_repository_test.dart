import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart';
import 'package:bill_tracker/features/reports/data/repositories/report_repository_impl.dart';
import 'package:bill_tracker/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ReportRepositoryImpl reportRepo;
  late TransactionRepositoryImpl txRepo;

  final currentMonth = DateTime(2026, 9, 1);
  final previousMonth = DateTime(2026, 8, 15);

  setUp(() async {
    db = DatabaseConnection.inMemory();
    reportRepo = ReportRepositoryImpl(db);
    txRepo = TransactionRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ReportRepositoryImpl', () {
    test('returns empty report summary when no transactions exist', () async {
      final summary = await reportRepo.getMonthlyReport(currentMonth);

      expect(summary.totalExpense, 0.0);
      expect(summary.totalIncome, 0.0);
      expect(summary.netBalance, 0.0);
      expect(summary.categorySpendings, isEmpty);
      expect(summary.topExpenses, isEmpty);
      expect(summary.monthlyTrends.length, 6);
      expect(summary.expenseChangePercent, 0.0);
    });

    test('correctly aggregates category spendings, income, and percentages',
        () async {
      // Add 2 food expenses: 50.000đ and 150.000đ = 200.000đ
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_f1',
          type: TransactionType.expense,
          amount: 50000,
          currency: 'VND',
          categoryId: 'food_drinks',
          occurredAt: DateTime(2026, 9, 2),
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: DateTime(2026, 9, 2),
          updatedAt: DateTime(2026, 9, 2),
        ),
      );
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_f2',
          type: TransactionType.expense,
          amount: 150000,
          currency: 'VND',
          categoryId: 'food_drinks',
          occurredAt: DateTime(2026, 9, 3),
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: DateTime(2026, 9, 3),
          updatedAt: DateTime(2026, 9, 3),
        ),
      );

      // Add 1 transport expense: 100.000đ
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_t1',
          type: TransactionType.expense,
          amount: 100000,
          currency: 'VND',
          categoryId: 'transport',
          occurredAt: DateTime(2026, 9, 4),
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: DateTime(2026, 9, 4),
          updatedAt: DateTime(2026, 9, 4),
        ),
      );

      // Add 1 income: 1.000.000đ
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_inc',
          type: TransactionType.income,
          amount: 1000000,
          currency: 'VND',
          categoryId: 'work',
          occurredAt: DateTime(2026, 9, 1),
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: DateTime(2026, 9, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
      );

      final summary = await reportRepo.getMonthlyReport(currentMonth);

      // Total expense = 300.000đ
      expect(summary.totalExpense, 300000.0);
      // Total income = 1.000.000đ
      expect(summary.totalIncome, 1000000.0);
      // Net balance = 700.000đ
      expect(summary.netBalance, 700000.0);

      // Category breakdown
      expect(summary.categorySpendings.length, 2);
      // First is food_drinks (200.000đ = 66.67%)
      final food = summary.categorySpendings.first;
      expect(food.category.id, 'food_drinks');
      expect(food.amount, 200000.0);
      expect(food.transactionCount, 2);
      expect(food.percentage, closeTo(66.67, 0.1));

      // Second is transport (100.000đ = 33.33%)
      final transport = summary.categorySpendings.last;
      expect(transport.category.id, 'transport');
      expect(transport.amount, 100000.0);
      expect(transport.transactionCount, 1);
      expect(transport.percentage, closeTo(33.33, 0.1));
    });

    test('extracts top 5 largest expenses in descending order (PRD BR-03)',
        () async {
      for (var i = 1; i <= 7; i++) {
        await txRepo.createTransaction(
          Transaction(
            id: 'tx_$i',
            type: TransactionType.expense,
            amount: (i * 100000)
                .toDouble(), // 100k, 200k, 300k, 400k, 500k, 600k, 700k
            currency: 'VND',
            categoryId: 'shopping',
            merchant: 'Shop $i',
            occurredAt: DateTime(2026, 9, i),
            source: TransactionSource.manual,
            status: TransactionStatus.confirmed,
            createdAt: DateTime(2026, 9, i),
            updatedAt: DateTime(2026, 9, i),
          ),
        );
      }

      final summary = await reportRepo.getMonthlyReport(currentMonth);

      expect(summary.topExpenses.length, 5);
      expect(summary.topExpenses[0].amount, 700000.0);
      expect(summary.topExpenses[1].amount, 600000.0);
      expect(summary.topExpenses[2].amount, 500000.0);
      expect(summary.topExpenses[3].amount, 400000.0);
      expect(summary.topExpenses[4].amount, 300000.0);
    });

    test('calculates month-over-month comparison percent (PRD BR-04)',
        () async {
      // Previous month expense: 1.000.000đ
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_prev',
          type: TransactionType.expense,
          amount: 1000000,
          currency: 'VND',
          categoryId: 'food_drinks',
          occurredAt: previousMonth,
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: previousMonth,
          updatedAt: previousMonth,
        ),
      );

      // Current month expense: 1.250.000đ (+25%)
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_curr',
          type: TransactionType.expense,
          amount: 1250000,
          currency: 'VND',
          categoryId: 'food_drinks',
          occurredAt: DateTime(2026, 9, 10),
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: DateTime(2026, 9, 10),
          updatedAt: DateTime(2026, 9, 10),
        ),
      );

      final summary = await reportRepo.getMonthlyReport(currentMonth);

      expect(summary.previousMonthExpense, 1000000.0);
      expect(summary.totalExpense, 1250000.0);
      // (+25.0%)
      expect(summary.expenseChangePercent, closeTo(25.0, 0.01));
    });
  });
}
