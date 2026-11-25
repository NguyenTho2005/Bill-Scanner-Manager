import 'package:equatable/equatable.dart';

/// One VND price candidate found by OCR on a product label.
class PriceCandidate extends Equatable {
  /// Creates a [PriceCandidate].
  const PriceCandidate({required this.value, required this.confidence});

  /// Amount in VND.
  final double value;

  /// Heuristic confidence between 0.0 and 1.0.
  final double confidence;

  @override
  List<Object?> get props => [value, confidence];

  @override
  String toString() => 'PriceCandidate($value, $confidence)';
}

/// Aggregate output of price OCR for one image (§4.6 #15).
class PriceOcrResult extends Equatable {
  /// Creates a [PriceOcrResult].
  const PriceOcrResult({
    required this.rawText,
    required this.candidates,
    required this.latencyMs,
  });

  /// Raw recognized text, kept for debug/retrain.
  final String rawText;

  /// All price candidates found, ordered by confidence (best first).
  final List<PriceCandidate> candidates;

  /// OCR latency in milliseconds.
  final int latencyMs;

  /// The single best candidate when it is confident enough to auto-fill
  /// the amount numpad. `null` when ambiguous or below the threshold —
  /// in that case the user enters the amount manually.
  PriceCandidate? get confidentValue {
    final confident =
        candidates.where((c) => c.confidence >= autoFillThreshold).toList();
    if (confident.length != 1) return null;
    return confident.first;
  }

  /// A candidate is auto-fillable only at this confidence or higher.
  static const double autoFillThreshold = 0.7;

  @override
  List<Object?> get props => [rawText, candidates, latencyMs];
}

/// Rule-based extractor of VND-style price strings from OCR text.
///
/// Recognized formats (Vietnamese labels):
/// - grouped thousands: `45.000`, `45,000`
/// - bare 4–6 digit numbers: `45000`
/// - currency suffix/prefix: `45.000đ`, `45.000 VND`, `₫45.000`
/// - thousand shorthand: `45k`, `45K`
class PriceTextExtractor {
  PriceTextExtractor._();

  static final RegExp _groupedRegex = RegExp(
    r'(?:₫|đ)?\s*([0-9]{1,3}(?:[.,][0-9]{3})+)(?:\s*(?:₫|đ|vnd))?',
    caseSensitive: false,
  );

  static final RegExp _bareRegex = RegExp(
    r'(?:₫|đ)?\s*([0-9]{4,6})(?:\s*(?:₫|đ|vnd))?(?![0-9])',
    caseSensitive: false,
  );

  static final RegExp _kShorthandRegex = RegExp(
    r'(?:₫|đ)?\s*([0-9]{1,3}(?:[.,][0-9]{1,2})?)\s*[kK](?:\s*(?:₫|đ|vnd))?(?![a-zA-Z0-9])',
  );

  /// Extracts price candidates from OCR text, best-first.
  static List<PriceCandidate> extract(String rawText) {
    final found = <PriceCandidate>[];
    void add(double value, double confidence) {
      if (value < 100 || value > 100000000) return;
      // Dedupe by value, keep the highest confidence.
      final existing = found.indexWhere((c) => c.value == value);
      if (existing >= 0) {
        if (confidence > found[existing].confidence) {
          found[existing] = PriceCandidate(value: value, confidence: confidence);
        }
        return;
      }
      found.add(PriceCandidate(value: value, confidence: confidence));
    }

    for (final match in _groupedRegex.allMatches(rawText)) {
      final value = _parseNumber(match.group(1)!);
      if (value != null) {
        final hasSymbol = match.group(0)!.contains(RegExp('[₫đvVnNdD]'));
        add(value, hasSymbol ? 0.9 : 0.8);
      }
    }

    for (final match in _bareRegex.allMatches(rawText)) {
      final value = _parseNumber(match.group(1)!);
      if (value != null) {
        final hasSymbol = match.group(0)!.contains(RegExp('[₫đvVnNdD]'));
        add(value, hasSymbol ? 0.75 : 0.55);
      }
    }

    for (final match in _kShorthandRegex.allMatches(rawText)) {
      final value = _parseNumber(match.group(1)!);
      if (value != null) {
        add(value * 1000, 0.7);
      }
    }

    // Sort by confidence desc, then value desc (larger price more likely
    // to be the real one when confidences tie).
    found.sort((a, b) {
      final byConfidence = b.confidence.compareTo(a.confidence);
      return byConfidence != 0 ? byConfidence : b.value.compareTo(a.value);
    });
    return found;
  }

  /// Builds a [PriceOcrResult] from raw OCR text.
  static PriceOcrResult buildResult(String rawText, int latencyMs) {
    return PriceOcrResult(
      rawText: rawText,
      candidates: extract(rawText),
      latencyMs: latencyMs,
    );
  }

  static double? _parseNumber(String token) {
    final clean = token.replaceAll('.', '').replaceAll(',', '');
    return double.tryParse(clean);
  }
}
