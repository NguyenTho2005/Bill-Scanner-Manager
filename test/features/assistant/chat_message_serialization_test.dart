import 'package:bill_tracker/features/assistant/domain/entities/assistant_block.dart';
import 'package:bill_tracker/features/assistant/domain/entities/chat_message.dart';
import 'package:bill_tracker/features/assistant/domain/entities/transaction_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final draft = TransactionDraft(
    amount: 45000,
    categoryId: 'food_drinks',
    categoryName: 'Ăn uống',
    occurredAt: DateTime(2026, 11, 24, 9, 30),
    note: 'Cà phê',
  );

  test('round-trips every block type through JSON', () {
    final blocks = <AssistantBlock>[
      const MetricBlock(
        title: 'Tổng quan',
        rows: [
          MetricRow(
            label: 'Tổng chi',
            value: '45.000đ',
            hint: '1 giao dịch',
          ),
        ],
      ),
      TransactionsBlock(
        items: [
          TransactionPreview(
            id: 'tx_1',
            amount: 45000,
            occurredAt: DateTime(2026, 11, 24),
            categoryName: 'Ăn uống',
            categoryColorValue: 0xFFFF6B35,
            note: 'Cà phê',
          ),
        ],
        totalAmount: 45000,
      ),
      DraftBlock(draft: draft),
      const NoteBlock(
        text: 'Chẩn đoán',
        tone: NoteTone.warning,
        copyable: true,
      ),
    ];

    final message = ChatMessage(
      id: 'm_1',
      role: ChatRole.assistant,
      text: 'Xin chào',
      createdAt: DateTime(2026, 11, 24, 9, 31),
      blocks: blocks,
      suggestions: const ['Top 5 khoản chi'],
    );

    final decoded = ChatMessage.decodeBlocks(message.encodeBlocks());
    expect(decoded, hasLength(4));

    final metrics = decoded[0] as MetricBlock;
    expect(metrics.rows.first.value, '45.000đ');

    final list = decoded[1] as TransactionsBlock;
    expect(list.items.single.amount, 45000);
    expect(list.totalAmount, 45000);

    final draftBlock = decoded[2] as DraftBlock;
    expect(draftBlock.draft, draft);

    final note = decoded[3] as NoteBlock;
    expect(note.tone, NoteTone.warning);
    expect(note.copyable, isTrue);

    expect(
      ChatMessage.decodeSuggestions(message.encodeSuggestions()),
      ['Top 5 khoản chi'],
    );
  });

  test('survives malformed stored JSON', () {
    expect(ChatMessage.decodeBlocks('not-json'), isEmpty);
    expect(ChatMessage.decodeBlocks(null), isEmpty);
    expect(ChatMessage.decodeSuggestions('{}'), isEmpty);
  });

  test('marks a created draft state and keeps the payload', () {
    final block = DraftBlock(draft: draft);
    final created = block.copyWith(state: DraftState.created);

    final restored = DraftBlock.fromJson(created.toJson());
    expect(restored.state, DraftState.created);
    expect(restored.draft.amount, 45000);
  });
}
