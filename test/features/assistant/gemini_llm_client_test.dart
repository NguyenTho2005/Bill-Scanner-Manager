import 'dart:convert';

import 'package:bill_tracker/features/assistant/data/services/gemini_llm_client.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/services/llm_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;

void main() {
  const settings = AssistantSettings(
    cloudEnabled: true,
    provider: AssistantCloudProvider.gemini,
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
    model: 'gemini-2.5-flash',
    apiKey: 'test-key',
  );

  test('builds the Gemini generateContent endpoint', () {
    expect(
      settings.geminiGenerateContentUri.toString(),
      'https://generativelanguage.googleapis.com/v1beta/'
      'models/gemini-2.5-flash:generateContent',
    );
  });

  test('sends a Gemini request and returns the reply text', () async {
    late http.Request request;
    final client = GeminiLlmClient(
      httpClient: http_testing.MockClient((captured) async {
        request = captured;
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'role': 'model',
                  'parts': [
                    {'text': 'Xin chào'},
                  ],
                },
                'finishReason': 'STOP',
              },
            ],
          }),
          200,
        );
      }),
    );

    final reply = await client.complete(
      settings: settings,
      messages: const [
        LlmMessage(role: 'system', content: 'Bạn là trợ lý.'),
        LlmMessage(role: 'user', content: 'Chào'),
      ],
    );

    expect(reply, 'Xin chào');
    expect(
      request.url.toString(),
      settings.geminiGenerateContentUri.toString(),
    );
    expect(request.headers['x-goog-api-key'], 'test-key');

    final body =
        jsonDecode(utf8.decode(request.bodyBytes)) as Map<String, dynamic>;
    final systemInstruction = body['systemInstruction'] as Map<String, dynamic>;
    final systemText =
        (systemInstruction['parts'] as List).first as Map<String, dynamic>;
    expect(systemText['text'], 'Bạn là trợ lý.');
    final contents = body['contents'] as List<dynamic>;
    expect(contents, hasLength(1));
    final first = contents.first as Map<String, dynamic>;
    expect(first['role'], 'user');
    final parts = first['parts'] as List<dynamic>;
    expect((parts.first as Map<String, dynamic>)['text'], 'Chào');
    final generationConfig = body['generationConfig'] as Map<String, dynamic>;
    expect(generationConfig['temperature'], 0.3);
    expect(generationConfig['maxOutputTokens'], 1024);
  });

  test('throws when the client is not usable', () async {
    const unusable = AssistantSettings(
      provider: AssistantCloudProvider.gemini,
      cloudEnabled: false,
    );
    final client = GeminiLlmClient();
    await expectLater(
      client.complete(settings: unusable, messages: const []),
      throwsA(isA<LlmException>()),
    );
  });

  test('maps the assistant role to Gemini "model"', () async {
    late http.Request request;
    final client = GeminiLlmClient(
      httpClient: http_testing.MockClient((captured) async {
        request = captured;
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'role': 'model',
                  'parts': [
                    {'text': 'ok'},
                  ],
                },
              },
            ],
          }),
          200,
        );
      }),
    );

    await client.complete(
      settings: settings,
      messages: const [
        LlmMessage(role: 'user', content: 'a'),
        LlmMessage(role: 'assistant', content: 'b'),
      ],
    );

    final body =
        jsonDecode(utf8.decode(request.bodyBytes)) as Map<String, dynamic>;
    final contents = body['contents'] as List<dynamic>;
    expect(contents, hasLength(2));
    expect(
      (contents.last as Map<String, dynamic>)['role'],
      'model',
    );
  });
}
