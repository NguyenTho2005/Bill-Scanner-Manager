import 'package:bill_tracker/features/transaction/domain/entities/recurring_rule.dart';

/// Domain-level repository for recurring transaction rules.
///
/// Design notes (featuring into TransactionRepository, §4.1):
/// - Inputs are validated by the entity (e.g. category exists upstream).
/// - The service drives progress through `nextRunAt` — the repository
///   never computes it (compute logic lives in [RecurringRule]).
abstract class RecurringTransactionRepository {
  /// Returns all rules (including inactive) sorted by id.
  Future<List<RecurringRule>> watchAll();

  /// Returns all rules (including inactive).
  Future<List<RecurringRule>> getAll();

  /// Returns rules that are due: active and `nextRunAt <= now`.
  Future<List<RecurringRule>> getDueRules(DateTime now);

  /// Fetches one rule by id.
  Future<RecurringRule?> getById(String id);

  /// Inserts a new rule.
  Future<void> save(RecurringRule rule);

  /// Updates an existing rule.
  Future<void> update(RecurringRule rule);

  /// Toggles the rule (kept after last occurrence — e.g. if nextRunAt is past).
  Future<void> setIsActive(String id, {required bool isActive});

  /// Deletes a rule.
  Future<void> delete(String id);
}
