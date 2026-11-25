import 'package:bill_tracker/features/assistant/domain/entities/transaction_draft.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';

/// A single row inside a [MetricBlock] — "Tổng chi" / "1.250.000đ".
class MetricRow {
  /// Creates a [MetricRow].
  const MetricRow({required this.label, required this.value, this.hint});

  /// Restores a row from its JSON form.
  factory MetricRow.fromJson(Map<String, dynamic> json) => MetricRow(
        label: json['label'] as String? ?? '',
        value: json['value'] as String? ?? '',
        hint: json['hint'] as String?,
      );

  /// Row label, e.g. "Tổng chi".
  final String label;

  /// Formatted value, e.g. "1.250.000đ".
  final String value;

  /// Optional secondary line, e.g. "42% tổng chi".
  final String? hint;

  /// JSON-serializable representation.
  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        if (hint != null) 'hint': hint,
      };
}

/// Compact, persistence-safe snapshot of a transaction for chat cards.
class TransactionPreview {
  /// Creates a [TransactionPreview].
  const TransactionPreview({
    required this.id,
    required this.amount,
    required this.occurredAt,
    required this.categoryName,
    required this.categoryColorValue,
    this.merchant,
    this.note,
  });

  /// Restores a preview from its JSON form.
  factory TransactionPreview.fromJson(Map<String, dynamic> json) {
    return TransactionPreview(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      occurredAt: DateTime.tryParse(json['occurredAt'] as String? ?? '') ??
          DateTime.now(),
      categoryName: json['categoryName'] as String? ?? 'Khác',
      categoryColorValue:
          (json['categoryColorValue'] as num?)?.toInt() ?? 0xFF9E9E9E,
      merchant: json['merchant'] as String?,
      note: json['note'] as String?,
    );
  }

  /// Builds a preview from a domain [Transaction].
  factory TransactionPreview.fromTransaction(Transaction transaction) {
    return TransactionPreview(
      id: transaction.id,
      amount: transaction.amount,
      occurredAt: transaction.occurredAt,
      categoryName: transaction.category?.name ?? 'Khác',
      categoryColorValue: transaction.category?.colorValue ?? 0xFF9E9E9E,
      merchant: transaction.merchant,
      note: transaction.note,
    );
  }

  /// Transaction identifier.
  final String id;

  /// Amount in VND.
  final double amount;

  /// When the transaction happened.
  final DateTime occurredAt;

  /// Display name of the category.
  final String categoryName;

  /// Category color as ARGB integer.
  final int categoryColorValue;

  /// Merchant / store name.
  final String? merchant;

  /// Free-form note.
  final String? note;

  /// JSON-serializable representation.
  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'occurredAt': occurredAt.toIso8601String(),
        'categoryName': categoryName,
        'categoryColorValue': categoryColorValue,
        if (merchant != null) 'merchant': merchant,
        if (note != null) 'note': note,
      };
}

/// Lifecycle of a draft proposed by the assistant.
enum DraftState {
  /// Waiting for the user to confirm or dismiss.
  pending,

  /// Saved into the local transaction table.
  created,

  /// Discarded by the user.
  dismissed,
}

/// Rich content attached to an assistant message.
///
/// Blocks are stored as JSON inside `chat_messages.blocksJson` so chat history
/// survives app restarts without re-querying the database.
sealed class AssistantBlock {
  const AssistantBlock();

  /// Stable discriminator persisted in JSON.
  String get type;

  /// JSON-serializable representation.
  Map<String, dynamic> toJson();

  /// Restores any block from its JSON form, or `null` when unknown.
  static AssistantBlock? fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'metrics':
        return MetricBlock.fromJson(json);
      case 'transactions':
        return TransactionsBlock.fromJson(json);
      case 'draft':
        return DraftBlock.fromJson(json);
      case 'note':
        return NoteBlock.fromJson(json);
      default:
        return null;
    }
  }
}

/// A titled table of label/value rows (totals, budgets, diagnostics).
final class MetricBlock extends AssistantBlock {
  /// Creates a [MetricBlock].
  const MetricBlock({required this.rows, this.title});

  /// Restores the block from JSON.
  factory MetricBlock.fromJson(Map<String, dynamic> json) => MetricBlock(
        title: json['title'] as String?,
        rows: (json['rows'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(MetricRow.fromJson)
            .toList(),
      );

  /// Optional block heading.
  final String? title;

  /// Ordered rows.
  final List<MetricRow> rows;

  @override
  String get type => 'metrics';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (title != null) 'title': title,
        'rows': rows.map((row) => row.toJson()).toList(),
      };
}

/// A list of transactions rendered as compact photo rows.
final class TransactionsBlock extends AssistantBlock {
  /// Creates a [TransactionsBlock].
  const TransactionsBlock({
    required this.items,
    this.title,
    this.totalAmount,
  });

  /// Restores the block from JSON.
  factory TransactionsBlock.fromJson(Map<String, dynamic> json) {
    return TransactionsBlock(
      title: json['title'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TransactionPreview.fromJson)
          .toList(),
    );
  }

  /// Optional block heading.
  final String? title;

  /// Transactions to display, already ordered for the answer.
  final List<TransactionPreview> items;

  /// Optional sum shown in the footer.
  final double? totalAmount;

  @override
  String get type => 'transactions';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (title != null) 'title': title,
        if (totalAmount != null) 'totalAmount': totalAmount,
        'items': items.map((item) => item.toJson()).toList(),
      };
}

/// A proposed transaction the user can confirm with one tap.
final class DraftBlock extends AssistantBlock {
  /// Creates a [DraftBlock].
  const DraftBlock({
    required this.draft,
    this.state = DraftState.pending,
  });

  /// Restores the block from JSON.
  factory DraftBlock.fromJson(Map<String, dynamic> json) {
    final rawDraft = json['draft'];
    return DraftBlock(
      draft: rawDraft is Map<String, dynamic>
          ? TransactionDraft.fromJson(rawDraft)
          : TransactionDraft.empty(),
      state: DraftState.values.firstWhere(
        (value) => value.name == json['state'],
        orElse: () => DraftState.pending,
      ),
    );
  }

  /// Parsed draft data.
  final TransactionDraft draft;

  /// Current lifecycle state.
  final DraftState state;

  /// Returns a copy with a new [state].
  DraftBlock copyWith({DraftState? state}) =>
      DraftBlock(draft: draft, state: state ?? this.state);

  @override
  String get type => 'draft';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'state': state.name,
        'draft': draft.toJson(),
      };
}

/// Visual tone for a [NoteBlock].
enum NoteTone {
  /// Neutral informational note.
  info,

  /// Warning about privacy / configuration.
  warning,

  /// Positive confirmation.
  success,
}

/// A short callout, optionally copyable (e.g. support diagnostics).
final class NoteBlock extends AssistantBlock {
  /// Creates a [NoteBlock].
  const NoteBlock({
    required this.text,
    this.tone = NoteTone.info,
    this.copyable = false,
  });

  /// Restores the block from JSON.
  factory NoteBlock.fromJson(Map<String, dynamic> json) => NoteBlock(
        text: json['text'] as String? ?? '',
        tone: NoteTone.values.firstWhere(
          (value) => value.name == json['tone'],
          orElse: () => NoteTone.info,
        ),
        copyable: json['copyable'] as bool? ?? false,
      );

  /// Callout body.
  final String text;

  /// Visual tone.
  final NoteTone tone;

  /// Whether the UI should offer a "copy" affordance.
  final bool copyable;

  @override
  String get type => 'note';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'text': text,
        'tone': tone.name,
        'copyable': copyable,
      };
}
