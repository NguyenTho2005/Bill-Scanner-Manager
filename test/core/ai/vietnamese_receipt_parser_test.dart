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
  });
}
