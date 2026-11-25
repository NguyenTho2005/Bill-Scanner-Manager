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

  /// Lines that never count as product rows: totals, change, fees, header
  /// metadata (address, date, invoice no.), thanks footer, etc.
  static final RegExp _lineItemSkipKeywords = RegExp(
    r'\b(tong cong|tong tien|thanh toan|thanh tien|tien phai tra|tien mat|'
    'tien thua|tien tra lai|cong tien|vat|giam gia|khuyen mai|phi phuc vu|'
    'phi ship|phi giao hang|dat coc|tra hang|doi tra|ngay|dia chi|hoa don|'
    r'cam on|thoi gian|nhan vien|thu ngan|ma don|ma vach|hotline|website)\b',
    caseSensitive: false,
  );

  static final RegExp _leadingQuantity = RegExp(r'^(\d{1,3})\s*[xX×]?\s+');
  static final RegExp _leadingXQuantity = RegExp(r'^[xX×]\s*(\d{1,3})\s+');
  static final RegExp _trailingXQuantity = RegExp(r'\s[xX×]\s*(\d{1,3})$');
  static final RegExp _hasLetters = RegExp('[a-zA-Z]');

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
    // totalLineIndex: index of the keyword line that produced the total, or
    // -1 when the total came from the low-confidence fallback. Line-item
    // parsing uses it as the upper bound of the itemized region.
    var totalLineIndex = -1;
    for (var i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      final isTotalLine = _totalKeywords.any((k) => k.hasMatch(line));

      if (isTotalLine) {
        // Try extracting amount from this line
        final amount = _extractAmount(line);
        if (amount != null && amount > 1000) {
          total = amount;
          totalConfidence = 0.92;
          totalLineIndex = i;
          break;
        }

        // Try checking next line if amount is on subsequent line
        if (i + 1 < lines.length) {
          final nextAmount = _extractAmount(lines[i + 1]);
          if (nextAmount != null && nextAmount > 1000) {
            total = nextAmount;
            totalConfidence = 0.88;
            totalLineIndex = i;
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

    // ── 5. Parse Line Items (between header and total line) ───────────
    final lineItems = _parseLineItems(lines, totalLineIndex);

    // ── 6. Confidence and Review Flag ─────────────────────────────────
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
      lineItems: lineItems,
      overallConfidence: overallConfidence,
      requiresReview: requiresReview,
    );
  }

  /// Parses product rows from the region between the receipt header and the
  /// total line (§4.6 #14). Uses the same heuristic family as total
  /// detection: keyword skips + line position. Returns an empty list when
  /// no keyword total line was found, because the item region then cannot
  /// be bounded reliably.
  static List<ParsedLineItem> _parseLineItems(
    List<String> lines,
    int totalLineIndex,
  ) {
    if (totalLineIndex < 0) return const [];
    final items = <ParsedLineItem>[];
    for (var i = 0; i < totalLineIndex && i < lines.length; i++) {
      final item = _parseLineItemLine(lines[i]);
      if (item != null) items.add(item);
    }
    return items;
  }

  /// Attempts to parse one OCR line into a [ParsedLineItem].
  ///
  /// A plausible item row needs: at least one VND-style amount, a name
  /// fragment with letters before the amount, and no skip keyword
  /// (totals, change, fees, header metadata).
  static ParsedLineItem? _parseLineItemLine(String line) {
    final normalized = _removeDiacritics(line).toLowerCase();
    if (_lineItemSkipKeywords.hasMatch(normalized)) return null;
    if (_dateRegex.hasMatch(line)) return null;

    final matches = _amountRegex.allMatches(line).toList();
    if (matches.isEmpty) return null;

    final namePart = line.substring(0, matches.first.start).trim();
    if (namePart.length < 2 || !_hasLetters.hasMatch(namePart)) return null;

    // Standard layout is "Label ... price": take the last amount as the
    // line total.
    final total = _extractAmount(line);
    if (total == null || total < 100 || total > 100000000) return null;

    // Quantity: leading "2 ", "2x ", "x2 ", or trailing "x2".
    double? quantity;
    var name = namePart;
    final leadQty = _leadingQuantity.firstMatch(namePart);
    if (leadQty != null) {
      quantity = double.tryParse(leadQty.group(1)!);
      name = namePart.substring(leadQty.end).trim();
    } else {
      final leadXQty = _leadingXQuantity.firstMatch(namePart);
      if (leadXQty != null) {
        quantity = double.tryParse(leadXQty.group(1)!);
        name = namePart.substring(leadXQty.end).trim();
      }
    }
    if (quantity == null) {
      final trailingQty = _trailingXQuantity.firstMatch(name);
      if (trailingQty != null) {
        quantity = double.tryParse(trailingQty.group(1)!);
        name = name.substring(0, trailingQty.start).trim();
      }
    }
    if (name.length < 2) return null;

    // Unit price only when the line total divides evenly by quantity.
    double? unitPrice;
    if (quantity != null && quantity > 0) {
      final perUnit = total / quantity;
      if ((perUnit - perUnit.roundToDouble()).abs() < 0.01) {
        unitPrice = perUnit;
      }
    }

    // Per-line confidence (§4.6 #14): one clean trailing amount is strong,
    // multiple amounts are ambiguous; an explicit quantity adds a bit.
    var confidence = 0.85;
    if (matches.length > 1) confidence = 0.65;
    if (line.contains(RegExp('[|;]'))) confidence -= 0.10;
    if (quantity != null) {
      confidence = (confidence + 0.05).clamp(0.0, 0.90);
    }

    return ParsedLineItem(
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
      confidence: confidence.clamp(0.0, 1.0),
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
