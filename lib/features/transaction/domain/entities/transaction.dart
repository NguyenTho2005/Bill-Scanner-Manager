import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:equatable/equatable.dart';

/// Type of financial transaction.
enum TransactionType {
  /// Money spent.
  expense,

  /// Money received.
  income,
}

/// Creation origin of the transaction.
enum TransactionSource {
  /// Captured via product photo + AI classification.
  productSnap,

  /// Captured via receipt scanning + OCR.
  receiptScan,

  /// Manually entered by the user.
  manual,

  /// Imported from file/backup.
  import_,
}

/// Processing and confirmation status of the transaction.
enum TransactionStatus {
  /// Draft transaction in review.
  draft,

  /// Confirmed and counted in budgets/reports.
  confirmed,

  /// Requires user review (e.g. low OCR confidence).
  needsReview,

  /// Processing failed.
  failed,
}

/// Payment method used for the transaction.
enum PaymentMethod {
  /// Cash in hand.
  cash,

  /// Debit or credit card.
  card,

  /// Bank transfer.
  transfer,

  /// Electronic wallet (Momo, ZaloPay, ViettelPay, etc.).
  ewallet,

  /// Other payment method.
  other,
}

/// Domain entity representing a financial transaction.
class Transaction extends Equatable {
  /// Creates a [Transaction].
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.categoryId,
    required this.occurredAt,
    required this.source,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.merchant,
    this.note,
    this.paymentMethod,
    this.category,
    this.thumbnailPath,
  });

  /// Unique identifier (ULID / UUID v7).
  final String id;

  /// Expense or income.
  final TransactionType type;

  /// Monetary amount.
  final double amount;

  /// Currency code (e.g. 'VND').
  final String currency;

  /// Foreign key to Category.id.
  final String categoryId;

  /// Optional merchant / store name.
  final String? merchant;

  /// Date and time when the expense occurred.
  final DateTime occurredAt;

  /// Optional note / description.
  final String? note;

  /// Payment method used.
  final PaymentMethod? paymentMethod;

  /// Source how this transaction was entered.
  final TransactionSource source;

  /// Current status.
  final TransactionStatus status;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Populated category entity (optional relation join).
  final Category? category;

  /// Primary thumbnail path if photo is attached (optional relation join).
  final String? thumbnailPath;

  /// Creates a copy of this transaction with modified fields.
  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? currency,
    String? categoryId,
    String? merchant,
    DateTime? occurredAt,
    String? note,
    PaymentMethod? paymentMethod,
    TransactionSource? source,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Category? category,
    String? thumbnailPath,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      merchant: merchant ?? this.merchant,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      source: source ?? this.source,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        currency,
        categoryId,
        merchant,
        occurredAt,
        note,
        paymentMethod,
        source,
        status,
        createdAt,
        updatedAt,
        category,
        thumbnailPath,
      ];
}
