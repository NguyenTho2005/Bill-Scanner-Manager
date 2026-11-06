import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/services/vietnamese_transaction_query_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Fixed "now": Tuesday 3 Nov 2026 → this week starts Mon 2 Nov 2026.
  final now = DateTime(2026, 11, 3, 14, 30);

  const food = Category(
    id: 'food_drinks',
    name: 'Ăn uống',
    icon: 'restaurant',
    colorValue: 0xFFFF6B35,
  );
  const shopping = Category(
    id: 'shopping',
    name: 'Mua sắm',
    icon: 'shopping_bag',
    colorValue: 0xFF2196F3,
  );

  ParsedTransactionQuery parse(String query) =>
      VietnameseTransactionQueryParser.parse(query, now: now);

  group('VietnameseTransactionQueryParser — time phrases', () {
    test('"tháng này" → current month range', () {
      final result = parse('ăn uống tháng này');

      expect(result.isStructured, isTrue);
      expect(result.startDate, DateTime(2026, 11));
      expect(
        result.endDate,
        DateTime(2026, 12).subtract(const Duration(milliseconds: 1)),
      );
      expect(result.keyword, 'ăn uống');
      expect(result.minAmount, isNull);
      expect(result.maxAmount, isNull);
    });

    test('"tháng trước" → previous month range', () {
      final result = parse('WinMart tháng trước');

      expect(result.isStructured, isTrue);
      expect(result.startDate, DateTime(2026, 10));
      expect(
        result.endDate,
        DateTime(2026, 11).subtract(const Duration(milliseconds: 1)),
      );
      expect(result.keyword, 'WinMart');
    });

    test('"tuần này" → this Monday..Sunday', () {
      final result = parse('cà phê tuần này');

      expect(result.startDate, DateTime(2026, 11, 2));
      expect(
        result.endDate,
        DateTime(2026, 11, 9).subtract(const Duration(milliseconds: 1)),
      );
    });

    test('"tuần trước" → last Monday..Sunday', () {
      final result = parse('đi bus tuần trước');

      expect(result.startDate, DateTime(2026, 10, 26));
      expect(
        result.endDate,
        DateTime(2026, 11, 2).subtract(const Duration(milliseconds: 1)),
      );
    });

    test('"hôm nay" and "hôm qua" ranges', () {
      final today = parse('ăn uống hôm nay');
      expect(today.startDate, DateTime(2026, 11, 3));
      expect(today.endDate, DateTime(2026, 11, 3, 23, 59, 59, 999));

      final yesterday = parse('ăn uống hôm qua');
      expect(yesterday.startDate, DateTime(2026, 11, 2));
      expect(yesterday.endDate, DateTime(2026, 11, 2, 23, 59, 59, 999));
    });

    test('"năm nay" and "năm ngoái" ranges', () {
      final thisYear = parse('du lịch năm nay');
      expect(thisYear.startDate, DateTime(2026, 1, 1));
      expect(
        thisYear.endDate,
        DateTime(2027, 1, 1).subtract(const Duration(milliseconds: 1)),
      );

      final lastYear = parse('du lịch năm ngoái');
      expect(lastYear.startDate, DateTime(2025, 1, 1));
      expect(
        lastYear.endDate,
        DateTime(2026, 1, 1).subtract(const Duration(milliseconds: 1)),
      );
    });

    test('"7 ngày qua" → rolling window including today', () {
      final result = parse('7 ngày qua');

      expect(result.isStructured, isTrue);
      expect(result.startDate, DateTime(2026, 10, 28));
      expect(result.endDate, DateTime(2026, 11, 3, 23, 59, 59, 999));
    });
  });

  group('VietnameseTransactionQueryParser — amount phrases', () {
    test('"trên 200 nghìn" → min 200000', () {
      final result = parse('trên 200 nghìn');

      expect(result.isStructured, isTrue);
      expect(result.minAmount, 200000);
      expect(result.maxAmount, isNull);
    });

    test('"dưới 1 triệu" → max 1000000', () {
      final result = parse('dưới 1 triệu');

      expect(result.maxAmount, 1000000);
      expect(result.minAmount, isNull);
    });

    test('"từ 500k" → min 500000', () {
      final result = parse('từ 500k');

      expect(result.minAmount, 500000);
    });

    test('"ít hơn 300 nghìn" is a max, not a min', () {
      final result = parse('ít hơn 300 nghìn');

      expect(result.maxAmount, 300000);
      expect(result.minAmount, isNull);
    });

    test('both bounds in one query', () {
      final result = parse('ăn uống từ 20 k dưới 200 nghìn');

      expect(result.minAmount, 20000);
      expect(result.maxAmount, 200000);
      expect(result.keyword, 'ăn uống');
    });

    test('thousand-separated number is already VND', () {
      final result = parse('WinMart trên 200.000 tháng này');

      expect(result.minAmount, 200000);
      expect(result.keyword, 'WinMart');
    });

    test('decimal with trieu unit', () {
      final result = parse('dưới 1.5 triệu');

      expect(result.maxAmount, 1500000);
    });
  });

  group('VietnameseTransactionQueryParser — combined and fallback', () {
    test('merchant + time + amount in one query', () {
      final result = parse('WinMart tháng trước trên 200 nghìn');

      expect(result.isStructured, isTrue);
      expect(result.startDate, DateTime(2026, 10));
      expect(result.minAmount, 200000);
      expect(result.keyword, 'WinMart');
    });

    test('unstructured query falls back to keyword search', () {
      const query = 'quán nước suối';
      final result = parse(query);

      expect(result.isStructured, isFalse);
      expect(result.startDate, isNull);
      expect(result.endDate, isNull);
      expect(result.minAmount, isNull);
      expect(result.maxAmount, isNull);
      expect(result.keyword, query);
    });

    test('removes diacritics when users type without them', () {
      final result = parse('an uong thang nay');

      expect(result.isStructured, isTrue);
      expect(result.startDate, DateTime(2026, 11));
      expect(result.keyword, 'an uong');
    });

    test('"khoảng 300k" becomes a soft range', () {
      final result = parse('khoảng 300k');

      expect(result.isStructured, isTrue);
      expect(result.minAmount, closeTo(270000, 1));
      expect(result.maxAmount, closeTo(330000, 1));
    });
  });

  group('VietnameseTransactionQueryParser.resolveCategoryId', () {
    test('matches category name with diacritics variations', () {
      final categories = [food, shopping];

      expect(
        VietnameseTransactionQueryParser.resolveCategoryId(
          'ăn uống',
          categories,
        ),
        'food_drinks',
      );
      expect(
        VietnameseTransactionQueryParser.resolveCategoryId(
          'an uong',
          categories,
        ),
        'food_drinks',
      );
      expect(
        VietnameseTransactionQueryParser.resolveCategoryId(
          'mua sam',
          categories,
        ),
        'shopping',
      );
    });

    test('returns null for unknown keyword', () {
      expect(
        VietnameseTransactionQueryParser.resolveCategoryId(
          'vinasoy',
          [food, shopping],
        ),
        isNull,
      );
      expect(
        VietnameseTransactionQueryParser.resolveCategoryId('', [food]),
        isNull,
      );
    });
  });
}
