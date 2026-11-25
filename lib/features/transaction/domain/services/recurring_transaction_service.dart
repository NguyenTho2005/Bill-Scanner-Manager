import 'package:bill_tracker/features/transaction/domain/entities/recurring_rule.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart' show Transaction;

// Intentionally an interface: it is the seam for unit tests and DI.
// ignore_for_file: one_member_abstracts, document_ignores

/// Domain-level service that materializes recurring transaction rules into
/// real transactions when their [RecurringRule.nextRunAt] comes due.
abstract class RecurringTransactionService {
  /// Scans due rules (`isActive && nextRunAt <= now`) and creates
  /// [Transaction] occurrences for each, then advances the rule's
  /// `nextRunAt` past `now`.
  ///
  /// Returns the number of transactions created.
  Future<int> checkAndRunDueRules();
}
