/// Maps syncable mobile entities to/from server JSON payloads (snake_case
/// column names, per backend `serialize_entity` / §3.8).
library;

import 'package:bill_tracker/core/database/converters/snake_case_converters.dart';
import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction_media.dart';

/// Builds the server upsert payload for a transaction.
Map<String, Object?> transactionPayload(Transaction tx) {
  return {
    'id': tx.id,
    'type': tx.type.name,
    'amount': tx.amount,
    'currency': tx.currency,
    'category_id': tx.categoryId,
    'merchant': tx.merchant,
    'occurred_at': tx.occurredAt.toIso8601String(),
    'note': tx.note,
    'payment_method': tx.paymentMethod?.name,
    'source': tx.source.name,
    'status': tx.status.name,
    'is_shared': tx.isShared,
    'household_id': tx.householdId,
    'created_at': tx.createdAt.toIso8601String(),
    'updated_at': tx.updatedAt.toIso8601String(),
  };
}

/// Builds the server upsert payload for a category.
Map<String, Object?> categoryPayload(Category category) {
  return {
    'id': category.id,
    'parent_id': category.parentId,
    'name': category.name,
    'icon': category.icon,
    'color_value': category.colorValue,
    'is_system': category.isSystem,
    'sort_order': category.sortOrder,
  };
}

/// Builds the server upsert payload for a budget.
Map<String, Object?> budgetPayload(Budget budget) {
  return {
    'id': budget.id,
    'household_id': budget.householdId,
    'category_id': budget.categoryId,
    'period': budget.period,
    'amount_limit': budget.amountLimit,
    'alert_thresholds': budget.alertThresholds,
    'alert_sent_at_80': budget.alertSentAt80,
    'alert_sent_at_100': budget.alertSentAt100,
    // Mobile-only flag (§4.6 #16); ignored by backends without the column.
    'alert_sent_at_120': budget.alertSentAt120,
    'period_start': budget.periodStart.toIso8601String(),
    'period_end': budget.periodEnd.toIso8601String(),
  };
}

/// Builds the server upsert payload for a transaction media row.
Map<String, Object?> mediaPayload(TransactionMedia media) {
  return {
    'id': media.id,
    'transaction_id': media.transactionId,
    'type': media.type.name,
    'original_path': media.originalPath,
    'compressed_path': media.compressedPath,
    'thumbnail_path': media.thumbnailPath,
    'hash': media.hash,
    'width': media.width,
    'height': media.height,
    'file_size_bytes': media.fileSizeBytes,
    'captured_at': media.capturedAt?.toIso8601String(),
  };
}

/// Builds the server upsert payload for a receipt extraction.
///
/// `raw_text` is deliberately absent: the backend has no such column (see
/// PROJECT_CONTEXT §4.6 #21) and must not receive it.
Map<String, Object?> receiptExtractionPayload({
  required String transactionId,
  String? merchant,
  double? merchantConfidence,
  bool merchantUserEdited = false,
  DateTime? transactionDate,
  double? dateConfidence,
  double? total,
  double? totalConfidence,
  double? subtotal,
  double? tax,
  String? paymentMethod,
  double? overallConfidence,
  bool requiresReview = false,
}) {
  return {
    'transaction_id': transactionId,
    'merchant': merchant,
    'merchant_confidence': merchantConfidence,
    'merchant_user_edited': merchantUserEdited,
    'transaction_date': transactionDate?.toIso8601String(),
    'date_confidence': dateConfidence,
    'total': total,
    'total_confidence': totalConfidence,
    'subtotal': subtotal,
    'tax': tax,
    'payment_method': paymentMethod,
    'overall_confidence': overallConfidence,
    'requires_review': requiresReview,
  };
}

/// Builds the server upsert payload for a receipt line item.
Map<String, Object?> receiptLineItemPayload({
  required String id,
  required String transactionId,
  required String name,
  double? quantity,
  double? unitPrice,
  double? total,
  String? categorySuggestion,
  double confidence = 1,
}) {
  return {
    'id': id,
    'transaction_id': transactionId,
    'name': name,
    'quantity': quantity,
    'unit_price': unitPrice,
    'total': total,
    'category_suggestion': categorySuggestion,
    'confidence': confidence,
  };
}

/// Parses a server transaction payload back into a domain [Transaction].
Transaction transactionFromPayload(Map<String, Object?> payload) {
  return Transaction(
    id: (payload['id'] as String?) ?? '',
    type: TransactionType.values
        .byName((payload['type'] as String?) ?? 'expense'),
    amount: (payload['amount'] as num?)?.toDouble() ?? 0,
    currency: (payload['currency'] as String?) ?? 'VND',
    categoryId: (payload['category_id'] as String?) ?? '',
    merchant: payload['merchant'] as String?,
    occurredAt: DateTime.tryParse((payload['occurred_at'] as String?) ?? '') ??
        DateTime.now(),
    note: payload['note'] as String?,
    paymentMethod: (payload['payment_method'] as String?) == null
        ? null
        : PaymentMethod.values.byName((payload['payment_method'] as String?)!),
    source: const TransactionSourceConverter()
        .fromSql((payload['source'] as String?) ?? 'manual'),
    status: const TransactionStatusConverter()
        .fromSql((payload['status'] as String?) ?? 'confirmed'),
    createdAt: DateTime.tryParse((payload['created_at'] as String?) ?? '') ??
        DateTime.now(),
    updatedAt: DateTime.tryParse((payload['updated_at'] as String?) ?? '') ??
        DateTime.now(),
    isShared: (payload['is_shared'] as bool?) ?? false,
    householdId: payload['household_id'] as String?,
    createdByUserId: payload['created_by_user_id'] as String?,
    createdByName: payload['created_by_name'] as String?,
  );
}

/// Parses a server category payload back into a domain [Category].
Category categoryFromPayload(Map<String, Object?> payload) {
  return Category(
    id: (payload['id'] as String?) ?? '',
    parentId: payload['parent_id'] as String?,
    name: (payload['name'] as String?) ?? '',
    icon: (payload['icon'] as String?) ?? 'more_horiz',
    colorValue: (payload['color_value'] as num?)?.toInt() ?? 0,
    isSystem: (payload['is_system'] as bool?) ?? false,
    sortOrder: (payload['sort_order'] as num?)?.toInt() ?? 0,
  );
}

/// Parses a server budget payload back into a domain [Budget].
Budget budgetFromPayload(Map<String, Object?> payload) {
  final rawThresholds = payload['alert_thresholds'];
  var thresholds = const <double>[0.8, 1, 1.2];
  if (rawThresholds is List) {
    thresholds = rawThresholds.map((e) => (e as num).toDouble()).toList();
  } else if (rawThresholds is String && rawThresholds.trim().isNotEmpty) {
    final cleaned = rawThresholds.replaceAll('[', '').replaceAll(']', '');
    final parsed = cleaned
        .split(',')
        .map((s) => double.tryParse(s.trim()))
        .whereType<double>()
        .toList();
    if (parsed.isNotEmpty) thresholds = parsed;
  }

  return Budget(
    id: (payload['id'] as String?) ?? '',
    householdId: payload['household_id'] as String?,
    categoryId: (payload['category_id'] as String?) ?? '',
    amountLimit: (payload['amount_limit'] as num?)?.toDouble() ?? 0,
    periodStart:
        DateTime.tryParse((payload['period_start'] as String?) ?? '') ??
            DateTime.now(),
    periodEnd: DateTime.tryParse((payload['period_end'] as String?) ?? '') ??
        DateTime.now(),
    period: (payload['period'] as String?) ?? 'monthly',
    alertThresholds: thresholds,
    alertSentAt80: (payload['alert_sent_at_80'] as bool?) ?? false,
    alertSentAt100: (payload['alert_sent_at_100'] as bool?) ?? false,
    alertSentAt120: (payload['alert_sent_at_120'] as bool?) ?? false,
    category: null,
  );
}
