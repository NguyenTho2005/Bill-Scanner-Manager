import 'package:bill_tracker/features/households/domain/entities/household.dart';

/// Repository managing shared households, invitations, and shared budgets.
abstract class HouseholdRepository {
  /// Returns households the current user belongs to.
  Future<List<Household>> getHouseholds();

  /// Creates a new household with the current user as owner.
  Future<Household> createHousehold({
    required String name,
    String? displayName,
  });

  /// Generates an invite code and deep link for [householdId].
  Future<HouseholdInvite> createInvite({
    required String householdId,
    int expiresInHours = 72,
  });

  /// Accepts an invite by [code] and joins the household as a member.
  Future<Household> acceptInvite({
    required String code,
    String? displayName,
  });

  /// Removes a member from [householdId] (owner removes member, or self-leave).
  Future<void> removeMember({
    required String householdId,
    required String userId,
  });

  /// Lists shared budgets for [householdId] with spent amounts and attribution.
  Future<List<SharedBudgetSummary>> getSharedBudgets(String householdId);

  /// Creates a shared budget inside [householdId].
  Future<SharedBudgetSummary> createSharedBudget({
    required String householdId,
    required String categoryId,
    required double amountLimit,
    required DateTime periodStart,
    required DateTime periodEnd,
    String period = 'monthly',
  });

  /// Lists all shared (`isShared == true`) transactions in [householdId].
  Future<List<SharedExpenseItem>> getSharedTransactions(String householdId);
}
