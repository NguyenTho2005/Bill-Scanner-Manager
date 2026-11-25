import 'dart:async';
import 'dart:convert';

import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/services/llm_client.dart';
import 'package:http/http.dart' as http;

/// Calls the Google Gemini `generateContent` endpoint with a user key.
///
/// Used only when the user explicitly enables cloud mode and selects Gemini in
/// assistant settings. The key is read from secure storage and sent through
/// the `x-goog-api-key` header, never logged.
class GeminiLlmClient implements LlmClient {
  /// Creates the client with an optional [httpClient] for testing.
  GeminiLlmClient({
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 40),
  }) : _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Request timeout.
  final Duration timeout;

  /// Upper bound for the generated answer.
  static const _maxOutputTokens = 1024;

  @override
  Future<String> complete({
    required AssistantSettings settings,
    required List<LlmMessage> messages,
  }) async {
    if (!settings.isUsable) {
      throw const LlmException('Chưa cấu hình API key cho trợ lý cloud.');
    }

    final systemParts = <String>[];
    final contents = <Map<String, dynamic>>[];

    for (final message in messages) {
      if (message.role == 'system') {
        systemParts.add(message.content);
        continue;
      }
      contents.add({
        'role': message.role == 'assistant' ? 'model' : 'user',
        'parts': [
          {'text': message.content},
        ],
      });
    }

    final body = jsonEncode({
      if (systemParts.isNotEmpty)
        'systemInstruction': {
          'parts': [
            {'text': systemParts.join('\n\n')},
          ],
        },
      'contents': contents,
      'generationConfig': {
        'temperature': settings.temperature,
        'maxOutputTokens': _maxOutputTokens,
      },
    });

    http.Response response;
    try {
      response = await _http
          .post(
            settings.geminiGenerateContentUri,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': settings.apiKey,
            },
            body: body,
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const LlmException('Trợ lý Gemini phản hồi quá lâu.');
    } on Object {
      throw const LlmException('Không kết nối được tới Gemini.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LlmException(
        'Gemini trả về lỗi ${response.statusCode}. '
        'Kiểm tra lại model và API key.',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const LlmException('Phản hồi của Gemini không hợp lệ.');
      }

      final candidates = decoded['candidates'];
      if (candidates is! List || candidates.isEmpty) {
        throw LlmException(_emptyReplyMessage(decoded));
      }

      final first = candidates.first;
      if (first is! Map<String, dynamic>) {
        throw const LlmException('Phản hồi của Gemini không hợp lệ.');
      }

      final text = _extractText(first);
      if (text.isNotEmpty) {
        return text;
      }

      final finishReason = first['finishReason'];
      throw LlmException(
        finishReason is String && finishReason != 'STOP'
            ? 'Gemini dừng phản hồi ($finishReason).'
            : 'Gemini trả về nội dung rỗng.',
      );
    } on FormatException {
      throw const LlmException('Không đọc được phản hồi của Gemini.');
    }
  }

  String _extractText(Map<String, dynamic> candidate) {
    final content = candidate['content'];
    final parts = content is Map<String, dynamic> ? content['parts'] : null;
    if (parts is! List) return '';

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is! Map<String, dynamic>) continue;
      final text = part['text'];
      if (text is! String || text.trim().isEmpty) continue;
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(text.trim());
    }
    return buffer.toString().trim();
  }

  String _emptyReplyMessage(Map<String, dynamic> decoded) {
    final feedback = decoded['promptFeedback'];
    final blockReason =
        feedback is Map<String, dynamic> ? feedback['blockReason'] : null;
    if (blockReason is String && blockReason.isNotEmpty) {
      return 'Gemini đã chặn câu hỏi ($blockReason).';
    }
    return 'Gemini trả về nội dung rỗng.';
  }
}
