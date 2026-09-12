import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction_media.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [TransactionRepository].
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return getIt<TransactionRepository>();
});

/// Current active filter for transactions list/feed.
final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return const TransactionFilter();
});

/// Reactive stream of transactions matching current filter.
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final filter = ref.watch(transactionFilterProvider);
  return repo.watchTransactions(filter: filter);
});

/// Provider for fetching a single transaction by ID.
final transactionDetailProvider =
    FutureProvider.family<Transaction?, String>((ref, id) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionById(id);
});

/// Controller for creating, updating, and deleting transactions.
class TransactionController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Creates a new transaction.
  Future<bool> create({
    required Transaction transaction,
    TransactionMedia? media,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.createTransaction(transaction, media: media);
    });
    return !state.hasError;
  }

  /// Updates an existing transaction.
  Future<bool> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.updateTransaction(transaction);
    });
    return !state.hasError;
  }

  /// Deletes a transaction by ID.
  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.deleteTransaction(id);
    });
    return !state.hasError;
  }
}

/// Provider for [TransactionController].
final transactionControllerProvider =
    AsyncNotifierProvider.autoDispose<TransactionController, void>(
  TransactionController.new,
);
