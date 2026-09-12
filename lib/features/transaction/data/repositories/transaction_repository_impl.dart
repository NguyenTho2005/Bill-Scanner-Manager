import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:bill_tracker/features/transaction/data/repositories/category_repository_impl.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction_media.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:drift/drift.dart';

/// Drift implementation of [TransactionRepository].
class TransactionRepositoryImpl implements TransactionRepository {
  /// Creates [TransactionRepositoryImpl] with [AppDatabase].
  TransactionRepositoryImpl(this._db, [this._budgetRepository]);

  final AppDatabase _db;
  final BudgetRepository? _budgetRepository;

  @override
  Future<List<Transaction>> getTransactions({
    TransactionFilter? filter,
  }) async {
    final query = _buildJoinedQuery(filter);
    final rows = await query.get();
    return _mapRowsToTransactions(rows);
  }

  @override
  Stream<List<Transaction>> watchTransactions({
    TransactionFilter? filter,
  }) {
    final query = _buildJoinedQuery(filter);
    return query.watch().map(_mapRowsToTransactions);
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final query = _db.select(_db.transactions).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
      leftOuterJoin(
        _db.transactionMedias,
        _db.transactionMedias.transactionId.equalsExp(_db.transactions.id),
      ),
    ])
      ..where(_db.transactions.id.equals(id))
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final txRow = row.readTable(_db.transactions);
    final catRow = row.readTableOrNull(_db.categories);
    final mediaRow = row.readTableOrNull(_db.transactionMedias);

    return _mapRowToTransaction(txRow, catRow, mediaRow);
  }

  @override
  Future<void> createTransaction(
    Transaction transaction, {
    TransactionMedia? media,
  }) async {
    await _db.transaction(() async {
      await _db.into(_db.transactions).insert(transaction.toCompanion());
      if (media != null) {
        await _db.into(_db.transactionMedias).insert(media.toCompanion());
      }
    });
    await _budgetRepository?.checkAndTriggerAlerts();
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _db.update(_db.transactions).replace(transaction.toCompanion());
    await _budgetRepository?.checkAndTriggerAlerts();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _db.transaction(() async {
      // Delete associated media
      await (_db.delete(_db.transactionMedias)
            ..where((t) => t.transactionId.equals(id)))
          .go();
      // Delete associated line items if any
      await (_db.delete(_db.receiptLineItems)
            ..where((t) => t.transactionId.equals(id)))
          .go();
      // Delete associated receipt extraction if any
      await (_db.delete(_db.receiptExtractions)
            ..where((t) => t.transactionId.equals(id)))
          .go();
      // Delete transaction row
      await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<List<TransactionMedia>> getMediasForTransaction(
    String transactionId,
  ) async {
    final query = _db.select(_db.transactionMedias)
      ..where((t) => t.transactionId.equals(transactionId));
    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  JoinedSelectStatement<HasResultSet, dynamic> _buildJoinedQuery(
    TransactionFilter? filter,
  ) {
    final query = _db.select(_db.transactions).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
      leftOuterJoin(
        _db.transactionMedias,
        _db.transactionMedias.transactionId.equalsExp(_db.transactions.id),
      ),
    ]);

    if (filter != null) {
      if (filter.startDate != null) {
        query.where(
          _db.transactions.occurredAt.isBiggerOrEqualValue(filter.startDate!),
        );
      }
      if (filter.endDate != null) {
        query.where(
          _db.transactions.occurredAt.isSmallerOrEqualValue(filter.endDate!),
        );
      }
      if (filter.categoryId != null) {
        query.where(_db.transactions.categoryId.equals(filter.categoryId!));
      }
      if (filter.source != null) {
        query.where(_db.transactions.source.equals(filter.source!.name));
      }
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final pattern = '%${filter.searchQuery!}%';
        query.where(
          _db.transactions.merchant.like(pattern) |
              _db.transactions.note.like(pattern),
        );
      }
    }

    query.orderBy([
      OrderingTerm.desc(_db.transactions.occurredAt),
      OrderingTerm.desc(_db.transactions.createdAt),
    ]);

    return query;
  }

  List<Transaction> _mapRowsToTransactions(List<TypedResult> rows) {
    // Deduplicate by transaction id in case of multiple media joins
    final map = <String, Transaction>{};
    for (final row in rows) {
      final txRow = row.readTable(_db.transactions);
      if (!map.containsKey(txRow.id)) {
        final catRow = row.readTableOrNull(_db.categories);
        final mediaRow = row.readTableOrNull(_db.transactionMedias);
        map[txRow.id] = _mapRowToTransaction(txRow, catRow, mediaRow);
      }
    }
    return map.values.toList();
  }

  Transaction _mapRowToTransaction(
    TransactionRow tx,
    CategoryRow? cat,
    TransactionMediaRow? media,
  ) {
    return Transaction(
      id: tx.id,
      type: TransactionType.values.byName(tx.type),
      amount: tx.amount,
      currency: tx.currency,
      categoryId: tx.categoryId,
      occurredAt: tx.occurredAt,
      source: TransactionSource.values.byName(tx.source),
      status: TransactionStatus.values.byName(tx.status),
      createdAt: tx.createdAt,
      updatedAt: tx.updatedAt,
      merchant: tx.merchant,
      note: tx.note,
      paymentMethod: tx.paymentMethod != null
          ? PaymentMethod.values.byName(tx.paymentMethod!)
          : null,
      category: cat?.toDomain(),
      thumbnailPath: media?.thumbnailPath,
    );
  }
}

/// Mapper extension for [Transaction] to [TransactionsCompanion].
extension TransactionCompanionX on Transaction {
  /// Converts domain entity to Drift companion for storage.
  TransactionsCompanion toCompanion() => TransactionsCompanion(
        id: Value(id),
        type: Value(type.name),
        amount: Value(amount),
        currency: Value(currency),
        categoryId: Value(categoryId),
        merchant: Value(merchant),
        occurredAt: Value(occurredAt),
        note: Value(note),
        paymentMethod: Value(paymentMethod?.name),
        source: Value(source.name),
        status: Value(status.name),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
      );
}

/// Mapper extension for [TransactionMedia] to Drift companion and domain.
extension TransactionMediaCompanionX on TransactionMedia {
  /// Converts domain media to Drift companion for storage.
  TransactionMediasCompanion toCompanion() => TransactionMediasCompanion(
        id: Value(id),
        transactionId: Value(transactionId),
        type: Value(type.name),
        originalPath: Value(originalPath),
        compressedPath: Value(compressedPath),
        thumbnailPath: Value(thumbnailPath),
        hash: Value(hash),
        width: Value(width),
        height: Value(height),
        fileSizeBytes: Value(fileSizeBytes),
        capturedAt: Value(capturedAt),
      );
}

/// Mapper extension for [TransactionMediaRow] to domain [TransactionMedia].
extension TransactionMediaRowX on TransactionMediaRow {
  /// Converts Drift row to domain [TransactionMedia].
  TransactionMedia toDomain() => TransactionMedia(
        id: id,
        transactionId: transactionId,
        type: MediaType.values.byName(type),
        compressedPath: compressedPath,
        thumbnailPath: thumbnailPath,
        hash: hash,
        originalPath: originalPath,
        width: width,
        height: height,
        fileSizeBytes: fileSizeBytes,
        capturedAt: capturedAt,
      );
}
