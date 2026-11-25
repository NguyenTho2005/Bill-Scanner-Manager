import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';

/// One turn sent to a chat-completions style API.
class LlmMessage {
  /// Creates an [LlmMessage].
  const LlmMessage({required this.role, required this.content});

  /// `system`, `user` or `assistant`.
  final String role;

  /// Plain text content.
  final String content;

  /// JSON-serializable representation.
  Map<String, String> toJson() => {'role': role, 'content': content};
}

/// Failure while talking to the third-party LLM provider.
class LlmException implements Exception {
  /// Creates an [LlmException] with a user-safe [message].
  const LlmException(this.message);

  /// Message that never contains the API key.
  final String message;

  @override
  String toString() => 'LlmException: $message';
}

/// Minimal abstraction over any OpenAI-compatible chat completion API.
// ignore: one_member_abstracts
abstract class LlmClient {
  /// Sends [messages] and returns the assistant's plain text answer.
  ///
  /// Throws [LlmException] on transport or provider errors.
  Future<String> complete({
    required AssistantSettings settings,
    required List<LlmMessage> messages,
  });
}
