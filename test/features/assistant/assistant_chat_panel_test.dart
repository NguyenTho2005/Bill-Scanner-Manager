import 'package:bill_tracker/features/assistant/domain/services/assistant_engine.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_responder.dart';
import 'package:bill_tracker/features/assistant/presentation/providers/assistant_providers.dart';
import 'package:bill_tracker/features/assistant/presentation/widgets/assistant_chat_panel.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late FakeTransactionRepository transactions;
  late FakeAssistantRepository repository;
  late AssistantEngine engine;

  final now = DateTime(2026, 11, 24, 9, 30);

  setUp(() {
    transactions = FakeTransactionRepository([
      buildTransaction(
        id: 'tx_1',
        amount: 50000,
        categoryId: 'food_drinks',
        occurredAt: DateTime(2026, 11, 2, 8),
      ),
      buildTransaction(
        id: 'tx_2',
        amount: 210000,
        categoryId: 'food_drinks',
        occurredAt: DateTime(2026, 11, 10, 19),
      ),
    ]);
    repository = FakeAssistantRepository();
    engine = AssistantEngine(
      transactionRepository: transactions,
      categoryRepository: FakeCategoryRepository(),
      reportRepository: FakeReportRepository(transactions.transactions),
      budgetRepository: FakeBudgetRepository(),
      clock: () => now,
    );
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          assistantRepositoryProvider.overrideWithValue(repository),
          assistantEngineProvider.overrideWithValue(engine),
          assistantResponderProvider.overrideWithValue(
            AssistantResponder(
              engine: engine,
              llmClient: OfflineOnlyLlmClient(),
            ),
          ),
          transactionRepositoryProvider.overrideWithValue(transactions),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AssistantChatPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the empty state with starter prompts', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Hỏi nhanh về chi tiêu của bạn'), findsOneWidget);
    expect(find.text('Tháng này tôi tiêu bao nhiêu?'), findsOneWidget);
    expect(find.text('Cà phê 45k'), findsOneWidget);
    expect(find.text('Chạy hoàn toàn trên thiết bị'), findsOneWidget);
  });

  testWidgets('answers a prompt with metrics computed locally', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Tháng này tôi tiêu bao nhiêu?'));
    await tester.pumpAndSettle();

    expect(find.textContaining('260.000đ'), findsWidgets);
    expect(find.text('Tổng chi'), findsOneWidget);
    expect(find.textContaining('Xử lý trên thiết bị'), findsWidgets);
    expect(repository.messages.length, 2);
  });

  testWidgets('confirms a draft created from free text', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'cà phê 45k');
    await tester.pump();
    await tester.tap(find.byTooltip('Gửi'));
    await tester.pumpAndSettle();

    expect(find.text('Lưu giao dịch'), findsOneWidget);

    await tester.tap(find.text('Lưu giao dịch'));
    await tester.pumpAndSettle();

    expect(find.text('Đã lưu vào sổ giao dịch'), findsOneWidget);
    expect(transactions.transactions, hasLength(3));
    expect(transactions.transactions.last.amount, 45000);
    expect(transactions.transactions.last.categoryId, 'food_drinks');
  });

  testWidgets('dismisses a draft without saving', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'grab 60k');
    await tester.pump();
    await tester.tap(find.byTooltip('Gửi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bỏ'));
    await tester.pumpAndSettle();

    expect(find.text('Đã bỏ qua'), findsOneWidget);
    expect(transactions.transactions, hasLength(2));
  });

  testWidgets('opens assistant settings and exposes the privacy switch',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Cấu hình trợ lý'));
    await tester.pumpAndSettle();

    expect(find.text('Trợ lý AI'), findsOneWidget);
    expect(find.text('Trợ lý AI cloud (tuỳ chọn)'), findsOneWidget);
    expect(find.text('Lưu cấu hình'), findsOneWidget);
  });

  testWidgets('clears the conversation after confirmation', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.byType(TextField),
      'tháng này tôi tiêu bao nhiêu',
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Gửi'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Tuỳ chọn khác'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xoá hội thoại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xoá'));
    await tester.pumpAndSettle();

    expect(find.text('Hỏi nhanh về chi tiêu của bạn'), findsOneWidget);
    expect(repository.messages, isEmpty);
  });
}
