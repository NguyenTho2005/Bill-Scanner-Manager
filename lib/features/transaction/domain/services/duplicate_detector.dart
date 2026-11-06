import 'package:bill_tracker/core/utils/vietnamese_text_utils.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:equatable/equatable.dart';

/// A potential duplicate of a candidate transaction.
class DuplicateMatch extends Equatable {
  /// Creates [DuplicateMatch].
  const DuplicateMatch({
    required this.existing,
    required this.merchantSimilarity,
    required this.hoursApart,
  });

  /// The transaction already stored on-device.
  final Transaction existing;

  /// How similar the merchant (or note) of both transactions is: 0.0–1.0.
  final double merchantSimilarity;

  /// How far apart the two transactions occurred, in hours.
  final double hoursApart;

  @override
  List<Object?> get props => [existing, merchantSimilarity, hoursApart];
}

/// Local-first detector for likely duplicate transactions.
///
/// Two transactions are considered duplicates when:
/// - the amount is (near) identical,
/// - they happened within [timeWindow] hours of each other, and
/// - the merchant (fallback: note) texts are near-identical.
///
/// The detector never deletes anything — it only reports matches so the UI
/// can ask the user whether to keep saving or cancel.
class DuplicateDetector {
  /// Creates [DuplicateDetector].
  const DuplicateDetector({
    this.timeWindow = const Duration(hours: 24),
    this.merchantThreshold = 0.8,
    this.amountTolerance = 0,
  });

  /// Maximum time gap between the candidate and an existing transaction.
  final Duration timeWindow;

  /// Minimum merchant (or note) similarity, 0.0–1.0, for a match.
  final double merchantThreshold;

  /// Maximum absolute difference between amounts to still count as equal.
  final double amountTolerance;

  /// Returns all existing transactions that look like duplicates of
  /// [candidate], sorted by time proximity.
  List<DuplicateMatch> findDuplicates({
    required Transaction candidate,
    required List<Transaction> existing,
    DateTime? now,
  }) {
    final matches = <DuplicateMatch>[];
    for (final other in existing) {
      if (candidate.id == other.id) continue;
      if (!_isSameMoney(candidate, other)) continue;

      final gap = candidate.occurredAt.difference(other.occurredAt).abs();
      if (gap > timeWindow) continue;

      final similarity = _merchantSimilarity(candidate, other);
      if (similarity < merchantThreshold) continue;

      matches.add(
        DuplicateMatch(
          existing: other,
          merchantSimilarity: similarity,
          hoursApart: gap.inHours.toDouble(),
        ),
      );
    }
    matches.sort((a, b) {
      final gapA = candidate.occurredAt.difference(a.existing.occurredAt).abs();
      final gapB = candidate.occurredAt.difference(b.existing.occurredAt).abs();
      return gapA.compareTo(gapB);
    });
    return matches;
  }

  bool _isSameMoney(Transaction a, Transaction b) {
    if (a.type != b.type) return false;
    if (a.currency != b.currency) return false;
    return (a.amount - b.amount).abs() <= amountTolerance;
  }

  double _merchantSimilarity(Transaction a, Transaction b) {
    final merchantA = a.merchant?.trim();
    final merchantB = b.merchant?.trim();
    if (merchantA != null && merchantB != null) {
      return _textSimilarity(merchantA, merchantB);
    }

    // Fall back to the note when either side has no merchant recorded.
    final noteA = a.note?.trim();
    final noteB = b.note?.trim();
    if (noteA != null && noteB != null) {
      return _textSimilarity(noteA, noteB);
    }

    return 0;
  }

  double _textSimilarity(String a, String b) {
    final areSimilar = VietnameseTextUtils.similarity(a, b);
    final overlap = VietnameseTextUtils.tokenOverlapSimilarity(a, b);
    return areSimilar > overlap ? areSimilar : overlap;
  }
}
