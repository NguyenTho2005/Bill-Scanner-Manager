import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/services/duplicate_detector.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _tx({
  required String id,
  required double amount,
  required DateTime occurredAt,
  String? merchant,
  String? note,
  TransactionType type = TransactionType.expense,
}) =>
    Transaction(
      id: id,
      type: type,
      amount: amount,
      currency: 'VND',
      categoryId: 'food_drinks',
      merchant: merchant,
      note: note,
      occurredAt: occurredAt,
      source: TransactionSource.manual,
      status: TransactionStatus.confirmed,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  const detector = DuplicateDetector();

  final base = DateTime(2026, 11, 3, 10);
  final candidate = _tx(
    id: 'new-1',
    amount: 45000,
    occurredAt: base,
    merchant: 'Highlands Coffee 273',
  );

  group('DuplicateDetector basics', () {
    test('flags same amount, similar merchant within 24h', () {
      final existing = _tx(
        id: 'old-1',
        amount: 45000,
        occurredAt: base.subtract(const Duration(hours: 2)),
        merchant: 'Highlands Coffee',
      );

      final matches = detector.findDuplicates(
        candidate: candidate,
        existing: [existing],
      );

      expect(matches, hasLength(1));
      expect(matches.first.existing.id, 'old-1');
    });

    test('does not match when amount differs', () {
      final existing = _tx(
        id: 'old-1',
        amount: 120000,
        occurredAt: base,
        merchant: 'Highlands Coffee',
      );

      final matches = detector.findDuplicates(
        candidate: candidate,
        existing: [existing],
      );

      expect(matches, isEmpty);
    });

    test('does not match beyond the 24h window', () {
      final existing = _tx(
        id: 'old-1',
        amount: 45000,
        occurredAt: base.subtract(const Duration(hours: 30)),
        merchant: 'Highlands Coffee',
      );

      final matches = detector.findDuplicates(
        candidate: candidate,
        existing: [existing],
      );

      expect(matches, isEmpty);
    });

    test('does not match a completely different merchant', () {
      final existing = _tx(
        id: 'old-1',
        amount: 45000,
        occurredAt: base,
        merchant: 'WinMart Lang Ha',
      );

      final matches = detector.findDuplicates(
        candidate: candidate,
        existing: [existing],
      );

      expect(matches, isEmpty);
    });

    test("ignores the candidate's own id (edit flow)", () {
      final self = _tx(
        id: 'new-1',
        amount: 45000,
        occurredAt: base,
        merchant: 'Highlands Coffee 273',
      );

      final matches = detector.findDuplicates(
        candidate: candidate,
        existing: [self],
      );

      expect(matches, isEmpty);
    });

    test('does not cross-match income with expense', () {
      final income = _tx(
        id: 'old-1',
        amount: 45000,
        occurredAt: base,
        merchant: 'Highlands Coffee',
        type: TransactionType.income,
      );

      final matches = detector.findDuplicates(
        candidate: candidate,
        existing: [income],
      );

      expect(matches, isEmpty);
    });
  });

  group('DuplicateDetector fuzzy merchant matching', () {
    test('ignores case, diacritics and punctuation', () {
      final existing = _tx(
        id: 'old-1',
        amount: 45000,
        occurredAt: base.subtract(const Duration(minutes: 30)),
        merchant: 'HIGHLANDS COFFEE 273 * BT',
      );

      final matches = detector.findDuplicates(
        candidate: candidate,
        existing: [existing],
      );

      expect(matches, hasLength(1));
    });

    test('matches via token overlap (branch detail)', () {
      final branchCandidate = _tx(
        id: 'new-3',
        amount: 45000,
        occurredAt: base,
        merchant: 'Highlands Coffee',
      );
      final existing = _tx(
        id: 'old-1',
        amount: 45000,
        occurredAt: base,
        merchant: 'Highlands Coffee Pham Ngoc Thach',
      );

      final matches = detector.findDuplicates(
        candidate: branchCandidate,
        existing: [existing],
      );

      expect(matches, hasLength(1));
      expect(matches.first.merchantSimilarity, greaterThan(0.8));
    });

    test('falls back to note similarity when merchant missing', () {
      final noteCandidate = _tx(
        id: 'new-2',
        amount: 89000,
        occurredAt: base,
        note: 'Giao cao su WinMart',
      );
      final existing = _tx(
        id: 'old-2',
        amount: 89000,
        occurredAt: base.subtract(const Duration(hours: 5)),
        note: 'giao cao su winmart',
      );

      final matches = detector.findDuplicates(
        candidate: noteCandidate,
        existing: [existing],
      );

      expect(matches, hasLength(1));
    });

    test('never matches when only one side has any text', () {
      final existing = _tx(
        id: 'old-3',
        amount: 45000,
        occurredAt: base,
      );

      final matches = detector.findDuplicates(
        candidate: candidate,
        existing: [existing],
      );

      expect(matches, isEmpty);
    });
  });

  group('DuplicateDetector ordering and tolerance', () {
    test('sorts matches by time proximity to the candidate', () {
      final far = _tx(
        id: 'far',
        amount: 45000,
        occurredAt: base.subtract(const Duration(hours: 20)),
        merchant: 'Highlands Coffee',
      );
      final near = _tx(
        id: 'near',
        amount: 45000,
        occurredAt: base.subtract(const Duration(hours: 1)),
        merchant: 'Highlands Coffee',
      );

      final matches = detector.findDuplicates(
        candidate: candidate,
        existing: [far, near],
      );

      expect(matches.map((m) => m.existing.id).toList(), ['near', 'far']);
    });

    test('supports an amount tolerance', () {
      const tolerant = DuplicateDetector(
        amountTolerance: 2000,
      );
      final existing = _tx(
        id: 'old-4',
        amount: 46000, // candidate is 45000 → diff 1000 ≤ tolerance.
        occurredAt: base,
        merchant: 'Highlands Coffee',
      );

      final matches = tolerant.findDuplicates(
        candidate: candidate,
        existing: [existing],
      );

      expect(matches, hasLength(1));

      const strict = DuplicateDetector();
      expect(
        strict.findDuplicates(candidate: candidate, existing: [existing]),
        isEmpty,
      );
    });
  });
}
