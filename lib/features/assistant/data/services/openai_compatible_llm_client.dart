import 'dart:async';
import 'dart:convert';

import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/services/llm_client.dart';
import 'package:http/http.dart' as http;

/// Calls any OpenAI-compatible `/chat/completions` endpoint with a user key.
///
/// Used only when the user explicitly enables cloud mode in assistant
/// settings. The key is read from secure storage and never logged.
class OpenAiCompatibleLlmClient implements LlmClient {
  /// Creates the client with an optional [httpClient] for testing.
  OpenAiCompatibleLlmClient({
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 40),
  }) : _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Request timeout.
  final Duration timeout;

  @override
  Future<String> complete({
    required AssistantSettings settings,
    required List<LlmMessage> messages,
  }) async {
    if (!settings.isUsable) {
      throw const LlmException('Chưa cấu hình API key cho trợ lý cloud.');
    }

    final body = jsonEncode({
      'model': settings.model,
      'temperature': settings.temperature,
      'messages': messages.map((item) => item.toJson()).toList(),
    });

    http.Response response;
    try {
      response = await _http
          .post(
            settings.chatCompletionsUri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${settings.apiKey}',
            },
            body: body,
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const LlmException('Trợ lý cloud phản hồi quá lâu.');
    } on Object {
      throw const LlmException('Không kết nối được tới trợ lý cloud.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LlmException(
        'Trợ lý cloud trả về lỗi ${response.statusCode}. '
        'Kiểm tra lại endpoint, model và API key.',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const LlmException('Phản hồi của trợ lý cloud không hợp lệ.');
      }
      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) {
        throw const LlmException('Trợ lý cloud trả về nội dung rỗng.');
      }
      final first = choices.first;
      final message = first is Map<String, dynamic> ? first['message'] : null;
      final content =
          message is Map<String, dynamic> ? message['content'] : null;
      final text = (content as String?)?.trim() ?? '';
      if (text.isEmpty) {
        throw const LlmException('Trợ lý cloud trả về nội dung rỗng.');
      }
      return text;
    } on FormatException {
      throw const LlmException('Không đọc được phản hồi của trợ lý cloud.');
    }
  }
}
