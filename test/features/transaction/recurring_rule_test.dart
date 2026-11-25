import 'package:bill_tracker/features/transaction/domain/entities/recurring_rule.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurringRule.computeNextRunAt', () {
    RecurringRule rule({
      DateTime? nextRunAt,
      RecurringFrequency frequency = RecurringFrequency.monthly,
      int? dayOfMonth,
      int? dayOfWeek,
    }) {
      return RecurringRule(
        id: 'r1',
        amount: 100,
        type: TransactionType.expense,
        currency: 'VND',
        categoryId: 'other',
        frequency: frequency,
        dayOfMonth: dayOfMonth,
        dayOfWeek: dayOfWeek,
        startDate: DateTime(2025, 1, 1),
        nextRunAt: nextRunAt ?? DateTime(2025, 1, 1),
      );
    }

    test('daily: advances by one day and is always > from', () {
      final from = DateTime(2025, 1, 2, 10);
      final next = RecurringRule.computeNextRunAt(
        rule(frequency: RecurringFrequency.daily, nextRunAt: from),
        from,
      );
      expect(next, DateTime(2025, 1, 3, 10));
      expect(next.isAfter(from), isTrue);
    });

    test('weekly: advances to next weekday', () {
      // From Sunday Jan 5, rule due then → next Wednesday Jan 8.
      final from = DateTime(2025, 1, 5, 9);
      expect(from.weekday, 7);
      final next = RecurringRule.computeNextRunAt(
        rule(
          frequency: RecurringFrequency.weekly,
          dayOfWeek: 3,
          nextRunAt: from,
        ),
        from,
      );
      expect(next.weekday, 3);
      expect(next.isAfter(from), isTrue);
      expect(next, DateTime(2025, 1, 8, 9));
    });

    test('weekly: same weekday → advances one week', () {
      final from = DateTime(2025, 1, 6); // Monday
      final next = RecurringRule.computeNextRunAt(
        rule(
          frequency: RecurringFrequency.weekly,
          dayOfWeek: 1,
          nextRunAt: from,
        ),
        from,
      );
      expect(next, DateTime(2025, 1, 13));
    });

    test('weekly: nextRunAt in future is returned as-is', () {
      final from = DateTime(2025, 1, 5, 9);
      final next = RecurringRule.computeNextRunAt(
        rule(
          frequency: RecurringFrequency.weekly,
          dayOfWeek: 6,
          nextRunAt: DateTime(2025, 1, 12, 9),
        ),
        from,
      );
      expect(next, DateTime(2025, 1, 12, 9));
    });

    test('monthly: day 31 in January → February 28 (clamped)', () {
      final from = DateTime(2025, 1, 31);
      final next = RecurringRule.computeNextRunAt(
        rule(frequency: RecurringFrequency.monthly, dayOfMonth: 31, nextRunAt: from),
        from,
      );
      expect(next, DateTime(2025, 2, 28));
    });

    test('monthly: day 31 after February → March 31', () {
      final from = DateTime(2025, 2, 28);
      final next = RecurringRule.computeNextRunAt(
        rule(frequency: RecurringFrequency.monthly, dayOfMonth: 31, nextRunAt: from),
        from,
      );
      expect(next, DateTime(2025, 3, 31));
    });

    test('monthly: day 29 in February → March 29', () {
      final from = DateTime(2025, 2, 28);
      final next = RecurringRule.computeNextRunAt(
        rule(frequency: RecurringFrequency.monthly, dayOfMonth: 29, nextRunAt: from),
        from,
      );
      expect(next, DateTime(2025, 3, 29));
    });

    test('monthly: day 5 in April → May 5', () {
      final from = DateTime(2025, 4, 5);
      final next = RecurringRule.computeNextRunAt(
        rule(frequency: RecurringFrequency.monthly, dayOfMonth: 5, nextRunAt: from),
        from,
      );
      expect(next, DateTime(2025, 5, 5));
    });
  });
}
