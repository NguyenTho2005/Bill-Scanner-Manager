import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/budget/domain/entities/category_budget_progress.dart';

/// Repository contract for Budget operations.
abstract class BudgetRepository {
  /// Fetches all budgets.
  Future<List<Budget>> getAllBudgets();

  /// Watches all budgets reactively.
  Stream<List<Budget>> watchAllBudgets();

  /// Gets a budget by its primary ID.
  Future<Budget?> getBudgetById(String id);

  /// Gets a budget by target category ID.
  Future<Budget?> getBudgetByCategoryId(String categoryId);

  /// Watches budget progress for all configured budgets for a given [month].
  /// Defaults to current month if [month] is null.
  Stream<List<CategoryBudgetProgress>> watchBudgetProgressList({
    DateTime? month,
  });

  /// Inserts or updates a budget.
  Future<void> saveBudget(Budget budget);

  /// Deletes a budget by ID.
  Future<void> deleteBudget(String id);

  /// Evaluates current spent amounts against limits and fires notifications
  /// and analytics for newly reached thresholds (80%, 100%).
  Future<void> checkAndTriggerAlerts();
}
