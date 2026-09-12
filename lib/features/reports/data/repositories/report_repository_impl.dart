import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/features/reports/domain/entities/report_data.dart';
import 'package:bill_tracker/features/reports/domain/repositories/report_repository.dart';
import 'package:bill_tracker/features/transaction/data/repositories/category_repository_impl.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:drift/drift.dart';

/// Drift SQLite implementation of [ReportRepository].
class ReportRepositoryImpl implements ReportRepository {
  /// Creates [ReportRepositoryImpl] with [AppDatabase].
  ReportRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<ReportSummary> getMonthlyReport(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month);
    final endOfMonth = DateTime(month.year, month.month + 1)
        .subtract(const Duration(milliseconds: 1));

    // Previous month range
    final prevMonth = DateTime(month.year, month.month - 1);
    final prevStart = DateTime(prevMonth.year, prevMonth.month);
    final prevEnd = DateTime(prevMonth.year, prevMonth.month + 1)
        .subtract(const Duration(milliseconds: 1));

    // ── Current Month Transactions Query ─────────────────────────
    final query = _db.select(_db.transactions).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
      leftOuterJoin(
        _db.transactionMedias,
        _db.transactionMedias.transactionId.equalsExp(_db.transactions.id),
      ),
    ])
      ..where(
        _db.transactions.occurredAt.isBiggerOrEqualValue(startOfMonth) &
            _db.transactions.occurredAt.isSmallerOrEqualValue(endOfMonth) &
            _db.transactions.status.isNotIn(['failed']),
      )
      ..orderBy([OrderingTerm.desc(_db.transactions.occurredAt)]);

    final rows = await query.get();

    double totalExpense = 0;
    double totalIncome = 0;
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};
    final categoryMap = <String, Category>{};
    final expenseTransactions = <Transaction>[];

    for (final row in rows) {
      final txRow = row.readTable(_db.transactions);
      final catRow = row.readTableOrNull(_db.categories);
      final mediaRow = row.readTableOrNull(_db.transactionMedias);

      final category = catRow?.toDomain() ??
          Category(
            id: txRow.categoryId,
            name: 'Khác',
            icon: 'more_horiz',
            colorValue: 0xFF9E9E9E,
          );
      categoryMap[txRow.categoryId] = category;

      final tx = Transaction(
        id: txRow.id,
        type: txRow.type == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        amount: txRow.amount,
        currency: txRow.currency,
        categoryId: txRow.categoryId,
        merchant: txRow.merchant,
        occurredAt: txRow.occurredAt,
        note: txRow.note,
        source: _mapSource(txRow.source),
        status: _mapStatus(txRow.status),
        createdAt: txRow.createdAt,
        updatedAt: txRow.updatedAt,
        category: category,
        thumbnailPath: mediaRow?.thumbnailPath,
      );

      if (tx.type == TransactionType.expense) {
        totalExpense += tx.amount;
        expenseTransactions.add(tx);
        categoryTotals[tx.categoryId] =
            (categoryTotals[tx.categoryId] ?? 0) + tx.amount;
        categoryCounts[tx.categoryId] =
            (categoryCounts[tx.categoryId] ?? 0) + 1;
      } else {
        totalIncome += tx.amount;
      }
    }

    // ── Category Spendings Breakdown ──────────────────────────────
    final categorySpendings = <CategorySpending>[];
    for (final entry in categoryTotals.entries) {
      final cat = categoryMap[entry.key]!;
      final amount = entry.value;
      final percentage = totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0;
      final count = categoryCounts[entry.key] ?? 0;

      categorySpendings.add(
        CategorySpending(
          category: cat,
          amount: amount,
          percentage: percentage,
          transactionCount: count,
        ),
      );
    }
    categorySpendings.sort((a, b) => b.amount.compareTo(a.amount));

    // ── Top 5 Largest Expenses ────────────────────────────────────
    expenseTransactions.sort((a, b) => b.amount.compareTo(a.amount));
    final topExpenses = expenseTransactions.take(5).toList();

    // ── Previous Month Total Expense ──────────────────────────────
    final prevSumColumn = _db.transactions.amount.sum();
    final prevQuery = _db.selectOnly(_db.transactions)
      ..addColumns([prevSumColumn])
      ..where(
        _db.transactions.type.equals('expense') &
            _db.transactions.occurredAt.isBiggerOrEqualValue(prevStart) &
            _db.transactions.occurredAt.isSmallerOrEqualValue(prevEnd) &
            _db.transactions.status.isNotIn(['failed']),
      );
    final prevResult = await prevQuery.getSingle();
    final previousMonthExpense = prevResult.read(prevSumColumn) ?? 0.0;

    // ── 6-Month Historical Trends ─────────────────────────────────
    final monthlyTrends = <MonthlyTrend>[];
    for (var i = 5; i >= 0; i--) {
      final targetM = DateTime(month.year, month.month - i);
      final mStart = DateTime(targetM.year, targetM.month);
      final mEnd = DateTime(targetM.year, targetM.month + 1)
          .subtract(const Duration(milliseconds: 1));

      final expenseSum = _db.transactions.amount.sum(
        filter: _db.transactions.type.equals('expense'),
      );
      final incomeSum = _db.transactions.amount.sum(
        filter: _db.transactions.type.equals('income'),
      );

      final trendQuery = _db.selectOnly(_db.transactions)
        ..addColumns([expenseSum, incomeSum])
        ..where(
          _db.transactions.occurredAt.isBiggerOrEqualValue(mStart) &
              _db.transactions.occurredAt.isSmallerOrEqualValue(mEnd) &
              _db.transactions.status.isNotIn(['failed']),
        );

      final res = await trendQuery.getSingle();
      monthlyTrends.add(
        MonthlyTrend(
          year: targetM.year,
          month: targetM.month,
          label: 'T${targetM.month}',
          expense: res.read(expenseSum) ?? 0.0,
          income: res.read(incomeSum) ?? 0.0,
        ),
      );
    }

    return ReportSummary(
      month: month,
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      previousMonthExpense: previousMonthExpense,
      categorySpendings: categorySpendings,
      topExpenses: topExpenses,
      monthlyTrends: monthlyTrends,
    );
  }

  @override
  Stream<ReportSummary> watchMonthlyReport(DateTime month) {
    // Watch table updates on transactions to reactively regenerate the summary
    return _db
        .select(_db.transactions)
        .watch()
        .asyncMap((_) => getMonthlyReport(month));
  }

  TransactionSource _mapSource(String source) {
    switch (source) {
      case 'product_snap':
        return TransactionSource.productSnap;
      case 'receipt_scan':
        return TransactionSource.receiptScan;
      case 'import':
        return TransactionSource.import_;
      default:
        return TransactionSource.manual;
    }
  }

  TransactionStatus _mapStatus(String status) {
    switch (status) {
      case 'draft':
        return TransactionStatus.draft;
      case 'needs_review':
        return TransactionStatus.needsReview;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.confirmed;
    }
  }
}
