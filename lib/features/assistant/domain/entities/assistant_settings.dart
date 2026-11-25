import 'package:equatable/equatable.dart';

/// Cloud provider used by the optional AI assistant.
enum AssistantCloudProvider {
  /// Any endpoint compatible with the OpenAI Chat Completions API.
  openAiCompatible,

  /// Google Gemini API (`generativelanguage.googleapis.com`).
  gemini,
}

/// Runtime configuration for the optional cloud LLM assistant.
///
/// The default is fully offline: no message ever leaves the device unless the
/// user explicitly turns cloud mode on and provides an endpoint + key.
class AssistantSettings extends Equatable {
  /// Creates [AssistantSettings].
  const AssistantSettings({
    this.cloudEnabled = false,
    this.provider = AssistantCloudProvider.openAiCompatible,
    this.baseUrl = defaultBaseUrl,
    this.model = defaultModel,
    this.apiKey = '',
    this.temperature = 0.3,
  });

  /// Restores settings from JSON, falling back to defaults.
  factory AssistantSettings.fromJson(Map<String, dynamic> json) {
    return AssistantSettings(
      cloudEnabled: json['cloudEnabled'] as bool? ?? false,
      provider: _providerFromName(json['provider'] as String?),
      baseUrl: json['baseUrl'] as String? ?? defaultBaseUrl,
      model: json['model'] as String? ?? defaultModel,
      apiKey: json['apiKey'] as String? ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.3,
    );
  }

  /// Default endpoint compatible with the OpenAI Chat Completions API.
  static const defaultBaseUrl = 'https://api.openai.com/v1';

  /// Default model used when the user does not override it.
  static const defaultModel = 'gpt-4o-mini';

  /// Default endpoint for the Google Gemini API.
  static const defaultGeminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// Default Gemini model used when the user does not override it.
  static const defaultGeminiModel = 'gemini-2.5-flash';

  /// Default base URL for [provider].
  static String defaultBaseUrlFor(AssistantCloudProvider provider) {
    return switch (provider) {
      AssistantCloudProvider.openAiCompatible => defaultBaseUrl,
      AssistantCloudProvider.gemini => defaultGeminiBaseUrl,
    };
  }

  /// Default model for [provider].
  static String defaultModelFor(AssistantCloudProvider provider) {
    return switch (provider) {
      AssistantCloudProvider.openAiCompatible => defaultModel,
      AssistantCloudProvider.gemini => defaultGeminiModel,
    };
  }

  /// Whether free-form questions are forwarded to a third-party LLM.
  final bool cloudEnabled;

  /// Cloud provider that receives free-form questions.
  final AssistantCloudProvider provider;

  /// Base URL of the provider API.
  final String baseUrl;

  /// Model identifier.
  final String model;

  /// Bearer token. Stored in secure storage only.
  final String apiKey;

  /// Sampling temperature for creative answers.
  final double temperature;

  /// Whether credentials are complete enough to attempt a request.
  bool get isUsable =>
      cloudEnabled &&
      baseUrl.trim().isNotEmpty &&
      model.trim().isNotEmpty &&
      apiKey.trim().isNotEmpty;

  /// Builds the OpenAI chat completions endpoint from [baseUrl].
  Uri get chatCompletionsUri {
    final trimmed = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$trimmed/chat/completions');
  }

  /// Builds the Gemini `generateContent` endpoint from [baseUrl].
  Uri get geminiGenerateContentUri {
    final trimmed = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final modelId = model.trim().replaceFirst(RegExp('^models/'), '');
    return Uri.parse('$trimmed/models/$modelId:generateContent');
  }

  /// Returns a copy with selected fields replaced.
  AssistantSettings copyWith({
    bool? cloudEnabled,
    AssistantCloudProvider? provider,
    String? baseUrl,
    String? model,
    String? apiKey,
    double? temperature,
  }) {
    return AssistantSettings(
      cloudEnabled: cloudEnabled ?? this.cloudEnabled,
      provider: provider ?? this.provider,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
      temperature: temperature ?? this.temperature,
    );
  }

  /// JSON-serializable representation (never logged).
  Map<String, dynamic> toJson() => {
        'cloudEnabled': cloudEnabled,
        'provider': provider.name,
        'baseUrl': baseUrl,
        'model': model,
        'apiKey': apiKey,
        'temperature': temperature,
      };

  static AssistantCloudProvider _providerFromName(String? name) {
    for (final provider in AssistantCloudProvider.values) {
      if (provider.name == name) return provider;
    }
    return AssistantCloudProvider.openAiCompatible;
  }

  @override
  List<Object?> get props =>
      [cloudEnabled, provider, baseUrl, model, apiKey, temperature];
}
