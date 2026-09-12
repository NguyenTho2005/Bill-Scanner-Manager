import 'package:bill_tracker/core/ai/receipt_ocr_service.dart';

/// Rule-based parser for Vietnamese retail and F&B receipts.
class VietnameseReceiptParser {
  VietnameseReceiptParser._();

  static final List<String> _knownMerchants = [
    'Highlands Coffee',
    'Phúc Long',
    'The Coffee House',
    'Starbucks',
    'WinMart+',
    'WinMart',
    'Circle K',
    'GS25',
    'FamilyMart',
    '7-Eleven',
    'Co.opmart',
    'Bách Hóa Xanh',
    'Lotte Mart',
    'Big C',
    'KFC',
    'Lotteria',
    'Jollibee',
    "McDonald's",
    'Pizza Hut',
    'Domino Pizza',
    'Golden Gate',
    'Kichi Kichi',
    'Gogi House',
    'ShopeeFood',
    'GrabFood',
  ];

  static final List<RegExp> _totalKeywords = [
    RegExp(r't[ổo]ng\s*c[ộo]ng', caseSensitive: false),
    RegExp(r't[ổo]ng\s*ti[ềe]n', caseSensitive: false),
    RegExp(r'thanh\s*to[áa]n', caseSensitive: false),
    RegExp(r'ti[ềe]n\s*ph[ảa]i\s*tr[ảa]', caseSensitive: false),
    RegExp(r'c[ộo]ng\s*ti[ềe]n\s*h[àa]ng', caseSensitive: false),
    RegExp('total', caseSensitive: false),
    RegExp(r'amount\s*due', caseSensitive: false),
  ];

  static final RegExp _amountRegex = RegExp(
    '(?:[0-9]{1,3}(?:[.,][0-9]{3})+|[0-9]{4,})',
  );

  static final RegExp _dateRegex = RegExp(
    r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})|(\d{4})[/-](\d{1,2})[/-](\d{1,2})',
  );

  /// Parses raw OCR text into structured [ReceiptExtractionResult].
  static ReceiptExtractionResult parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String? merchant;
    double? merchantConfidence;

    DateTime? transactionDate;
    double? dateConfidence;

    double? total;
    double? totalConfidence;

    String? paymentMethod;

    // ── 1. Detect Merchant ────────────────────────────────────────────
    for (final line in lines.take(6)) {
      final normalizedLine = _removeDiacritics(line).toLowerCase();
      for (final brand in _knownMerchants) {
        final normalizedBrand = _removeDiacritics(brand).toLowerCase();
        if (normalizedLine.contains(normalizedBrand)) {
          merchant = brand;
          merchantConfidence = 0.95;
          break;
        }
      }
      if (merchant != null) break;
    }

    // Fallback merchant to the first non-trivial line if not recognized
    if (merchant == null && lines.isNotEmpty) {
      final candidate = lines.first;
      if (candidate.length >= 3 && !candidate.contains(RegExp('[0-9]{4,}'))) {
        merchant = candidate;
        merchantConfidence = 0.65;
      }
    }

    // ── 2. Detect Total Amount ────────────────────────────────────────
    for (var i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      final isTotalLine = _totalKeywords.any((k) => k.hasMatch(line));

      if (isTotalLine) {
        // Try extracting amount from this line
        final amount = _extractAmount(line);
        if (amount != null && amount > 1000) {
          total = amount;
          totalConfidence = 0.92;
          break;
        }

        // Try checking next line if amount is on subsequent line
        if (i + 1 < lines.length) {
          final nextAmount = _extractAmount(lines[i + 1]);
          if (nextAmount != null && nextAmount > 1000) {
            total = nextAmount;
            totalConfidence = 0.88;
            break;
          }
        }
      }
    }

    // Fallback: search bottom lines for the largest VND amount
    if (total == null) {
      double maxFound = 0;
      for (final line in lines.reversed.take(8)) {
        final amount = _extractAmount(line);
        if (amount != null && amount > maxFound && amount < 100000000) {
          maxFound = amount;
        }
      }
      if (maxFound > 1000) {
        total = maxFound;
        totalConfidence = 0.60;
      }
    }

    // ── 3. Detect Date ────────────────────────────────────────────────
    for (final line in lines) {
      final match = _dateRegex.firstMatch(line);
      if (match != null) {
        final parsed = _parseDateMatch(match);
        if (parsed != null) {
          transactionDate = parsed;
          dateConfidence = 0.90;
          break;
        }
      }
    }

    // ── 4. Detect Payment Method ──────────────────────────────────────
    final normText = _removeDiacritics(rawText).toLowerCase();
    if (normText.contains('momo') ||
        normText.contains('zalopay') ||
        normText.contains('shopeepay')) {
      paymentMethod = 'ewallet';
    } else if (normText.contains('chuyen khoan') ||
        normText.contains('vnpay') ||
        normText.contains('vietqr') ||
        normText.contains('qr code')) {
      paymentMethod = 'transfer';
    } else if (normText.contains('the') ||
        normText.contains('visa') ||
        normText.contains('master') ||
        normText.contains('card')) {
      paymentMethod = 'card';
    } else if (normText.contains('tien mat') || normText.contains('cash')) {
      paymentMethod = 'cash';
    }

    // ── 5. Confidence and Review Flag ─────────────────────────────────
    final hasTotal = total != null && (totalConfidence ?? 0) >= 0.70;
    final requiresReview = !hasTotal;
    final overallConfidence = total != null ? (totalConfidence ?? 0.5) : 0.2;

    return ReceiptExtractionResult(
      rawText: rawText,
      merchant: merchant,
      merchantConfidence: merchantConfidence,
      transactionDate: transactionDate ?? DateTime.now(),
      dateConfidence: dateConfidence ?? 0.5,
      total: total,
      totalConfidence: totalConfidence,
      paymentMethod: paymentMethod,
      overallConfidence: overallConfidence,
      requiresReview: requiresReview,
    );
  }

  static double? _extractAmount(String line) {
    final matches = _amountRegex.allMatches(line);
    if (matches.isEmpty) return null;

    // Pick the last matched amount on the line (standard format: Label ... Amount)
    final matchStr = matches.last.group(0)!;
    // Normalize commas and dots: "45.000" or "45,000" -> "45000"
    final cleanStr = matchStr.replaceAll('.', '').replaceAll(',', '');
    return double.tryParse(cleanStr);
  }

  static DateTime? _parseDateMatch(Match match) {
    try {
      if (match.group(1) != null) {
        // Format: dd/MM/yyyy
        final d = int.parse(match.group(1)!);
        final m = int.parse(match.group(2)!);
        final y = int.parse(match.group(3)!);
        if (m >= 1 && m <= 12 && d >= 1 && d <= 31 && y >= 2020 && y <= 2030) {
          return DateTime(y, m, d);
        }
      } else if (match.group(4) != null) {
        // Format: yyyy-MM-dd
        final y = int.parse(match.group(4)!);
        final m = int.parse(match.group(5)!);
        final d = int.parse(match.group(6)!);
        if (m >= 1 && m <= 12 && d >= 1 && d <= 31 && y >= 2020 && y <= 2030) {
          return DateTime(y, m, d);
        }
      }
    } on Object {
      return null;
    }
    return null;
  }

  static String _removeDiacritics(String str) {
    const withDiacritics =
        'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđ'
        'ÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬÉÈẺẼẸÊẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÚÙỦŨỤƯỨỪỬỮỰÝỲỶỸỴĐ';
    const withoutDiacritics =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    var result = str;
    for (var i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return result;
  }
}
