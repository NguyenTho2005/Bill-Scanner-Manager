import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction_media.dart';

/// Filter options for querying transactions.
class TransactionFilter {
  /// Creates a [TransactionFilter].
  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.source,
    this.searchQuery,
    this.minAmount,
    this.maxAmount,
  });

  /// Optional start date (inclusive).
  final DateTime? startDate;

  /// Optional end date (inclusive).
  final DateTime? endDate;

  /// Optional category filter.
  final String? categoryId;

  /// Optional source filter (productSnap, receiptScan, etc.).
  final TransactionSource? source;

  /// Optional search text (matches merchant or note).
  final String? searchQuery;

  /// Optional inclusive lower bound on the transaction amount.
  final double? minAmount;

  /// Optional inclusive upper bound on the transaction amount.
  final double? maxAmount;
}

/// Repository interface for transactions and attached media.
abstract class TransactionRepository {
  /// Retrieves transactions matching the given filter.
  Future<List<Transaction>> getTransactions({TransactionFilter? filter});

  /// Emits reactive list of transactions matching the filter.
  Stream<List<Transaction>> watchTransactions({TransactionFilter? filter});

  /// Retrieves a single transaction by its ID with populated category.
  Future<Transaction?> getTransactionById(String id);

  /// Saves a new transaction with optional attached media.
  Future<void> createTransaction(
    Transaction transaction, {
    TransactionMedia? media,
  });

  /// Updates an existing transaction.
  Future<void> updateTransaction(Transaction transaction);

  /// Deletes a transaction and its associated media rows.
  Future<void> deleteTransaction(String id);

  /// Retrieves all media items attached to a transaction.
  Future<List<TransactionMedia>> getMediasForTransaction(String transactionId);
}
