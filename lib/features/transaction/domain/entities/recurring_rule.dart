import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:equatable/equatable.dart';

/// Frequency of a recurring transaction rule.
enum RecurringFrequency { daily, weekly, monthly }

/// Default date used when a rule has no explicit [RecurringRule.createdAt].
final DateTime _epoch = DateTime(1970, 1, 1);

/// Domain entity representing a recurring transaction template.
class RecurringRule extends Equatable {
  RecurringRule({
    required this.id,
    required this.amount,
    required this.type,
    required this.currency,
    required this.categoryId,
    required this.frequency,
    required this.startDate,
    required this.nextRunAt,
    this.merchant,
    this.note,
    this.dayOfMonth,
    this.dayOfWeek,
    this.endDate,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime(1970, 1, 1);

  /// Unique identifier (ULID / UUID v7).
  final String id;

  /// Amount per occurrence.
  final double amount;

  /// Expense or income.
  final TransactionType type;

  /// Foreign key to Category.id.
  final String categoryId;

  /// Frequency of the rule.
  final RecurringFrequency frequency;

  /// Day of month for monthly rules (1-31).
  final int? dayOfMonth;

  /// Weekday for weekly rules (DateTime.weekday, Monday=1).
  final int? dayOfWeek;

  /// First day the rule may fire.
  final DateTime startDate;

  /// Optional last day after which the rule stops.
  final DateTime? endDate;

  /// Next scheduled fire time (inclusive semantics at the service level).
  final DateTime nextRunAt;

  /// Active flag — inactive rules are not processed.
  final bool isActive;

  /// Creation timestamp (defaults to [_epoch] when not provided).
  final DateTime? createdAt;

  /// Optional merchant / store name.
  final String? merchant;

  /// Optional note / description.
  final String? note;

  /// Currency code (default 'VND').
  final String currency;

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        categoryId,
        frequency,
        dayOfMonth,
        dayOfWeek,
        startDate,
        endDate,
        nextRunAt,
        isActive,
        merchant,
        note,
        currency,
        createdAt,
      ];

  /// Effective creation timestamp.
  DateTime get effectiveCreatedAt => createdAt ?? _epoch;

  RecurringRule copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? currency,
    String? merchant,
    String? note,
    String? categoryId,
    RecurringFrequency? frequency,
    int? dayOfMonth,
    int? dayOfWeek,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextRunAt,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringRule(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Computes the next run strictly after [from] for this rule.
  ///
  /// Edge cases (hỗ trợ test):
  /// - daily: tiến 1 ngày từ run trước.
  /// - weekly: tiến tới thứ trong tuần ở [dayOfWeek].
  /// - monthly: tiến tới ngày [dayOfMonth] của tháng sau đó; tháng không
  ///   có ngày đó (ví dụ 31 trong tháng 2) → clamps về ngày cuối.
  static DateTime computeNextRunAt(RecurringRule rule, DateTime from) {
    var candidate = rule.nextRunAt.isAfter(from)
        ? rule.nextRunAt
        : _advance(rule, rule.nextRunAt);
    while (!candidate.isAfter(from)) {
      candidate = _advance(rule, candidate);
    }
    return candidate;
  }

  /// Advances the rule one period after [previous].
  static DateTime _advance(RecurringRule rule, DateTime previous) {
    switch (rule.frequency) {
      case RecurringFrequency.daily:
        return previous.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        final target = rule.dayOfWeek ?? DateTime.monday;
        var offset = (target - previous.weekday + 7) % 7;
        if (offset == 0) offset = 7; // strictly after previous
        return previous.add(Duration(days: offset));
      case RecurringFrequency.monthly:
        return _advanceMonthly(rule, previous);
    }
  }

  static DateTime _advanceMonthly(RecurringRule rule, DateTime previous) {
    final year = previous.year;
    var month = previous.month + 1;
    while (true) {
      final daysInMonth = DateTime(year, month + 1).subtract(
        const Duration(days: 1),
      ).day;
      final day = rule.dayOfMonth ?? 1;
      if (day > daysInMonth) {
        // Tháng này không có ngày đó → clamps về ngày cuối cùng của tháng
        // (edge case: dayOfMonth = 31 trong tháng 2).
        final clamped = DateTime(year, month, daysInMonth);
        if (clamped.isAfter(previous)) return clamped;
        month++;
        continue;
      }
      final candidate = DateTime(year, month, day);
      if (candidate.isAfter(previous)) return candidate;
      month++;
    }
  }
}
