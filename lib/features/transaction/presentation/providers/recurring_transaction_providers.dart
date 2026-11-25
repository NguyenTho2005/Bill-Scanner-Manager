import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/recurring_transaction_repository.dart';
import 'package:bill_tracker/features/transaction/domain/services/recurring_transaction_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [RecurringTransactionRepository] (get_it singleton).
final recurringTransactionRepositoryProvider =
    Provider<RecurringTransactionRepository>((ref) {
  return getIt<RecurringTransactionRepository>();
});

/// Provider for [RecurringTransactionService] (get_it singleton).
final recurringTransactionServiceProvider =
    Provider<RecurringTransactionService>((ref) {
  return getIt<RecurringTransactionService>();
});
