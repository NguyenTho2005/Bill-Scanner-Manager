import 'package:bill_tracker/features/assistant/data/services/gemini_llm_client.dart';
import 'package:bill_tracker/features/assistant/data/services/openai_compatible_llm_client.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/services/llm_client.dart';

/// Routes each request to the client matching [AssistantSettings.provider].
class ProviderAwareLlmClient implements LlmClient {
  /// Creates the router with optional clients for testing.
  ProviderAwareLlmClient({
    LlmClient? openAiCompatible,
    LlmClient? gemini,
  })  : _openAiCompatible = openAiCompatible ?? OpenAiCompatibleLlmClient(),
        _gemini = gemini ?? GeminiLlmClient();

  final LlmClient _openAiCompatible;
  final LlmClient _gemini;

  @override
  Future<String> complete({
    required AssistantSettings settings,
    required List<LlmMessage> messages,
  }) {
    final client = switch (settings.provider) {
      AssistantCloudProvider.openAiCompatible => _openAiCompatible,
      AssistantCloudProvider.gemini => _gemini,
    };
    return client.complete(settings: settings, messages: messages);
  }
}
