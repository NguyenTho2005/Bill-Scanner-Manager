import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/notifications/notification_service.dart';
import 'package:bill_tracker/core/utils/id_generator.dart';
import 'package:bill_tracker/features/transaction/domain/entities/recurring_rule.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/recurring_transaction_repository.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:bill_tracker/features/transaction/domain/services/recurring_transaction_service.dart';

/// Drift implementation of [RecurringTransactionService].
///
/// Uses [RecurringTransactionRepository] (rules) + [TransactionRepository]
/// (writes), mirrors the layering of other services (§4.1).
class RecurringTransactionServiceImpl implements RecurringTransactionService {
  /// Creates [RecurringTransactionServiceImpl].
  RecurringTransactionServiceImpl({
    required RecurringTransactionRepository recurringRepo,
    TransactionRepository? txRepo,
    NotificationService? notificationService,
  })  : _recurringRepo = recurringRepo,
        _txRepo = txRepo,
        _notificationService = notificationService;

  final RecurringTransactionRepository _recurringRepo;
  final TransactionRepository? _txRepo;
  final NotificationService? _notificationService;

  /// Maximum occurrences to materialize per rule in one scan (safety net).
  static const int _maxOccurrencesPerRule = 50000;

  /// Builds the [Transaction] for one occurrence of [rule].
  static Transaction buildRecurringTransaction(
    RecurringRule rule,
    DateTime occurredAt,
  ) {
    return Transaction(
      id: IdGenerator.generateV7(),
      type: rule.type,
      amount: rule.amount,
      currency: rule.currency,
      categoryId: rule.categoryId,
      merchant: rule.merchant,
      note: rule.note,
      occurredAt: occurredAt,
      source: TransactionSource.recurring,
      status: TransactionStatus.confirmed,
      createdAt: occurredAt,
      updatedAt: occurredAt,
    );
  }

  @override
  Future<int> checkAndRunDueRules() async {
    final now = DateTime.now();
    final rules = await _recurringRepo.getDueRules(now);
    var totalCreated = 0;

    for (final rule in rules) {
      if (rule.endDate != null && rule.endDate!.isBefore(now)) continue;

      final createdTx = <Transaction>[];
      var candidate = rule.nextRunAt;
      var guard = 0;
      while (candidate.isBefore(now) &&
          (rule.endDate == null || candidate.isBefore(rule.endDate!))) {
        createdTx.add(buildRecurringTransaction(rule, candidate));
        candidate = RecurringRule.computeNextRunAt(rule, candidate);
        guard++;
        if (guard > _maxOccurrencesPerRule) break;
      }

      // Advance the rule so no occurrence is scheduled twice.
      final advanced =
          rule.copyWith(nextRunAt: RecurringRule.computeNextRunAt(rule, now));
      await _recurringRepo.update(advanced);
      totalCreated += createdTx.length;

      if (createdTx.isNotEmpty) {
        final first = createdTx.first;
        await _notificationService?.showRecurringTransactionAlert(
          id: rule.id.hashCode.abs() % 1000000 + createdTx.length,
          title: 'Giao dịch định kịt (${rule.frequency.name})',
          body: '${first.amount.toVnd()} • '
              '${rule.merchant ?? rule.categoryId}',
          payload: first.id,
        );
        if (_txRepo != null) {
          for (final tx in createdTx) {
            await _txRepo.createTransaction(tx);
          }
        }
      }
    }
    return totalCreated;
  }
}
