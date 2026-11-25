import 'package:bill_tracker/features/assistant/domain/services/assistant_engine.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_responder.dart';
import 'package:bill_tracker/features/assistant/presentation/providers/assistant_providers.dart';
import 'package:bill_tracker/features/assistant/presentation/widgets/assistant_bubble.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  final now = DateTime(2026, 11, 24, 9, 30);

  late FakeTransactionRepository transactions;
  late FakeAssistantRepository repository;
  late AssistantEngine engine;

  List<Override> overrides() => [
        assistantRepositoryProvider.overrideWithValue(repository),
        assistantEngineProvider.overrideWithValue(engine),
        assistantResponderProvider.overrideWithValue(
          AssistantResponder(engine: engine, llmClient: OfflineOnlyLlmClient()),
        ),
        transactionRepositoryProvider.overrideWithValue(transactions),
      ];

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

  Future<void> pumpHost(WidgetTester tester, {Widget? host}) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          home: Scaffold(
            body: host ??
                const AssistantBubbleHost(
                  child: SizedBox.expand(),
                ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('floating bubble opens the assistant popup', (tester) async {
    await pumpHost(tester);

    expect(find.byTooltip('Trợ lý chi tiêu'), findsOneWidget);
    expect(find.text('Hỏi nhanh về chi tiêu của bạn'), findsNothing);

    await tester.tap(find.byTooltip('Trợ lý chi tiêu'));
    await tester.pumpAndSettle();

    expect(find.text('Hỏi nhanh về chi tiêu của bạn'), findsOneWidget);
    expect(find.text('Chạy hoàn toàn trên thiết bị'), findsOneWidget);
    expect(find.text('Tháng này tôi tiêu bao nhiêu?'), findsOneWidget);

    await tester.tap(find.byTooltip('Đóng trợ lý'));
    await tester.pumpAndSettle();

    expect(find.text('Hỏi nhanh về chi tiêu của bạn'), findsNothing);
  });

  testWidgets('answers a suggestion inside the popup', (tester) async {
    await pumpHost(tester);

    await tester.tap(find.byTooltip('Trợ lý chi tiêu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tháng này tôi tiêu bao nhiêu?'));
    await tester.pumpAndSettle();

    expect(find.textContaining('260.000đ'), findsWidgets);
    expect(find.text('Tổng chi'), findsOneWidget);
    expect(repository.messages, hasLength(2));
    expect(repository.messages.last.isLocal, isTrue);
  });

  testWidgets('shows an unread badge for answers received while closed',
      (tester) async {
    final container = ProviderContainer(overrides: overrides());
    addTearDown(container.dispose);

    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: AssistantBubbleHost(child: SizedBox.expand()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1'), findsNothing);

    await container
        .read(assistantChatProvider.notifier)
        .send('tháng này tôi tiêu bao nhiêu?');
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byTooltip('Trợ lý chi tiêu'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Đóng trợ lý'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsNothing);
  });

  testWidgets('bubble stays on screen after a drag', (tester) async {
    await pumpHost(tester);

    await tester.drag(
      find.byTooltip('Trợ lý chi tiêu'),
      const Offset(-400, -200),
    );
    await tester.pumpAndSettle();

    final bubble = tester.getCenter(find.byTooltip('Trợ lý chi tiêu'));
    expect(bubble.dx, greaterThanOrEqualTo(0));
    expect(bubble.dx, lessThan(420));
    expect(bubble.dy, greaterThanOrEqualTo(0));
    expect(bubble.dy, lessThan(900));
  });
}
