import 'package:bill_tracker/core/ai/vietnamese_receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VietnameseReceiptParser', () {
    test('extracts Highlands Coffee receipt with total and momo', () {
      const ocrText = '''
HIGHLANDS COFFEE
Dia chi: 123 Nguyen Trai, Q1
Ngay: 09/09/2026 10:15
Hoa don: #001294
1  Phin Sua Da (L)     39.000
1  Banh Mi Ga          20.000
Cong tien hang:        59.000
TONG CONG:             59.000
Thanh toan: MoMo
Cam on quy khach!
''';

      final result = VietnameseReceiptParser.parse(ocrText);

      expect(result.merchant, 'Highlands Coffee');
      expect(result.merchantConfidence, 0.95);
      expect(result.total, 59000);
      expect(result.totalConfidence, greaterThan(0.85));
      expect(result.paymentMethod, 'ewallet');
      expect(result.transactionDate?.day, 9);
      expect(result.transactionDate?.month, 9);
      expect(result.transactionDate?.year, 2026);
      expect(result.requiresReview, isFalse);
    });

    test('extracts WinMart supermarket receipt', () {
      const ocrText = '''
WINMART+
Cua hang: WinMart+ 88 Lang Ha
Ngay ban: 2026-09-08
1 Sua tuoi Vinamilk     36.000
2 Mi Hao Hao             8.000
Tong tien thanh toan:  145.000
Tien mat:              200.000
Tien thua:              55.000
''';

      final result = VietnameseReceiptParser.parse(ocrText);

      expect(result.merchant, 'WinMart+');
      expect(result.total, 145000);
      expect(result.paymentMethod, 'cash');
      expect(result.transactionDate?.day, 8);
      expect(result.transactionDate?.month, 9);
      expect(result.transactionDate?.year, 2026);
      expect(result.requiresReview, isFalse);
    });

    test('flags requiresReview when total is not detected', () {
      const corruptedOcr = '''
Cua hang tap hoa nho
Ngay: 01/01/2026
...
''';

      final result = VietnameseReceiptParser.parse(corruptedOcr);

      expect(result.requiresReview, isTrue);
      expect(result.overallConfidence, lessThan(0.70));
    });

    test('detects bank transfer payment method with VietQR', () {
      const transferOcr = '''
Phuc Long Coffee & Tea
Ngay: 15/08/2026
Tong cong: 65.000
Hinh thuc: VietQR / Chuyen khoan
''';

      final result = VietnameseReceiptParser.parse(transferOcr);

      expect(result.merchant, 'Phúc Long');
      expect(result.total, 65000);
      expect(result.paymentMethod, 'transfer');
    });

    group('line items', () {
      test('parses product rows between header and total line', () {
        const ocrText = '''
HIGHLANDS COFFEE
Dia chi: 123 Nguyen Trai, Q1
Ngay: 09/09/2026 10:15
Hoa don: #001294
1  Phin Sua Da (L)     39.000
1  Banh Mi Ga          20.000
Cong tien hang:        59.000
TONG CONG:             59.000
Thanh toan: MoMo
Cam on quy khach!
''';

        final result = VietnameseReceiptParser.parse(ocrText);

        expect(result.lineItems, hasLength(2));
        final first = result.lineItems[0];
        expect(first.name, 'Phin Sua Da (L)');
        expect(first.quantity, 1);
        expect(first.total, 39000);
        expect(first.unitPrice, 39000);
        expect(first.confidence, greaterThan(0.7));

        final second = result.lineItems[1];
        expect(second.name, 'Banh Mi Ga');
        expect(second.total, 20000);
      });

      test('computes unit price from quantity', () {
        const ocrText = '''
WINMART+
Ngay ban: 2026-09-08
1 Sua tuoi Vinamilk     36.000
2 Mi Hao Hao             8.000
Tong tien thanh toan:  145.000
''';

        final result = VietnameseReceiptParser.parse(ocrText);

        expect(result.lineItems, hasLength(2));
        final milo = result.lineItems[1];
        expect(milo.name, 'Mi Hao Hao');
        expect(milo.quantity, 2);
        expect(milo.total, 8000);
        expect(milo.unitPrice, 4000);
        expect(milo.confidence, greaterThanOrEqualTo(0.85));
      });

      test('skips totals, change, fees and header metadata rows', () {
        const ocrText = '''
GS25 LE VAN LINH
Ngay: 01/10/2026
Hoa don: 000123
Coca Choi 330ml          12.000
Phi phuc vu:             5.000
Tong cong:              17.000
Tien mat:                50.000
Tien thua:               33.000
''';

        final result = VietnameseReceiptParser.parse(ocrText);

        // Only the product row qualifies; fee/total/cash/change rows are
        // excluded by keyword heuristics.
        expect(result.lineItems, hasLength(1));
        expect(result.lineItems.first.name, 'Coca Choi 330ml');
        expect(result.lineItems.first.total, 12000);
      });

      test('no line items when total comes from fallback', () {
        const ocrText = '''
Cua hang tap hoa nho
Keo dua                  15.000
...
''';

        final result = VietnameseReceiptParser.parse(ocrText);

        // No keyword total line → item region unbounded → skip itemization.
        expect(result.lineItems, isEmpty);
      });

      test('rejects lines without a name or plausible amount', () {
        const ocrText = '''
CIRCLE K
Sticker qua tang             0
Nuoc sua chua                9.000
Tong cong:                  9.000
''';

        final result = VietnameseReceiptParser.parse(ocrText);

        // Zero-amount and nameless rows are dropped.
        expect(result.lineItems, hasLength(1));
        expect(result.lineItems.first.name, 'Nuoc sua chua');
      });

      test('line items carry confidence between 0 and 1', () {
        const ocrText = '''
KFC PASTEUR
1  Ga ran 5 mieng         95.000
Pepsi lon                  18.000
Tong cong:                113.000
''';

        final result = VietnameseReceiptParser.parse(ocrText);

        expect(result.lineItems, hasLength(2));
        for (final item in result.lineItems) {
          expect(item.confidence, inInclusiveRange(0.0, 1.0));
        }
      });
    });
  });
}
