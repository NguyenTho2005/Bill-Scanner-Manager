import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart';
import 'package:bill_tracker/features/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:bill_tracker/features/assistant/data/services/assistant_settings_store.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_block.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/entities/chat_message.dart';
import 'package:bill_tracker/features/assistant/domain/entities/transaction_draft.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemorySettingsStore implements AssistantSettingsStore {
  AssistantSettings current = const AssistantSettings();

  @override
  Future<AssistantSettings> load() async => current;

  @override
  Future<void> save(AssistantSettings settings) async => current = settings;
}

void main() {
  late AppDatabase db;
  late AssistantRepositoryImpl repository;
  late _MemorySettingsStore store;

  setUp(() {
    db = DatabaseConnection.inMemory();
    store = _MemorySettingsStore();
    repository = AssistantRepositoryImpl(db: db, settingsStore: store);
  });

  tearDown(() async {
    await db.close();
  });

  ChatMessage message(String id, ChatRole role, String text, int minute) {
    return ChatMessage(
      id: id,
      role: role,
      text: text,
      createdAt: DateTime(2026, 11, 24, 9, minute),
    );
  }

  test('starts with an empty history and offline settings', () async {
    expect(await repository.loadHistory(), isEmpty);
    expect((await repository.loadSettings()).cloudEnabled, isFalse);
  });

  test('persists messages in chronological order', () async {
    await repository.saveMessage(message('m2', ChatRole.assistant, 'Chào', 2));
    await repository.saveMessage(message('m1', ChatRole.user, 'Hi', 1));
    await repository.saveMessage(message('m3', ChatRole.user, 'Tiêu gì?', 3));

    final history = await repository.loadHistory();

    expect(history.map((item) => item.id), ['m1', 'm2', 'm3']);
    expect(history.first.isUser, isTrue);
  });

  test('round-trips blocks, suggestions and flags', () async {
    final original = ChatMessage(
      id: 'm1',
      role: ChatRole.assistant,
      text: 'Tổng quan',
      createdAt: DateTime(2026, 11, 24, 9, 30),
      blocks: const [
        MetricBlock(
          title: 'Tổng quan',
          rows: [MetricRow(label: 'Tổng chi', value: '100.000đ')],
        ),
        NoteBlock(text: 'Ghi chú', tone: NoteTone.warning),
      ],
      suggestions: const ['Top 5 khoản chi'],
      isLocal: false,
    );

    await repository.saveMessage(original);
    final restored = (await repository.loadHistory()).single;

    expect(restored.text, 'Tổng quan');
    expect(restored.isLocal, isFalse);
    expect(restored.suggestions, ['Top 5 khoản chi']);
    expect(restored.blocks, hasLength(2));
    expect(restored.blocks.first, isA<MetricBlock>());
    expect(restored.blocks.last, isA<NoteBlock>());
  });

  test('updates an existing message in place', () async {
    final draftBlock = DraftBlock(
      draft: TransactionDraft(
        amount: 45000,
        categoryId: 'food_drinks',
        categoryName: 'Ăn uống',
        occurredAt: DateTime(2026, 11, 24, 9, 30),
        note: 'Cà phê',
      ),
    );
    final original = ChatMessage(
      id: 'm1',
      role: ChatRole.assistant,
      text: 'Lưu nhé?',
      createdAt: DateTime(2026, 11, 24, 9, 30),
      blocks: [draftBlock],
    );
    await repository.saveMessage(original);

    final updated = original.copyWith(
      blocks: [draftBlock.copyWith(state: DraftState.created)],
    );
    await repository.saveMessage(updated);

    final restored = (await repository.loadHistory()).single;
    expect(restored.blocks.single, isA<DraftBlock>());
    expect(
      (restored.blocks.single as DraftBlock).state,
      DraftState.created,
    );
  });

  test('clears the whole conversation', () async {
    await repository.saveMessage(message('m1', ChatRole.user, 'Hi', 1));
    await repository.clearHistory();
    expect(await repository.loadHistory(), isEmpty);
  });

  test('delegates settings persistence to the store', () async {
    await repository.saveSettings(
      const AssistantSettings(cloudEnabled: true, apiKey: 'abc'),
    );
    expect(store.current.cloudEnabled, isTrue);
    expect((await repository.loadSettings()).apiKey, 'abc');
  });
}
