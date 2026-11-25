import 'package:bill_tracker/features/assistant/domain/entities/assistant_block.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_reply.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_engine.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  final now = DateTime(2026, 11, 24, 9, 30);

  late FakeTransactionRepository transactions;
  late FakeBudgetRepository budgets;
  late AssistantEngine engine;

  setUp(() {
    transactions = FakeTransactionRepository([
      buildTransaction(
        id: 'tx_1',
        amount: 50000,
        categoryId: 'food_drinks',
        occurredAt: DateTime(2026, 11, 2, 8),
        merchant: 'Highlands',
      ),
      buildTransaction(
        id: 'tx_2',
        amount: 150000,
        categoryId: 'food_drinks',
        occurredAt: DateTime(2026, 11, 10, 19),
        merchant: 'Pizza 4P',
      ),
      buildTransaction(
        id: 'tx_3',
        amount: 60000,
        categoryId: 'transport',
        occurredAt: DateTime(2026, 11, 5, 7),
        note: 'Grab',
      ),
      buildTransaction(
        id: 'tx_4',
        amount: 10000000,
        categoryId: 'other',
        occurredAt: DateTime(2026, 11, 15, 9),
        type: TransactionType.income,
        note: 'Lương',
      ),
      buildTransaction(
        id: 'tx_5',
        amount: 100000,
        categoryId: 'food_drinks',
        occurredAt: DateTime(2026, 10, 12, 12),
      ),
    ]);
    budgets = FakeBudgetRepository([
      buildProgress(
        category: testCategories[0],
        limit: 200000,
        spent: 200000,
      ),
      buildProgress(
        category: testCategories[1],
        limit: 500000,
        spent: 60000,
      ),
    ]);
    engine = AssistantEngine(
      transactionRepository: transactions,
      categoryRepository: FakeCategoryRepository(),
      reportRepository: FakeReportRepository(transactions.transactions),
      budgetRepository: budgets,
      clock: () => now,
    );
  });

  Future<AssistantReply> ask(String input) async {
    final query = await engine.understand(input);
    return engine.respondTo(query);
  }

  test('answers total spend for the current month', () async {
    final reply = await ask('tháng này tôi tiêu bao nhiêu?');

    expect(reply.text, contains('260.000đ'));
    expect(reply.text, contains('3 giao dịch'));
    final metrics = reply.blocks.whereType<MetricBlock>().single;
    expect(metrics.rows.first.value, '260.000đ');
    expect(
      metrics.rows.any((row) => row.label == 'Tổng thu'),
      isTrue,
    );
  });

  test('answers total spend for a specific category', () async {
    final reply = await ask('ăn uống tháng này bao nhiêu');

    expect(reply.text, contains('200.000đ'));
    expect(reply.text, contains('ăn uống'));
  });

  test('lists top expenses with transaction cards', () async {
    final reply = await ask('top 2 khoản chi lớn nhất');

    final block = reply.blocks.whereType<TransactionsBlock>().single;
    expect(block.items, hasLength(2));
    expect(block.items.first.amount, 150000);
    expect(block.items[1].amount, 60000);
  });

  test('breaks spending down by category', () async {
    final reply = await ask('chi tiêu theo danh mục');

    final metrics = reply.blocks.whereType<MetricBlock>().single;
    expect(metrics.rows.first.label, 'Ăn uống');
    expect(metrics.rows.first.value, '200.000đ');
    expect(metrics.rows.first.hint, contains('77%'));
    expect(metrics.rows, hasLength(2));
  });

  test('counts transactions', () async {
    final reply = await ask('tháng này có bao nhiêu giao dịch');

    expect(reply.text, contains('4 giao dịch'));
    expect(reply.text, contains('3 khoản chi'));
    expect(reply.text, contains('1 khoản thu'));
  });

  test('compares with the previous month', () async {
    final reply = await ask('so với tháng trước thế nào');

    expect(reply.text, contains('260.000đ'));
    expect(reply.text, contains('100.000đ'));
    final metrics = reply.blocks.whereType<MetricBlock>().single;
    expect(metrics.rows, hasLength(3));
  });

  test('reports budget status and exceeded categories', () async {
    final reply = await ask('ngân sách còn lại');

    expect(reply.text, contains('vượt giới hạn'));
    expect(reply.text, contains('Ăn uống'));
    final metrics = reply.blocks.whereType<MetricBlock>().single;
    expect(metrics.rows.first.hint, contains('Vượt'));
  });

  test('returns a draft for a quick-capture message', () async {
    final reply = await ask('cà phê sữa 45k');

    final draftBlock = reply.blocks.whereType<DraftBlock>().single;
    expect(draftBlock.draft.amount, 45000);
    expect(draftBlock.draft.categoryId, 'food_drinks');
    expect(draftBlock.state, DraftState.pending);
    expect(reply.text, contains('45.000đ'));
  });

  test('asks for a clearer message when the amount is missing', () async {
    final reply = await ask('cà phê');
    expect(reply.text, contains('chưa đọc được số tiền'));
    expect(reply.blocks.whereType<DraftBlock>(), isEmpty);
  });

  test('offers help and support content', () async {
    final help = await ask('bạn làm được gì');
    expect(help.text, contains('top 5 khoản chi'));

    final support = await ask('báo lỗi góp ý');
    expect(support.isFeedback, isTrue);
    expect(support.blocks.whereType<NoteBlock>().single.copyable, isTrue);
  });

  test('says there is no data for an empty period', () async {
    final reply = await ask('chi tiêu tuần trước');
    expect(reply.text, contains('chưa thấy giao dịch nào'));
  });

  test('builds a privacy-safe snapshot for the cloud model', () async {
    final snapshot = await engine.buildSnapshot(months: 2);

    expect(snapshot.text, contains('T11/2026'));
    expect(snapshot.text, contains('Ngân sách tháng này'));
    expect(snapshot.text, isNot(contains('Highlands')));
    expect(snapshot.text, isNot(contains('Pizza 4P')));
  });

  test('transaction draft carries the parsed note and date', () async {
    final reply = await ask('grab 60k hôm qua');
    final draft = reply.blocks.whereType<DraftBlock>().single.draft;

    expect(draft.amount, 60000);
    expect(draft.categoryId, 'transport');
    expect(draft.occurredAt.day, 23);
  });
}
