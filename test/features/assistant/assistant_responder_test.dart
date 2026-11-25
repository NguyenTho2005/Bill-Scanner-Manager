import 'package:bill_tracker/features/assistant/domain/entities/assistant_block.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/entities/chat_message.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_engine.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_responder.dart';
import 'package:bill_tracker/features/assistant/domain/services/llm_client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

class _RecordingLlmClient implements LlmClient {
  _RecordingLlmClient({this.reply = 'Câu trả lời từ cloud', this.error});

  final String reply;
  final LlmException? error;
  List<LlmMessage>? received;

  @override
  Future<String> complete({
    required AssistantSettings settings,
    required List<LlmMessage> messages,
  }) async {
    received = messages;
    if (error != null) throw error!;
    return reply;
  }
}

void main() {
  final now = DateTime(2026, 11, 24, 9, 30);

  late FakeTransactionRepository transactions;
  late AssistantEngine engine;

  const cloudSettings = AssistantSettings(
    cloudEnabled: true,
    apiKey: 'test-key',
    baseUrl: 'https://example.invalid/v1',
  );

  setUp(() {
    transactions = FakeTransactionRepository([
      buildTransaction(
        id: 'tx_1',
        amount: 50000,
        categoryId: 'food_drinks',
        occurredAt: DateTime(2026, 11, 2, 8),
      ),
    ]);
    engine = AssistantEngine(
      transactionRepository: transactions,
      categoryRepository: FakeCategoryRepository(),
      reportRepository: FakeReportRepository(transactions.transactions),
      budgetRepository: FakeBudgetRepository(),
      clock: () => now,
    );
  });

  test('answers structured questions locally even with cloud enabled',
      () async {
    final llm = _RecordingLlmClient();
    final responder = AssistantResponder(engine: engine, llmClient: llm);

    final reply = await responder.respond(
      input: 'tháng này tôi tiêu bao nhiêu?',
      settings: cloudSettings,
    );

    expect(reply.answeredByCloud, isFalse);
    expect(reply.text, contains('50.000đ'));
    expect(llm.received, isNull);
  });

  test('forwards unclassified questions to the cloud when enabled', () async {
    final llm = _RecordingLlmClient(reply: 'Bạn nên tiết kiệm hơn nhé.');
    final responder = AssistantResponder(engine: engine, llmClient: llm);

    final reply = await responder.respond(
      input: 'làm sao để tiết kiệm hiệu quả',
      settings: cloudSettings,
    );

    expect(reply.answeredByCloud, isTrue);
    expect(reply.text, 'Bạn nên tiết kiệm hơn nhé.');
    expect(llm.received, isNotNull);
    expect(llm.received!.first.role, 'system');
    expect(llm.received!.first.content, contains('BillTracker'));
    expect(llm.received!.last.content, 'làm sao để tiết kiệm hiệu quả');
  });

  test('falls back to local answers when the cloud call fails', () async {
    final llm = _RecordingLlmClient(
      error: const LlmException('Không kết nối được tới trợ lý cloud.'),
    );
    final responder = AssistantResponder(engine: engine, llmClient: llm);

    final reply = await responder.respond(
      input: 'làm sao để tiết kiệm hiệu quả',
      settings: cloudSettings,
    );

    expect(reply.answeredByCloud, isFalse);
    expect(reply.text, contains('Không dùng được trợ lý cloud'));
    expect(reply.blocks.whereType<NoteBlock>(), isNotEmpty);
  });

  test('never calls the cloud when settings are incomplete', () async {
    final llm = _RecordingLlmClient();
    final responder = AssistantResponder(engine: engine, llmClient: llm);

    final reply = await responder.respond(
      input: 'làm sao để tiết kiệm hiệu quả',
      settings: const AssistantSettings(),
    );

    expect(llm.received, isNull);
    expect(reply.text, contains('chưa hiểu ý này'));
  });

  test('includes recent conversation turns in the cloud prompt', () async {
    final llm = _RecordingLlmClient();
    final responder = AssistantResponder(engine: engine, llmClient: llm);
    final history = [
      ChatMessage(
        id: 'm1',
        role: ChatRole.user,
        text: 'tháng này tôi tiêu bao nhiêu?',
        createdAt: now,
      ),
      ChatMessage(
        id: 'm2',
        role: ChatRole.assistant,
        text: 'Bạn đã chi 50.000đ.',
        createdAt: now,
      ),
    ];

    await responder.respond(
      input: 'vậy có nên cắt giảm gì không',
      settings: cloudSettings,
      history: history,
    );

    final roles = llm.received!.map((item) => item.role).toList();
    expect(roles, ['system', 'user', 'assistant', 'user']);
  });
}
