import 'package:bill_tracker/core/utils/vietnamese_text_utils.dart';
import 'package:bill_tracker/features/assistant/domain/entities/transaction_draft.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_nlu.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/services/vietnamese_transaction_query_parser.dart';

/// Turns "cà phê sữa 45k hôm qua" into a structured draft transaction.
///
/// Runs entirely on-device. The draft is never persisted until the user taps
/// the confirm button in the chat.
class ChatExpenseDraftParser {
  /// Creates a parser bound to the user's categories.
  const ChatExpenseDraftParser({required this.categories});

  /// Categories available for guessing the destination bucket.
  final List<Category> categories;

  static final RegExp _amountToken = RegExp(
    r'(\d+(?:[.,]\d+)*)\s*(nghin|ngan|k|trieu|tr)?',
  );

  /// Words that add no value to a note.
  static const _metaWords = [
    'them vao',
    'them',
    'ghi lai',
    'ghi',
    'tao',
    'giup minh',
    'giup',
    'minh',
    'toi',
    'vua',
    'vao',
    'luc',
    'cho',
    'chi',
    'het',
    'mat',
    'thanh toan',
    'tra tien',
    'so tien',
    'khoan',
  ];

  static const _incomeHints = [
    'nhan duoc',
    'nhan tien',
    'luong',
    'thu nhap',
    'duoc tra',
    'hoan tien',
    'ban duoc',
    'thuong',
  ];

  /// Parses [input]; returns `null` when no usable amount is found.
  TransactionDraft? parse(String input, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final flat = VietnameseTextUtils.stripDiacritics(input.toLowerCase());
    final normalized = VietnameseTextUtils.normalize(input);

    final stripped = AssistantNlu.stripTimePhrases(flat);
    final amount = _pickAmount(stripped);
    if (amount == null || amount <= 0) {
      // Still try a bare number once time phrases are gone.
      final fallback = VietnameseTransactionQueryParser.extractAmount(stripped);
      if (fallback == null || fallback <= 0) return null;
      final draft = _build(
        input: input,
        flat: flat,
        amount: fallback,
        reference: reference,
        normalized: normalized,
      );
      return draft;
    }

    return _build(
      input: input,
      flat: flat,
      amount: amount,
      reference: reference,
      normalized: normalized,
    );
  }

  TransactionDraft _build({
    required String input,
    required String flat,
    required double amount,
    required DateTime reference,
    required String normalized,
  }) {
    final note = _extractNote(input: input, flat: flat);
    final isIncome = _incomeHints.any((hint) => normalized.contains(hint));

    final category = _guessCategory(note: note, normalized: normalized);
    final occurredAt = _resolveDate(normalized, reference);

    return TransactionDraft(
      amount: amount,
      categoryId: category.id,
      categoryName: category.name,
      occurredAt: occurredAt,
      note: note.isEmpty ? null : note,
      type: isIncome ? TransactionType.income : TransactionType.expense,
    );
  }

  /// Chooses the most plausible amount token.
  ///
  /// "2 ly cà phê 45k" must yield 45.000, not 2, so tokens carrying a unit
  /// ("k", "triệu") or thousand separators win over bare small numbers.
  double? _pickAmount(String text) {
    double? best;
    var bestScore = -1;

    for (final match in _amountToken.allMatches(text)) {
      final token = match.group(0) ?? '';
      final unit = match.group(2);
      final value = VietnameseTransactionQueryParser.extractAmount(token);
      if (value == null || value <= 0) continue;

      var score = 0;
      if (unit != null) {
        score = 2;
      } else if (value >= 1000) {
        score = 1;
      }

      final isBetter = score > bestScore ||
          (score == bestScore && best != null && value > best);
      if (isBetter) {
        best = value;
        bestScore = score;
      }
    }
    return best;
  }

  /// Builds a human-readable note from the original (accented) text.
  String _extractNote({required String input, required String flat}) {
    final ranges = <({int start, int end})>[];

    // Remove time phrases.
    for (final match in RegExp(
      '(hom kia|hom qua|hom nay|tuan truoc|tuan nay|thang truoc|thang nay|'
      'nam ngoai|nam nay|gan day|moi nhat)',
    ).allMatches(flat)) {
      ranges.add((start: match.start, end: match.end));
    }
    for (final match in RegExp(r'thang\s*\d{1,2}').allMatches(flat)) {
      ranges.add((start: match.start, end: match.end));
    }
    for (final match in RegExp(
      r'\d+\s*(ngay|tuan|thang)\s*(qua|gan day|truoc|tro lai)',
    ).allMatches(flat)) {
      ranges.add((start: match.start, end: match.end));
    }

    // Remove the amount token(s) that carry a unit or separator; keep the
    // leading quantity ("2 ly") since it is part of the description.
    for (final match in _amountToken.allMatches(flat)) {
      final token = match.group(0) ?? '';
      final unit = match.group(2);
      final value = VietnameseTransactionQueryParser.extractAmount(token) ?? 0;
      if (unit == null && value < 1000) continue;
      ranges.add((start: match.start, end: match.end));
    }

    ranges.sort((a, b) => b.start.compareTo(a.start));
    var note = input;
    for (final range in ranges) {
      if (range.start < 0 || range.end > note.length) continue;
      note = note.replaceRange(range.start, range.end, ' ');
    }

    // Remove filler verbs while keeping the accented text intact: match on
    // the length-preserving lowercase-ASCII copy, cut on the original.
    final flatNote = VietnameseTextUtils.stripDiacritics(note.toLowerCase());
    final fillerRanges = <({int start, int end})>[];
    for (final word in _metaWords) {
      for (final match in RegExp(
        '(^|\\s)${RegExp.escape(word)}(\\s|\$)',
      ).allMatches(flatNote)) {
        fillerRanges.add((start: match.start, end: match.end));
      }
    }
    fillerRanges.sort((a, b) => b.start.compareTo(a.start));
    for (final range in fillerRanges) {
      if (range.start < 0 || range.end > note.length) continue;
      note = note.replaceRange(range.start, range.end, ' ');
    }
    final cleaned = note
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\s,.\-–]+|[\s,.\-–]+$'), '')
        .trim();

    // Drop leftover single-letter noise.
    if (cleaned.length < 2) return '';
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  Category _guessCategory({required String note, required String normalized}) {
    final nlu = AssistantNlu(categories: categories);
    final direct = nlu.resolveCategory(VietnameseTextUtils.normalize(note));
    if (direct != null) return direct;

    final hinted = AssistantNlu.categoryIdForKeyword(
      VietnameseTextUtils.normalize('$note $normalized'),
    );
    if (hinted != null) {
      for (final category in categories) {
        if (category.id == hinted) return category;
      }
    }
    return _fallbackCategory();
  }

  Category _fallbackCategory() {
    for (final category in categories) {
      if (category.id == 'other') return category;
    }
    if (categories.isNotEmpty) return categories.first;
    return const Category(
      id: 'other',
      name: 'Khác',
      icon: 'category',
      colorValue: 0xFF9E9E9E,
    );
  }

  DateTime _resolveDate(String normalized, DateTime now) {
    if (normalized.contains('hom qua')) {
      return now.subtract(const Duration(days: 1));
    }
    if (normalized.contains('hom kia')) {
      return now.subtract(const Duration(days: 2));
    }
    if (normalized.contains('thang truoc')) {
      final previous = DateTime(now.year, now.month - 1, now.day);
      if (previous.day != now.day) {
        // Day overflowed (e.g. 31 March → 28 February).
        return DateTime(now.year, now.month, 0, 12);
      }
      return DateTime(
        previous.year,
        previous.month,
        previous.day,
        now.hour,
        now.minute,
      );
    }
    return now;
  }
}
