import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:equatable/equatable.dart';

/// Spending summary for a single category.
class CategorySpending extends Equatable {
  /// Creates [CategorySpending].
  const CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  /// The spending category.
  final Category category;

  /// Total amount spent in this category (VND).
  final double amount;

  /// Percentage of total spending (0.0 to 100.0).
  final double percentage;

  /// Number of transactions recorded in this category.
  final int transactionCount;

  @override
  List<Object?> get props => [category, amount, percentage, transactionCount];
}

/// Monthly financial trend data point.
class MonthlyTrend extends Equatable {
  /// Creates [MonthlyTrend].
  const MonthlyTrend({
    required this.year,
    required this.month,
    required this.label,
    required this.expense,
    required this.income,
  });

  /// Year of the trend point.
  final int year;

  /// Month of the trend point (1-12).
  final int month;

  /// Short label (e.g. "T4", "T5", "T6").
  final String label;

  /// Total expense for that month.
  final double expense;

  /// Total income for that month.
  final double income;

  @override
  List<Object?> get props => [year, month, label, expense, income];
}

/// Comprehensive report data for a selected month.
class ReportSummary extends Equatable {
  /// Creates [ReportSummary].
  const ReportSummary({
    required this.month,
    required this.totalExpense,
    required this.totalIncome,
    required this.previousMonthExpense,
    required this.categorySpendings,
    required this.topExpenses,
    required this.monthlyTrends,
  });

  /// Selected report month.
  final DateTime month;

  /// Total expenses in the selected month.
  final double totalExpense;

  /// Total income in the selected month.
  final double totalIncome;

  /// Net balance (income - expense).
  double get netBalance => totalIncome - totalExpense;

  /// Total expenses in the preceding month.
  final double previousMonthExpense;

  /// Percentage change in expenses compared to previous month.
  /// Positive means increased spending, negative means decreased spending.
  double get expenseChangePercent {
    if (previousMonthExpense == 0) return 0;
    return ((totalExpense - previousMonthExpense) / previousMonthExpense) * 100;
  }

  /// Breakdown of spending by category, sorted descending by amount.
  final List<CategorySpending> categorySpendings;

  /// Top 5 largest single expenses with photos.
  final List<Transaction> topExpenses;

  /// 6-month historical trend.
  final List<MonthlyTrend> monthlyTrends;

  @override
  List<Object?> get props => [
        month,
        totalExpense,
        totalIncome,
        previousMonthExpense,
        categorySpendings,
        topExpenses,
        monthlyTrends,
      ];
}
