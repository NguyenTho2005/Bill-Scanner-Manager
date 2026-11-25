import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/entities/chat_message.dart';

/// Persistence boundary for assistant chat history and configuration.
abstract class AssistantRepository {
  /// Loads the most recent [limit] messages in chronological order.
  Future<List<ChatMessage>> loadHistory({int limit = 200});

  /// Inserts or replaces a single message.
  Future<void> saveMessage(ChatMessage message);

  /// Deletes every stored message.
  Future<void> clearHistory();

  /// Loads assistant configuration (offline by default).
  Future<AssistantSettings> loadSettings();

  /// Persists assistant configuration.
  Future<void> saveSettings(AssistantSettings settings);
}
