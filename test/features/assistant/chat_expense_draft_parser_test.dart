import 'package:bill_tracker/features/assistant/domain/services/chat_expense_draft_parser.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  final now = DateTime(2026, 11, 24, 9, 30);
  const parser = ChatExpenseDraftParser(categories: testCategories);

  test('parses a simple coffee expense', () {
    final draft = parser.parse('cà phê 45k', now: now);

    expect(draft, isNotNull);
    expect(draft!.amount, 45000);
    expect(draft.note, 'Cà phê');
    expect(draft.categoryId, 'food_drinks');
    expect(draft.type, TransactionType.expense);
    expect(draft.occurredAt, now);
  });

  test('ignores a leading quantity when a unit amount exists', () {
    final draft = parser.parse('2 ly cà phê sữa 45k', now: now);

    expect(draft!.amount, 45000);
    expect(draft.note?.toLowerCase(), contains('2 ly'));
  });

  test('understands thousand separators', () {
    final draft = parser.parse('grab 60.000', now: now);

    expect(draft!.amount, 60000);
    expect(draft.categoryId, 'transport');
  });

  test('understands "triệu" and income wording', () {
    final draft = parser.parse('nhận lương 15 triệu', now: now);

    expect(draft!.amount, 15000000);
    expect(draft.type, TransactionType.income);
  });

  test('resolves yesterday', () {
    final draft = parser.parse('trà sữa 30k hôm qua', now: now);

    expect(draft!.occurredAt.day, 23);
    expect(draft.amount, 30000);
  });

  test('resolves day from last month safely', () {
    final draft = parser.parse('mua áo 200k tháng trước', now: now);

    expect(draft!.occurredAt.month, 10);
    expect(draft.categoryId, 'shopping');
  });

  test('returns null when no amount is present', () {
    expect(parser.parse('xin chào', now: now), isNull);
    expect(parser.parse('tháng này tôi tiêu bao nhiêu', now: now), isNull);
  });

  test('falls back to the "other" category when nothing matches', () {
    final draft = parser.parse('abc xyz 12k', now: now);
    expect(draft!.categoryId, 'other');
  });
}
