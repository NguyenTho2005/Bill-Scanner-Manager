import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:equatable/equatable.dart';

/// A transaction proposed by the assistant from a free-form chat message.
///
/// Nothing is written to the database until the user confirms the draft.
class TransactionDraft extends Equatable {
  /// Creates a [TransactionDraft].
  const TransactionDraft({
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.occurredAt,
    this.note,
    this.type = TransactionType.expense,
  });

  /// Empty draft used when stored JSON is unreadable.
  factory TransactionDraft.empty() => TransactionDraft(
        amount: 0,
        categoryId: 'other',
        categoryName: 'Khác',
        occurredAt: DateTime.now(),
      );

  /// Restores a draft from its JSON form.
  factory TransactionDraft.fromJson(Map<String, dynamic> json) {
    return TransactionDraft(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      categoryId: json['categoryId'] as String? ?? 'other',
      categoryName: json['categoryName'] as String? ?? 'Khác',
      occurredAt: DateTime.tryParse(json['occurredAt'] as String? ?? '') ??
          DateTime.now(),
      type: TransactionType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      note: json['note'] as String?,
    );
  }

  /// Amount in VND.
  final double amount;

  /// Resolved category identifier.
  final String categoryId;

  /// Human-readable category name.
  final String categoryName;

  /// When the expense happened.
  final DateTime occurredAt;

  /// Short description extracted from the message ("cà phê sữa").
  final String? note;

  /// Whether money left or entered the wallet.
  final TransactionType type;

  /// Whether the draft has enough information to be saved.
  bool get isSavable => amount > 0;

  /// Returns a copy with selected fields replaced.
  TransactionDraft copyWith({
    double? amount,
    String? categoryId,
    String? categoryName,
    DateTime? occurredAt,
    String? note,
    TransactionType? type,
  }) {
    return TransactionDraft(
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
      type: type ?? this.type,
    );
  }

  /// JSON-serializable representation.
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'occurredAt': occurredAt.toIso8601String(),
        'type': type.name,
        if (note != null) 'note': note,
      };

  @override
  List<Object?> get props =>
      [amount, categoryId, categoryName, occurredAt, note, type];
}
