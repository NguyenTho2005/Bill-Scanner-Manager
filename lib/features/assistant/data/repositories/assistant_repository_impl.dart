import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/features/assistant/data/services/assistant_settings_store.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/entities/chat_message.dart';
import 'package:bill_tracker/features/assistant/domain/repositories/assistant_repository.dart';
import 'package:drift/drift.dart';

/// Drift-backed implementation of [AssistantRepository].
class AssistantRepositoryImpl implements AssistantRepository {
  /// Creates the repository.
  AssistantRepositoryImpl({
    required AppDatabase db,
    required AssistantSettingsStore settingsStore,
  })  : _db = db,
        _settingsStore = settingsStore;

  final AppDatabase _db;
  final AssistantSettingsStore _settingsStore;

  @override
  Future<List<ChatMessage>> loadHistory({int limit = 200}) async {
    final query = (_db.select(_db.chatMessages)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)])
      ..limit(limit));
    final rows = await query.get();
    return rows.reversed.map(_toEntity).toList();
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    await _db.into(_db.chatMessages).insertOnConflictUpdate(
          ChatMessagesCompanion(
            id: Value(message.id),
            role: Value(message.role.name),
            body: Value(message.text),
            blocksJson: Value(message.encodeBlocks()),
            suggestionsJson: Value(message.encodeSuggestions()),
            isLocal: Value(message.isLocal),
            isFeedback: Value(message.isFeedback),
            createdAt: Value(message.createdAt),
          ),
        );
  }

  @override
  Future<void> clearHistory() async {
    await _db.delete(_db.chatMessages).go();
  }

  @override
  Future<AssistantSettings> loadSettings() => _settingsStore.load();

  @override
  Future<void> saveSettings(AssistantSettings settings) =>
      _settingsStore.save(settings);

  ChatMessage _toEntity(ChatMessageRow row) {
    return ChatMessage(
      id: row.id,
      role: row.role == ChatRole.user.name ? ChatRole.user : ChatRole.assistant,
      text: row.body,
      createdAt: row.createdAt,
      blocks: ChatMessage.decodeBlocks(row.blocksJson),
      suggestions: ChatMessage.decodeSuggestions(row.suggestionsJson),
      isLocal: row.isLocal,
      isFeedback: row.isFeedback,
    );
  }
}
