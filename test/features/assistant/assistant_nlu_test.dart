import 'package:bill_tracker/features/assistant/domain/services/assistant_nlu.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  final now = DateTime(2026, 11, 24, 9, 30);
  const nlu = AssistantNlu(categories: testCategories);

  group('AssistantNlu intent detection', () {
    AssistantIntent intentOf(String input) => nlu.parse(input, now: now).intent;

    test('detects total spending questions', () {
      expect(
        intentOf('Tháng này tôi tiêu bao nhiêu?'),
        AssistantIntent.totalSpend,
      );
      expect(intentOf('tổng chi tiêu tuần này'), AssistantIntent.totalSpend);
    });

    test('detects top expenses and parses the requested size', () {
      final query = nlu.parse('top 3 khoản chi lớn nhất tháng trước', now: now);
      expect(query.intent, AssistantIntent.topExpenses);
      expect(query.limit, 3);
      expect(query.timeframe.label, 'Tháng trước');
    });

    test('detects category breakdown', () {
      expect(
        intentOf('chi tiêu theo danh mục'),
        AssistantIntent.categoryBreakdown,
      );
      expect(
        intentOf('tháng này các danh mục nào nhiều nhất'),
        AssistantIntent.categoryBreakdown,
      );
    });

    test('detects budget questions', () {
      expect(
        intentOf('ngân sách còn lại bao nhiêu'),
        AssistantIntent.budgetStatus,
      );
    });

    test('detects month comparison', () {
      expect(
        intentOf('so với tháng trước thế nào'),
        AssistantIntent.compareMonths,
      );
    });

    test('detects transaction count questions', () {
      expect(
        intentOf('tháng này có bao nhiêu giao dịch'),
        AssistantIntent.countTransactions,
      );
    });

    test('detects income questions', () {
      expect(
        intentOf('tháng này thu nhập bao nhiêu'),
        AssistantIntent.incomeReport,
      );
    });

    test('detects greeting, help and support', () {
      expect(intentOf('xin chào'), AssistantIntent.greeting);
      expect(intentOf('bạn làm được gì'), AssistantIntent.help);
      expect(intentOf('báo lỗi giúp mình'), AssistantIntent.support);
    });

    test('treats an amount without a question as a new transaction', () {
      final query = nlu.parse('cà phê 45k hôm nay', now: now);
      expect(query.intent, AssistantIntent.createTransaction);
      expect(query.amount, 45000);
      expect(query.timeframe.label, 'Hôm nay');
    });

    test('falls back to unknown for unrelated text', () {
      expect(intentOf('thời tiết hôm nay thế nào'), AssistantIntent.unknown);
      expect(intentOf('kể chuyện cười'), AssistantIntent.unknown);
    });
  });

  group('AssistantNlu parsing details', () {
    test('resolves a mentioned category', () {
      final query = nlu.parse('ăn uống tháng này bao nhiêu', now: now);
      expect(query.category?.id, 'food_drinks');
    });

    test('resolves rolling windows', () {
      final query = nlu.parse('chi tiêu 3 tháng gần đây', now: now);
      expect(query.timeframe.start, DateTime(2026, 9));
      expect(query.timeframe.endExclusive, DateTime(2026, 12));
    });

    test('resolves explicit month to the most recent occurrence', () {
      final query = nlu.parse('chi tiêu tháng 10', now: now);
      expect(query.timeframe.start, DateTime(2026, 10));
      expect(query.timeframe.endExclusive, DateTime(2026, 11));
    });

    test('defaults to the current month', () {
      final query = nlu.parse('cà phê 45k', now: now);
      expect(query.timeframe.start, DateTime(2026, 11));
      expect(query.timeframe.endExclusive, DateTime(2026, 12));
    });

    test('does not read a month number as money', () {
      final query = nlu.parse('tháng 10 tôi tiêu bao nhiêu', now: now);
      expect(query.amount, isNull);
    });
  });

  group('AssistantNlu keyword category hints', () {
    test('maps drink keywords to food', () {
      expect(
        AssistantNlu.categoryIdForKeyword('ca phe sua da'),
        'food_drinks',
      );
    });

    test('maps transport keywords', () {
      expect(AssistantNlu.categoryIdForKeyword('do xang xe may'), 'transport');
    });

    test('respects word boundaries', () {
      expect(AssistantNlu.categoryIdForKeyword('nhan luong'), isNull);
    });
  });
}
