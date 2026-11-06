import 'package:bill_tracker/core/utils/vietnamese_text_utils.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:equatable/equatable.dart';

/// The structured result of parsing a Vietnamese search query.
///
/// Everything is resolved locally for local transaction filtering only.
class ParsedTransactionQuery extends Equatable {
  /// Creates [ParsedTransactionQuery].
  const ParsedTransactionQuery({
    required this.isStructured,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.keyword = '',
  });

  /// Whether at least one structured constraint (time, amount) was parsed.
  ///
  /// When false, callers should fall back to plain merchant/note keyword
  /// search so nothing breaks.
  final bool isStructured;

  /// Inclusive start of the date range filter (if a time phrase matched).
  final DateTime? startDate;

  /// Inclusive end of the date range filter (if a time phrase matched).
  final DateTime? endDate;

  /// Minimum amount, e.g. "trên 200 nghìn" (exclusive semantics may vary).
  final double? minAmount;

  /// Maximum amount, e.g. "dưới 1 triệu".
  final double? maxAmount;

  /// Remaining free text after removing time/amount phrases. Used to match
  /// merchant, note and category names.
  final String keyword;

  @override
  List<Object?> get props =>
      [isStructured, startDate, endDate, minAmount, maxAmount, keyword];
}

/// _TimeRange describes a concrete start/end computed from a reference time.
class _TimeRange {
  const _TimeRange(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

/// Parses natural Vietnamese money-search phrases into local filters.
///
/// Supported (all processed on-device):
/// - time: "hôm nay", "hôm qua", "tuần này/trước", "tháng này/trước",
///   "năm nay/ngoái", "N ngày qua"
/// - amount: "trên/hơn 200 nghìn", "dưới 1 triệu", "từ 500k",
///   "khoảng 300k" (numbers accept "nghìn/ngan/k", "triệu/tr", thousand
///   separators like "200.000" and decimals like "1.5 triệu")
/// - keyword: leftover tokens searched against merchant/note/category.
///
/// Anything unrecognizable degrades to keyword search on the remaining
/// text (see the keyword field of the parsed result).
class VietnameseTransactionQueryParser {
  const VietnameseTransactionQueryParser._();

  static final RegExp _timeRegex = RegExp(
    r'(\d+\s+ngay\s+qua|hom\s+nay|hom\s+qua|tuan\s+nay|tuan\s+truoc|'
    r'thang\s+nay|thang\s+truoc|nam\s+nay|nam\s+ngoai)',
  );

  static final RegExp _amountRegex = RegExp(
    // Multi-word comparators must precede single-word ones, otherwise
    // "ít hơn" would match bare "hơn" and flip the comparison direction.
    r'(tren|toi thieu|it hon|nho hon|toi da|duoi|hon|tu|khoang)\s*'
    r'(\d+(?:[.,]\d+)*)\s*'
    '(nghin|ngan|k|trieu|tr)?',
  );

  static final RegExp _unitRegex = RegExp(r'\s*(nghin|ngan|k|trieu|tr)\b');

  /// Parses [query] against [now] (defaults to the current time).
  static ParsedTransactionQuery parse(String query, {DateTime? now}) {
    final normalized = VietnameseTextUtils.normalize(query);

    final timeRange = _parseTime(normalized, now ?? DateTime.now());
    final amounts = _parseAmounts(normalized);

    final hasTime = timeRange != null;
    final hasAmount = amounts.minAmount != null || amounts.maxAmount != null;

    var keyword = query;
    if (hasTime || hasAmount) {
      final ranges = <int, int>{
        if (hasTime)
          for (final m in _timeRegex.allMatches(normalized)) m.start: m.end,
        if (hasAmount)
          for (final m in _amountRegex.allMatches(normalized)) m.start: m.end,
      };
      // Normalized text keeps 1:1 character offsets with the original, so
      // removing all ranges in a single descending pass is safe.
      final sortedRanges = ranges.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));
      for (final range in sortedRanges) {
        keyword = keyword.replaceRange(range.key, range.value, ' ');
      }
    }
    // Keep the original (accented) text so LIKE search can still match the
    // stored merchant/note exactly.
    keyword = VietnameseTextUtils.squashWhitespace(keyword);

    return ParsedTransactionQuery(
      isStructured: hasTime || hasAmount,
      startDate: timeRange?.start,
      endDate: timeRange?.end,
      minAmount: amounts.minAmount,
      maxAmount: amounts.maxAmount,
      keyword: keyword,
    );
  }

  /// Resolves [keyword] to a category by comparing normalized names.
  ///
  /// Returns null when nothing reasonably matches; the keyword is then
  /// simply searched as free text.
  static String? resolveCategoryId(
    String keyword,
    List<Category> categories,
  ) {
    final key = VietnameseTextUtils.normalize(keyword);
    if (key.isEmpty) return null;

    for (final category in categories) {
      final name = VietnameseTextUtils.normalize(category.name);
      if (name == key || name.contains(key) || key.contains(name)) {
        return category.id;
      }
    }
    return null;
  }

  // ── Time expressions ────────────────────────────────────────────────

  static _TimeRange? _parseTime(String normalized, DateTime now) {
    final match = _timeRegex.firstMatch(normalized);
    if (match == null) return null;
    final phrase = match.group(0) ?? '';

    final today = DateTime(now.year, now.month, now.day);
    const fullDay = Duration(days: 1, milliseconds: -1);

    if (phrase.contains('hom nay')) {
      return _TimeRange(today, today.add(fullDay));
    }
    if (phrase.contains('hom qua')) {
      final yesterday = today.subtract(const Duration(days: 1));
      return _TimeRange(yesterday, yesterday.add(fullDay));
    }
    if (phrase.contains('tuan nay')) {
      final monday = _mondayOf(today);
      return _TimeRange(
        monday,
        monday
            .add(const Duration(days: 7))
            .subtract(const Duration(milliseconds: 1)),
      );
    }
    if (phrase.contains('tuan truoc')) {
      final thisMonday = _mondayOf(today);
      final lastMonday = thisMonday.subtract(const Duration(days: 7));
      return _TimeRange(
        lastMonday,
        thisMonday.subtract(const Duration(milliseconds: 1)),
      );
    }
    if (phrase.contains('thang truoc')) {
      final firstOfThisMonth = DateTime(now.year, now.month);
      final firstOfLastMonth = DateTime(now.year, now.month - 1);
      return _TimeRange(
        firstOfLastMonth,
        firstOfThisMonth.subtract(const Duration(milliseconds: 1)),
      );
    }
    if (phrase.contains('thang nay')) {
      final firstOfThisMonth = DateTime(now.year, now.month);
      final firstOfNextMonth = DateTime(now.year, now.month + 1);
      return _TimeRange(
        firstOfThisMonth,
        firstOfNextMonth.subtract(const Duration(milliseconds: 1)),
      );
    }
    if (phrase.contains('nam ngoai')) {
      final firstOfLastYear = DateTime(now.year - 1, 1);
      return _TimeRange(
        firstOfLastYear,
        DateTime(now.year, 1).subtract(const Duration(milliseconds: 1)),
      );
    }
    if (phrase.contains('nam nay')) {
      final firstOfThisYear = DateTime(now.year, 1);
      return _TimeRange(
        firstOfThisYear,
        DateTime(now.year + 1, 1).subtract(const Duration(milliseconds: 1)),
      );
    }

    // "N ngày qua" — includes today.
    final daysMatch = RegExp(r'(\d+)\s*ngay\s+qua').firstMatch(phrase);
    final days = int.tryParse(daysMatch?.group(1) ?? '') ?? 0;
    if (days > 0) {
      final start = today.subtract(Duration(days: days - 1));
      return _TimeRange(start, today.add(fullDay));
    }
    return null;
  }

  static DateTime _mondayOf(DateTime date) {
    // Dart: Monday = 1 ... Sunday = 7.
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  // ── Amount expressions ──────────────────────────────────────────────

  static ({double? minAmount, double? maxAmount}) _parseAmounts(
    String normalized,
  ) {
    double? minAmount;
    double? maxAmount;

    for (final match in _amountRegex.allMatches(normalized)) {
      final comparator = match.group(1) ?? '';
      final phrase = match.group(0) ?? '';
      final value = _parseAmountPhrase(phrase);
      if (value == null) continue;

      if (_isMaxComparator(comparator)) {
        maxAmount = value;
      } else if (comparator.trim() == 'khoang') {
        // "khoảng 300k" → a soft range: 270k .. 330k.
        minAmount = value * 0.9;
        maxAmount = value * 1.1;
      } else {
        minAmount = value;
      }
    }

    return (minAmount: minAmount, maxAmount: maxAmount);
  }

  static bool _isMaxComparator(String comparator) {
    final c = VietnameseTextUtils.stripDiacritics(comparator.trim());
    return c == 'duoi' || c == 'it hon' || c == 'nho hon' || c == 'toi da';
  }

  /// Parses a phrase like "200 nghìn", "1.5 triệu", "200.000", "300k".
  static double? _parseAmountPhrase(String phrase) {
    final numberMatch = RegExp(r'(\d+(?:[.,]\d+)*)').firstMatch(phrase);
    if (numberMatch == null) return null;
    final numberText = numberMatch.group(1) ?? '';

    final digitsOnly = numberText.replaceAll(RegExp('[.,]'), '');
    if (digitsOnly.isEmpty) return null;

    final unitMatch = _unitRegex.firstMatch(phrase);
    final unit = unitMatch?.group(1);

    double base;
    final hasSeparatorWithGroups = numberText.contains(RegExp(r'[.,]\d{3}'));
    final hasDecimalTail = numberText.contains(RegExp(r'[.,]\d{1,2}$'));

    if (hasDecimalTail && !hasSeparatorWithGroups) {
      // "1.5 triệu" / "1,5 k" → decimal number.
      final normalizedDecimal = numberText.replaceAll(',', '.');
      base = double.tryParse(normalizedDecimal) ??
          double.tryParse(digitsOnly) ??
          0;
    } else {
      // "200.000" → thousand separators, plain dong value.
      base = double.tryParse(digitsOnly) ?? 0;
    }

    double multiplier = 1;
    if (unit == 'nghin' || unit == 'ngan' || unit == 'k') {
      multiplier = 1000;
    } else if (unit == 'trieu' || unit == 'tr') {
      multiplier = 1000000;
    } else if (unit == null && !hasSeparatorWithGroups && !hasDecimalTail) {
      // Bare number "200" without unit → treat as dong directly.
      multiplier = 1;
    }

    return base * multiplier;
  }

  // ── Keyword extraction ──────────────────────────────────────────────
}
