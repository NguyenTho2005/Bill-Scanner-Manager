import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/features/households/domain/entities/household.dart';
import 'package:bill_tracker/features/households/domain/repositories/household_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [HouseholdRepository].
final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return getIt<HouseholdRepository>();
});

/// List of households the user belongs to.
final householdsListProvider =
    FutureProvider.autoDispose<List<Household>>((ref) async {
  return ref.watch(householdRepositoryProvider).getHouseholds();
});

/// Currently selected household ID in the Shared Budgets screen.
final selectedHouseholdIdProvider = StateProvider<String?>((ref) => null);

/// Shared budgets for a specific `householdId`.
final sharedBudgetsProvider = FutureProvider.autoDispose
    .family<List<SharedBudgetSummary>, String>((ref, householdId) async {
  return ref.watch(householdRepositoryProvider).getSharedBudgets(householdId);
});

/// Shared transactions (with creator attribution) for `householdId`.
final sharedTransactionsProvider = FutureProvider.autoDispose
    .family<List<SharedExpenseItem>, String>((ref, householdId) async {
  return ref
      .watch(householdRepositoryProvider)
      .getSharedTransactions(householdId);
});
