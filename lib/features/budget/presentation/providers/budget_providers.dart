import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/budget/domain/entities/category_budget_progress.dart';
import 'package:bill_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [BudgetRepository] from DI locator.
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return getIt<BudgetRepository>();
});

/// Reactive stream of [CategoryBudgetProgress] for current month.
final budgetProgressListProvider =
    StreamProvider.autoDispose<List<CategoryBudgetProgress>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchBudgetProgressList();
});

/// Reactive stream of all configured [Budget] entities.
final budgetListProvider = StreamProvider.autoDispose<List<Budget>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchAllBudgets();
});

/// Async state notifier for budget mutations (create, update, delete).
class BudgetActionNotifier extends StateNotifier<AsyncValue<void>> {
  /// Creates [BudgetActionNotifier].
  BudgetActionNotifier(this._repository) : super(const AsyncValue.data(null));

  final BudgetRepository _repository;

  /// Saves or updates a budget entity.
  Future<void> saveBudget(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveBudget(budget);
    });
  }

  /// Deletes a budget by ID.
  Future<void> deleteBudget(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteBudget(id);
    });
  }
}

/// Provider for budget mutation actions.
final budgetActionNotifierProvider =
    StateNotifierProvider<BudgetActionNotifier, AsyncValue<void>>((ref) {
  return BudgetActionNotifier(ref.watch(budgetRepositoryProvider));
});
