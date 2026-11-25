import 'package:bill_tracker/core/ai/price_text_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceTextExtractor.extract', () {
    test('finds grouped thousands with currency symbol', () {
      final candidates = PriceTextExtractor.extract('Nước suối 45.000đ');

      expect(candidates, isNotEmpty);
      expect(candidates.first.value, 45000);
      expect(candidates.first.confidence, greaterThanOrEqualTo(0.9));
    });

    test('finds comma-grouped amount', () {
      final candidates = PriceTextExtractor.extract('Gia: 45,000 VND');

      expect(candidates.map((c) => c.value), contains(45000));
    });

    test('finds bare 4-6 digit amounts', () {
      final candidates = PriceTextExtractor.extract('HEINEKEN  35000');

      expect(candidates.map((c) => c.value), contains(35000));
      expect(candidates.first.confidence, lessThan(0.8));
    });

    test('finds k-shorthand', () {
      final candidates = PriceTextExtractor.extract('Trà sữa 45k');

      expect(candidates.map((c) => c.value), contains(45000));
      expect(candidates.first.confidence, 0.7);
    });

    test('ignores values below 100 VND', () {
      final candidates = PriceTextExtractor.extract('Gia: 5');

      expect(candidates, isEmpty);
    });

    test('ignores values above 100 million VND', () {
      final candidates = PriceTextExtractor.extract('Gia: 500.000.000');

      expect(candidates, isEmpty);
    });

    test('ignores dates and phone-like digit runs', () {
      // A date + long digit runs should not become plausible prices; the
      // 2026 might match the bare 4-digit rule but stays low confidence.
      final candidates = PriceTextExtractor.extract('HSD 01/03/2027  0912345678');

      expect(
        candidates.every((c) => c.value != 912345678),
        isTrue,
      );
      expect(
        candidates.every((c) => c.value != 2027 || c.confidence < 0.7),
        isTrue,
      );
    });

    test('dedupes repeated values keeping the highest confidence', () {
      final candidates = PriceTextExtractor.extract('25.000\n25.000đ\n25000');

      final values = candidates.map((c) => c.value).where((v) => v == 25000);
      expect(values, hasLength(1));
      expect(candidates.firstWhere((c) => c.value == 25000).confidence, 0.9);
    });

    test('empty and junk text return no candidates', () {
      expect(PriceTextExtractor.extract(''), isEmpty);
      expect(PriceTextExtractor.extract('Nước uống'), isEmpty);
    });
  });

  group('PriceOcrResult.confidentValue', () {
    test('returns the single candidate at or above threshold', () {
      final result = PriceTextExtractor.buildResult(
        'Coca Cola 12.000đ',
        42,
      );

      expect(result.confidentValue, isNotNull);
      expect(result.confidentValue!.value, 12000);
      expect(result.latencyMs, 42);
    });

    test('returns null when several candidates compete', () {
      final result = PriceTextExtractor.buildResult(
        'Nước 12.000đ\nPepsi 15.000đ',
        10,
      );

      expect(result.confidentValue, isNull);
    });

    test('returns null when the only candidate is low confidence', () {
      final result = PriceTextExtractor.buildResult('Mã 123456', 10);

      expect(result.confidentValue, isNull);
    });
  });
}
