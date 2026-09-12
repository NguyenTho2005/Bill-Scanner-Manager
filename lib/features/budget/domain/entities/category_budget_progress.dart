import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:equatable/equatable.dart';

/// Progress view model combining a budget with actual spent amount and category.
class CategoryBudgetProgress extends Equatable {
  /// Creates [CategoryBudgetProgress].
  const CategoryBudgetProgress({
    required this.budget,
    required this.category,
    required this.spentAmount,
  });

  /// The underlying budget.
  final Budget budget;

  /// The associated category.
  final Category category;

  /// Actual total expenses within the budget period for this category.
  final double spentAmount;

  /// Remaining amount until limit is reached (negative if exceeded).
  double get remainingAmount => budget.amountLimit - spentAmount;

  /// Ratio of spent vs limit (e.g. 0.85 = 85%).
  double get progressRatio =>
      budget.amountLimit > 0 ? (spentAmount / budget.amountLimit) : 0.0;

  /// Clamped progress ratio from 0.0 to 1.0 for UI progress bars.
  double get clampedProgress => progressRatio.clamp(0.0, 1.0);

  /// Percentage value integer (e.g. 80, 105).
  int get percent => (progressRatio * 100).toInt();

  /// Whether spent has reached or exceeded 80% but is below 100%.
  bool get isNearLimit =>
      spentAmount >= (budget.amountLimit * 0.8) &&
      spentAmount < budget.amountLimit;

  /// Whether spent has reached or exceeded 100% of the limit.
  bool get isExceeded => spentAmount >= budget.amountLimit;

  @override
  List<Object?> get props => [budget, category, spentAmount];
}
