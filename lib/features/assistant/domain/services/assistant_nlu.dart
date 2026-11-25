import 'package:bill_tracker/core/utils/vietnamese_text_utils.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/services/vietnamese_transaction_query_parser.dart';
import 'package:equatable/equatable.dart';

/// A resolved date window used by assistant answers.
///
/// The window is half-open: [start] is inclusive, [endExclusive] is exclusive.
class AssistantTimeFrame extends Equatable {
  /// Creates an [AssistantTimeFrame].
  const AssistantTimeFrame({
    required this.label,
    required this.start,
    required this.endExclusive,
  });

  /// Human label such as "Tháng này" or "3 tháng gần đây".
  final String label;

  /// Inclusive start.
  final DateTime start;

  /// Exclusive end.
  final DateTime endExclusive;

  /// Inclusive last instant, matching the `TransactionFilter.endDate` semantics.
  DateTime get endInclusive =>
      endExclusive.subtract(const Duration(milliseconds: 1));

  /// Whether this window covers exactly one calendar month.
  bool get isSingleMonth =>
      start.day == 1 &&
      start.hour == 0 &&
      start.minute == 0 &&
      start.microsecond == 0 &&
      endExclusive.day == 1 &&
      endExclusive.hour == 0;

  @override
  List<Object?> get props => [label, start, endExclusive];
}

/// What the user is asking for.
enum AssistantIntent {
  /// "xin chào"
  greeting,

  /// "bạn làm được gì"
  help,

  /// Total spending over a period.
  totalSpend,

  /// Income over a period.
  incomeReport,

  /// Largest transactions.
  topExpenses,

  /// Spending split per category.
  categoryBreakdown,

  /// How many transactions in a period.
  countTransactions,

  /// Month-over-month comparison.
  compareMonths,

  /// Remaining budget per category.
  budgetStatus,

  /// Latest transactions.
  recentTransactions,

  /// Turn a phrase like "cà phê 45k" into a draft.
  createTransaction,

  /// Support / feedback about the app itself.
  support,

  /// Nothing matched confidently.
  unknown,
}

/// Structured understanding of a single chat message.
class AssistantQuery extends Equatable {
  /// Creates an [AssistantQuery].
  const AssistantQuery({
    required this.raw,
    required this.normalized,
    required this.intent,
    required this.timeframe,
    this.category,
    this.amount,
    this.limit = 5,
  });

  /// Original user text.
  final String raw;

  /// Diacritic-free lowercase text used for matching.
  final String normalized;

  /// Detected intent.
  final AssistantIntent intent;

  /// Resolved period (defaults to the current month).
  final AssistantTimeFrame timeframe;

  /// Category mentioned in the message, if any.
  final Category? category;

  /// Money amount mentioned in the message, if any.
  final double? amount;

  /// Requested list size for "top N" questions.
  final int limit;

  @override
  List<Object?> get props =>
      [raw, normalized, intent, timeframe, category, amount, limit];
}

/// On-device natural-language understanding for Vietnamese spending questions.
///
/// Fully deterministic and synchronous: no network, no API key. The cloud LLM
/// (when enabled) only handles messages this parser cannot classify.
class AssistantNlu {
  /// Creates an [AssistantNlu] bound to the user's current categories.
  const AssistantNlu({required this.categories});

  /// Categories available for matching (used to resolve "ăn uống", "xăng"...).
  final List<Category> categories;

  static final RegExp _numberPattern = RegExp(r'\d+');

  /// Parses [input] into an [AssistantQuery].
  AssistantQuery parse(String input, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final normalized = VietnameseTextUtils.normalize(input);
    final timeframe = resolveTimeFrame(normalized, reference);
    final amount = VietnameseTransactionQueryParser.extractAmount(
      stripTimePhrases(normalized),
    );
    final category = resolveCategory(normalized);
    final limit = _resolveLimit(normalized);
    final intent = _resolveIntent(
      normalized: normalized,
      amount: amount,
      reference: reference,
    );

    // "so với tháng trước" means "this month vs last month", not
    // "last month vs the month before".
    final resolvedFrame = intent == AssistantIntent.compareMonths &&
            RegExp('(thang|tuan) truoc|hom qua').hasMatch(normalized) &&
            !RegExp(r'thang\s*\d').hasMatch(normalized)
        ? resolveTimeFrame('thang nay', reference)
        : timeframe;

    return AssistantQuery(
      raw: input,
      normalized: normalized,
      intent: intent,
      timeframe: resolvedFrame,
      category: category,
      amount: amount,
      limit: limit,
    );
  }

  // ── Intent detection ────────────────────────────────────────────────

  AssistantIntent _resolveIntent({
    required String normalized,
    required double? amount,
    required DateTime reference,
  }) {
    bool has(List<String> keywords) =>
        keywords.any((keyword) => normalized.contains(keyword));

    // Support / feedback always wins: it is an explicit meta request.
    if (has([
      'ho tro',
      'lien he',
      'phan hoi',
      'gop y',
      'bao loi',
      'bao bug',
      'khieu nai',
      'lien lac',
      'hotro',
      'support',
      'feedback',
    ])) {
      return AssistantIntent.support;
    }

    if (has([
      'ban la ai',
      'lam duoc gi',
      'lam gi duoc',
      'huong dan',
      'giup',
      'giup do',
      'tro giup',
      'help',
      'cach dung',
      'vi du',
    ])) {
      return AssistantIntent.help;
    }

    if (has(['ngan sach', 'han muc', 'vuot muc', 'con lai bao nhieu'])) {
      return AssistantIntent.budgetStatus;
    }

    if (has([
      'so sanh',
      'so voi',
      'chenh lech',
      'tang hay giam',
      'giam hay tang',
      'nhieu hon thang truoc',
      'it hon thang truoc',
    ])) {
      return AssistantIntent.compareMonths;
    }

    if (has([
      'theo danh muc',
      'danh muc nao',
      'phan bo',
      'chia theo',
      'cac danh muc',
      'ty trong',
      'ti trong',
      'co cau',
    ])) {
      return AssistantIntent.categoryBreakdown;
    }

    if (has([
      'top ',
      'lon nhat',
      'cao nhat',
      'dat nhat',
      'nhieu nhat',
      'chi lon',
      'khoan chi lon',
    ])) {
      return AssistantIntent.topExpenses;
    }

    if (has([
      'bao nhieu giao dich',
      'may giao dich',
      'so giao dich',
      'bao nhieu lan',
      'dem giao dich',
      'so lan',
    ])) {
      return AssistantIntent.countTransactions;
    }

    if (_isIncomeQuestion(normalized)) {
      return AssistantIntent.incomeReport;
    }

    if (_isTotalSpendQuestion(normalized)) {
      return AssistantIntent.totalSpend;
    }

    if (has([
      'gan day',
      'moi nhat',
      'liet ke',
      'xem giao dich',
      'nhung giao dich',
      'lich su',
      'vua chi',
      'vua mua',
    ])) {
      return AssistantIntent.recentTransactions;
    }

    // A money amount without question wording means "record this".
    if (amount != null && !_isQuestion(normalized)) {
      return AssistantIntent.createTransaction;
    }

    if (has(['xin chao', 'chao ban', 'chao ', 'hello', 'hi ban', 'alo'])) {
      return AssistantIntent.greeting;
    }

    if (amount != null) return AssistantIntent.createTransaction;

    // "cà phê", "grab" → the user probably wants to record something but
    // forgot the amount; ask for it instead of giving a generic reply.
    if (!_isQuestion(normalized) && categoryIdForKeyword(normalized) != null) {
      return AssistantIntent.createTransaction;
    }

    return AssistantIntent.unknown;
  }

  bool _isIncomeQuestion(String normalized) {
    final mentionsIncome = normalized.contains('thu nhap') ||
        normalized.contains('nhan duoc') ||
        normalized.contains('kiem duoc') ||
        normalized.contains('tien luong') ||
        normalized.startsWith('luong') ||
        normalized.contains(' thu ');
    return mentionsIncome;
  }

  bool _isTotalSpendQuestion(String normalized) {
    const asks = [
      'bao nhieu',
      'tong',
      'het bao nhieu',
      'chi tieu',
      'tieu',
      'chi ',
      'tieu het',
      'chi het',
      'da chi',
      'da tieu',
      'tong chi',
      'trung binh',
    ];
    return asks.any(normalized.contains);
  }

  bool _isQuestion(String normalized) {
    const questionTokens = [
      'bao nhieu',
      'tong',
      'top',
      'liet ke',
      'danh muc',
      'ngan sach',
      'so sanh',
      '?',
    ];
    return questionTokens.any(normalized.contains);
  }

  int _resolveLimit(String normalized) {
    final topMatch = RegExp(
      r'(?:top|(\d+)\s*(?:khoan|giao dich|mon|lan))',
    ).firstMatch(normalized);
    final rawNumber =
        topMatch?.group(1) ?? _numberPattern.firstMatch(normalized)?.group(0);
    final parsed = int.tryParse(rawNumber ?? '');
    if (parsed == null || parsed <= 0) return 5;
    return parsed.clamp(1, 20);
  }

  // ── Category resolution ─────────────────────────────────────────────

  /// Finds the category whose name appears in [normalized], if any.
  Category? resolveCategory(String normalized) {
    Category? best;
    var bestLength = 0;
    for (final category in categories) {
      final name = VietnameseTextUtils.normalize(category.name);
      if (name.isEmpty) continue;
      if (normalized.contains(name) && name.length > bestLength) {
        best = category;
        bestLength = name.length;
      }
    }
    return best;
  }

  /// Resolves extra keywords that imply a category ("xăng" → Di chuyển).
  static String? categoryIdForKeyword(String normalized) {
    const hints = <String, List<String>>{
      'food_drinks': [
        'an',
        'uong',
        'ca phe',
        'coffee',
        'tra sua',
        'tra ',
        'com',
        'pho',
        'bun',
        'banh',
        'nha hang',
        'quan an',
        'do an',
        'snack',
        'beer',
        'bia',
        'cf',
      ],
      'transport': [
        'xang',
        'grab',
        'taxi',
        'be ',
        'xe buyt',
        'gui xe',
        'do xe',
        've xe',
        've may bay',
        'tau',
        'ship hang',
        'phi ship',
      ],
      'shopping': [
        'mua',
        'shop',
        'sieu thi',
        'quan ao',
        'ao ',
        'giay',
        'dep',
        'tui',
        'my pham',
        'shopee',
        'lazada',
        'tiki',
      ],
      'entertainment': [
        'phim',
        'cinema',
        'game',
        'karaoke',
        'nhac',
        'concert',
        'gym',
        'travel',
        'du lich',
      ],
      'health': [
        'thuoc',
        'kham',
        'benh vien',
        'phong kham',
        'nha thuoc',
        'y te',
        'nha khoa',
        'bac si',
      ],
      'education': [
        'sach',
        'hoc phi',
        'khoa hoc',
        'truong',
        'giao trinh',
        'hoc ',
      ],
      'bills': [
        'tien dien',
        'tien nuoc',
        'internet',
        'wifi',
        'dien thoai',
        'hoa don',
        'cuoc ',
        'tien nha',
        'phi quan ly',
      ],
      'work': ['cong viec', 'van phong', 'in an', 'thiet bi'],
    };

    for (final entry in hints.entries) {
      for (final keyword in entry.value) {
        final trimmed = keyword.trim();
        if (trimmed.isEmpty) continue;
        // Require word boundaries so "an" does not match "ban".
        final pattern = RegExp('[^a-z0-9]${RegExp.escape(trimmed)}[^a-z0-9]');
        if (pattern.hasMatch(' $normalized ')) return entry.key;
      }
    }
    return null;
  }

  // ── Time frame resolution ───────────────────────────────────────────

  /// Resolves a Vietnamese time phrase into a concrete window.
  static AssistantTimeFrame resolveTimeFrame(String normalized, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    const oneDay = Duration(days: 1);

    if (normalized.contains('hom kia')) {
      final day = today.subtract(const Duration(days: 2));
      return AssistantTimeFrame(
        label: 'Hôm kia',
        start: day,
        endExclusive: day.add(oneDay),
      );
    }
    if (normalized.contains('hom qua')) {
      final day = today.subtract(oneDay);
      return AssistantTimeFrame(
        label: 'Hôm qua',
        start: day,
        endExclusive: day.add(oneDay),
      );
    }
    if (normalized.contains('hom nay')) {
      return AssistantTimeFrame(
        label: 'Hôm nay',
        start: today,
        endExclusive: today.add(oneDay),
      );
    }
    if (normalized.contains('tuan truoc')) {
      final monday = _mondayOf(today).subtract(const Duration(days: 7));
      return AssistantTimeFrame(
        label: 'Tuần trước',
        start: monday,
        endExclusive: monday.add(const Duration(days: 7)),
      );
    }
    if (normalized.contains('tuan nay')) {
      final monday = _mondayOf(today);
      return AssistantTimeFrame(
        label: 'Tuần này',
        start: monday,
        endExclusive: monday.add(const Duration(days: 7)),
      );
    }

    final rolling = RegExp(
      r'(\d+)\s*(ngay|tuan|thang)\s*(?:qua|gan day|truoc|tro lai)',
    ).firstMatch(normalized);
    if (rolling != null) {
      final count = int.tryParse(rolling.group(1) ?? '') ?? 0;
      final unit = rolling.group(2) ?? '';
      if (count > 0) {
        if (unit == 'ngay') {
          return AssistantTimeFrame(
            label: '$count ngày gần đây',
            start: today.subtract(Duration(days: count - 1)),
            endExclusive: today.add(oneDay),
          );
        }
        if (unit == 'tuan') {
          return AssistantTimeFrame(
            label: '$count tuần gần đây',
            start: today.subtract(Duration(days: count * 7 - 1)),
            endExclusive: today.add(oneDay),
          );
        }
        final firstOfThisMonth = DateTime(now.year, now.month);
        return AssistantTimeFrame(
          label: '$count tháng gần đây',
          start: DateTime(now.year, now.month - (count - 1)),
          endExclusive:
              DateTime(firstOfThisMonth.year, firstOfThisMonth.month + 1),
        );
      }
    }

    if (normalized.contains('thang truoc')) {
      return AssistantTimeFrame(
        label: 'Tháng trước',
        start: DateTime(now.year, now.month - 1),
        endExclusive: DateTime(now.year, now.month),
      );
    }
    if (normalized.contains('thang nay') ||
        normalized.contains('thang hien tai')) {
      return AssistantTimeFrame(
        label: 'Tháng này',
        start: DateTime(now.year, now.month),
        endExclusive: DateTime(now.year, now.month + 1),
      );
    }

    final explicitMonth = RegExp(r'thang\s*(\d{1,2})').firstMatch(normalized);
    if (explicitMonth != null) {
      final month = int.tryParse(explicitMonth.group(1) ?? '') ?? 0;
      if (month >= 1 && month <= 12) {
        // Pick the most recent occurrence of that month.
        final year = month <= now.month ? now.year : now.year - 1;
        return AssistantTimeFrame(
          label: 'Tháng $month/${year == now.year ? 'nay' : year}',
          start: DateTime(year, month),
          endExclusive: DateTime(year, month + 1),
        );
      }
    }

    if (normalized.contains('nam ngoai')) {
      return AssistantTimeFrame(
        label: 'Năm ngoái',
        start: DateTime(now.year - 1),
        endExclusive: DateTime(now.year),
      );
    }
    if (normalized.contains('nam nay')) {
      return AssistantTimeFrame(
        label: 'Năm nay',
        start: DateTime(now.year),
        endExclusive: DateTime(now.year + 1),
      );
    }

    final explicitYear = RegExp(r'nam\s*(20\d{2})').firstMatch(normalized);
    if (explicitYear != null) {
      final year = int.tryParse(explicitYear.group(1) ?? '') ?? now.year;
      return AssistantTimeFrame(
        label: 'Năm $year',
        start: DateTime(year),
        endExclusive: DateTime(year + 1),
      );
    }

    // Default: current calendar month.
    return AssistantTimeFrame(
      label: 'Tháng này',
      start: DateTime(now.year, now.month),
      endExclusive: DateTime(now.year, now.month + 1),
    );
  }

  /// Removes time phrases so "tháng 3" is not read as an amount.
  static String stripTimePhrases(String normalized) {
    var result = normalized;
    const phrases = [
      'hom kia',
      'hom qua',
      'hom nay',
      'tuan truoc',
      'tuan nay',
      'thang truoc',
      'thang nay',
      'thang hien tai',
      'nam ngoai',
      'nam nay',
      'gan day',
      'moi nhat',
      'luc ',
    ];
    for (final phrase in phrases) {
      result = result.replaceAll(phrase, ' ');
    }
    result = result.replaceAll(
      RegExp(r'thang\s*\d{1,2}'),
      ' ',
    );
    result = result.replaceAll(
      RegExp(r'nam\s*20\d{2}'),
      ' ',
    );
    result = result.replaceAll(
      RegExp(r'\d+\s*(ngay|tuan|thang)\s*(qua|gan day|truoc|tro lai)'),
      ' ',
    );
    return VietnameseTextUtils.squashWhitespace(result);
  }

  static DateTime _mondayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));
}
