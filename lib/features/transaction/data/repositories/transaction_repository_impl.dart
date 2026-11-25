import 'dart:convert';

import 'package:bill_tracker/core/ai/price_text_extractor.dart';
import 'package:bill_tracker/core/ai/product_classifier.dart';
import 'package:bill_tracker/core/ai/receipt_ocr_service.dart';
import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/converters/snake_case_converters.dart';
import 'package:bill_tracker/core/utils/id_generator.dart';
import 'package:bill_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:bill_tracker/features/transaction/data/repositories/category_repository_impl.dart';
import 'package:bill_tracker/features/transaction/data/sync/entity_serializer.dart';
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

  /// Enqueues a sync outbox row inside the caller's transaction.
  Future<void> _enqueueOutbox({
    required String entityType,
    required String entityId,
    required String operation,
    Map<String, Object?>? payload,
  }) async {
    await _db.into(_db.syncOutbox).insert(
          SyncOutboxCompanion.insert(
            id: 'sync_${entityType}_${entityId}_${DateTime.now().millisecondsSinceEpoch}',
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payloadJson: Value(jsonEncode(payload ?? {})),
            createdAt: DateTime.now(),
          ),
        );
  }

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
      await _enqueueOutbox(
        entityType: 'transaction',
        entityId: transaction.id,
        operation: 'upsert',
        payload: transactionPayload(transaction),
      );
      if (media != null) {
        await _enqueueOutbox(
          entityType: 'media',
          entityId: media.id,
          operation: 'upsert',
          payload: mediaPayload(media),
        );
      }
    });
    await _budgetRepository?.checkAndTriggerAlerts();
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _db.transaction(() async {
      await _db.update(_db.transactions).replace(transaction.toCompanion());
      await _enqueueOutbox(
        entityType: 'transaction',
        entityId: transaction.id,
        operation: 'upsert',
        payload: transactionPayload(transaction),
      );
    });
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
      await _enqueueOutbox(
        entityType: 'transaction',
        entityId: id,
        operation: 'delete',
      );
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

  @override
  Future<void> saveReceiptScanData({
    required String transactionId,
    required ReceiptExtractionResult extraction,
    required List<ParsedLineItem> lineItems,
  }) async {
    await _db.transaction(() async {
      // Extraction row — rawText is stored locally for debug/retrain only
      // (§4.6 #21: backend has no raw_text column, never synced).
      await _db
          .into(_db.receiptExtractions)
          .insertOnConflictUpdate(
            ReceiptExtractionsCompanion.insert(
              transactionId: transactionId,
              merchant: Value(extraction.merchant),
              merchantConfidence: Value(extraction.merchantConfidence),
              transactionDate: Value(extraction.transactionDate),
              dateConfidence: Value(extraction.dateConfidence),
              total: Value(extraction.total),
              totalConfidence: Value(extraction.totalConfidence),
              subtotal: Value(extraction.subtotal),
              tax: Value(extraction.tax),
              paymentMethod: Value(
                extraction.paymentMethod == null
                    ? null
                    : const PaymentMethodConverter()
                        .fromSql(extraction.paymentMethod!),
              ),
              overallConfidence: extraction.overallConfidence,
              rawText: Value(extraction.rawText),
              requiresReview: Value(extraction.requiresReview),
            ),
          );
      await _enqueueOutbox(
        entityType: 'receipt_extraction',
        entityId: transactionId,
        operation: 'upsert',
        payload: receiptExtractionPayload(
          transactionId: transactionId,
          merchant: extraction.merchant,
          merchantConfidence: extraction.merchantConfidence,
          transactionDate: extraction.transactionDate,
          dateConfidence: extraction.dateConfidence,
          total: extraction.total,
          totalConfidence: extraction.totalConfidence,
          subtotal: extraction.subtotal,
          tax: extraction.tax,
          paymentMethod: extraction.paymentMethod,
          overallConfidence: extraction.overallConfidence,
          requiresReview: extraction.requiresReview,
        ),
      );

      // Replace any previous line items with the confirmed set.
      await (_db.delete(_db.receiptLineItems)
            ..where((t) => t.transactionId.equals(transactionId)))
          .go();
      for (final item in lineItems) {
        final itemId = IdGenerator.generate();
        await _db.into(_db.receiptLineItems).insert(
              ReceiptLineItemsCompanion.insert(
                id: itemId,
                transactionId: transactionId,
                name: item.name,
                quantity: Value(item.quantity),
                unitPrice: Value(item.unitPrice),
                total: item.total,
                categorySuggestion: Value(item.categorySuggestion),
                confidence: Value(item.confidence),
              ),
            );
        await _enqueueOutbox(
          entityType: 'receipt_line_item',
          entityId: itemId,
          operation: 'upsert',
          payload: receiptLineItemPayload(
            id: itemId,
            transactionId: transactionId,
            name: item.name,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            total: item.total,
            categorySuggestion: item.categorySuggestion,
            confidence: item.confidence,
          ),
        );
      }
    });
  }

  @override
  Future<void> saveProductSnapInference({
    required String mediaId,
    required ProductClassificationResult classification,
    PriceOcrResult? priceOcr,
    String? priceOcrModelVersion,
  }) async {
    // AI inferences are a local audit log (KPI: OCR total >= 90%) — no
    // outbox enqueue.
    final amounts = priceOcr == null
        ? const <Map<String, Object?>>[]
        : priceOcr.candidates
            .map(
              (c) => {
                'value': c.value,
                'confidence': c.confidence,
              },
            )
            .toList();
    final confidence = priceOcr == null
        ? (classification.labels.isNotEmpty
            ? classification.labels.first.confidence
            : 0.0)
        : (priceOcr.confidentValue?.confidence ??
            (classification.labels.isNotEmpty
                ? classification.labels.first.confidence
                : 0.0));
    await _db.into(_db.aIInferences).insert(
          AIInferencesCompanion.insert(
            id: IdGenerator.generateV7(),
            mediaId: mediaId,
            modelVersion:
                '${classification.modelVersion}+${priceOcrModelVersion ?? 'no-price-ocr'}',
            labelsJson: Value(
              jsonEncode(
                classification.labels
                    .map(
                      (l) => {
                        'name': l.text,
                        'confidence': l.confidence,
                      },
                    )
                    .toList(),
              ),
            ),
            suggestedCategoryId: Value(classification.suggestedCategoryId),
            suggestedCategoryConfidence:
                Value(classification.suggestedCategoryConfidence),
            extractedAmountsJson: Value(jsonEncode(amounts)),
            confidence: confidence,
            latencyMs: classification.latencyMs + (priceOcr?.latencyMs ?? 0),
          ),
        );
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
        query.where(
          _db.transactions.source.equals(
            const TransactionSourceConverter().toSql(filter.source!),
          ),
        );
      }
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final pattern = '%${filter.searchQuery!}%';
        query.where(
          _db.transactions.merchant.like(pattern) |
              _db.transactions.note.like(pattern),
        );
      }
      if (filter.minAmount != null) {
        query.where(
          _db.transactions.amount.isBiggerOrEqualValue(filter.minAmount!),
        );
      }
      if (filter.maxAmount != null) {
        query.where(
          _db.transactions.amount.isSmallerOrEqualValue(filter.maxAmount!),
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
      type: tx.type,
      amount: tx.amount,
      currency: tx.currency,
      categoryId: tx.categoryId,
      occurredAt: tx.occurredAt,
      source: tx.source,
      status: tx.status,
      createdAt: tx.createdAt,
      updatedAt: tx.updatedAt,
      merchant: tx.merchant,
      note: tx.note,
      paymentMethod: tx.paymentMethod,
      category: cat?.toDomain(),
      thumbnailPath: media?.thumbnailPath,
      isShared: tx.isShared,
      householdId: tx.householdId,
      createdByUserId: tx.createdByUserId,
      createdByName: tx.createdByName,
    );
  }
}

/// Mapper extension for [Transaction] to [TransactionsCompanion].
extension TransactionCompanionX on Transaction {
  /// Converts domain entity to Drift companion for storage.
  TransactionsCompanion toCompanion() => TransactionsCompanion(
        id: Value(id),
        type: Value(type),
        amount: Value(amount),
        currency: Value(currency),
        categoryId: Value(categoryId),
        merchant: Value(merchant),
        occurredAt: Value(occurredAt),
        note: Value(note),
        paymentMethod: Value(paymentMethod),
        source: Value(source),
        status: Value(status),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        isShared: Value(isShared),
        householdId: Value(householdId),
        createdByUserId: Value(createdByUserId),
        createdByName: Value(createdByName),
      );
}

/// Mapper extension for [TransactionMedia] to Drift companion and domain.
extension TransactionMediaCompanionX on TransactionMedia {
  /// Converts domain media to Drift companion for storage.
  TransactionMediasCompanion toCompanion() => TransactionMediasCompanion(
        id: Value(id),
        transactionId: Value(transactionId),
        type: Value(type),
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
        type: type,
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
