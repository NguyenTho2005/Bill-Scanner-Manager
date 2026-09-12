import 'package:equatable/equatable.dart';

/// Parsed line item from a scanned receipt.
class ParsedLineItem extends Equatable {
  /// Creates [ParsedLineItem].
  const ParsedLineItem({
    required this.name,
    required this.total,
    this.quantity,
    this.unitPrice,
    this.categorySuggestion,
    this.confidence = 1.0,
  });

  /// Name or description of the product.
  final String name;

  /// Quantity purchased.
  final double? quantity;

  /// Unit price.
  final double? unitPrice;

  /// Total price for this line.
  final double total;

  /// Category suggested for this line item.
  final String? categorySuggestion;

  /// Confidence score between 0.0 and 1.0.
  final double confidence;

  @override
  List<Object?> get props => [
        name,
        quantity,
        unitPrice,
        total,
        categorySuggestion,
        confidence,
      ];
}

/// Comprehensive extraction output from scanning a receipt.
class ReceiptExtractionResult extends Equatable {
  /// Creates [ReceiptExtractionResult].
  const ReceiptExtractionResult({
    required this.rawText,
    required this.overallConfidence,
    this.merchant,
    this.merchantConfidence,
    this.transactionDate,
    this.dateConfidence,
    this.total,
    this.totalConfidence,
    this.subtotal,
    this.tax,
    this.paymentMethod,
    this.lineItems = const [],
    this.requiresReview = false,
  });

  /// Full raw OCR text.
  final String rawText;

  /// Extracted merchant/store name.
  final String? merchant;

  /// Confidence for merchant extraction.
  final double? merchantConfidence;

  /// Extracted transaction date.
  final DateTime? transactionDate;

  /// Confidence for date extraction.
  final double? dateConfidence;

  /// Extracted total amount.
  final double? total;

  /// Confidence for total amount.
  final double? totalConfidence;

  /// Subtotal before tax/discounts if found.
  final double? subtotal;

  /// Tax amount (VAT) if found.
  final double? tax;

  /// Detected payment method string (e.g. 'cash', 'card', 'transfer', 'ewallet').
  final String? paymentMethod;

  /// Itemized line items if parsed.
  final List<ParsedLineItem> lineItems;

  /// Overall composite confidence score.
  final double overallConfidence;

  /// True if total confidence < 0.70 or critical fields are ambiguous.
  final bool requiresReview;

  @override
  List<Object?> get props => [
        rawText,
        merchant,
        merchantConfidence,
        transactionDate,
        dateConfidence,
        total,
        totalConfidence,
        subtotal,
        tax,
        paymentMethod,
        lineItems,
        overallConfidence,
        requiresReview,
      ];
}

/// Abstract contract for Receipt OCR services.
abstract class ReceiptOcrService {
  /// Scans a receipt image at [imagePath] and returns extracted structured data.
  Future<ReceiptExtractionResult> extractReceipt(String imagePath);

  /// Releases OCR resources.
  void dispose();
}
