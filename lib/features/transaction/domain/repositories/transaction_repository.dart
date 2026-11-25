import 'package:bill_tracker/core/ai/price_text_extractor.dart';
import 'package:bill_tracker/core/ai/product_classifier.dart';
import 'package:bill_tracker/core/ai/receipt_ocr_service.dart';
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

  /// Persists the confirmed receipt scan data after user review (§4.6 #14).
  ///
  /// Stores one receipt-extraction row (including the raw OCR text, kept
  /// local-only for debug/retrain — never synced, §4.6 #21) and one
  /// receipt-line-item row per confirmed line item, enqueuing outbox
  /// operations for the syncable rows.
  Future<void> saveReceiptScanData({
    required String transactionId,
    required ReceiptExtractionResult extraction,
    required List<ParsedLineItem> lineItems,
  });

  /// Persists the AI inference audit row for a Product Snap capture
  /// (§4.6 #15): image-labeling classification plus optional on-device
  /// price OCR results (stored in `extracted_amounts_json`).
  Future<void> saveProductSnapInference({
    required String mediaId,
    required ProductClassificationResult classification,
    PriceOcrResult? priceOcr,
    String? priceOcrModelVersion,
  });
}
