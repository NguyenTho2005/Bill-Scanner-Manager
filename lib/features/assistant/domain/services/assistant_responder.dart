import 'package:bill_tracker/features/assistant/domain/entities/assistant_block.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_reply.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/entities/chat_message.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_engine.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_nlu.dart';
import 'package:bill_tracker/features/assistant/domain/services/llm_client.dart';

/// Turns a user message into an [AssistantReply].
///
/// Structured questions ("tổng chi tháng này", "cà phê 45k") are always
/// answered on-device so the numbers stay exact and no data leaves the phone.
/// Only messages the local NLU cannot classify are forwarded to the optional
/// cloud LLM, and only when the user enabled it explicitly.
class AssistantResponder {
  /// Creates the responder.
  AssistantResponder({
    required AssistantEngine engine,
    required LlmClient llmClient,
  })  : _engine = engine,
        _llm = llmClient;

  final AssistantEngine _engine;
  final LlmClient _llm;

  /// Maximum number of previous turns forwarded to the cloud model.
  static const _historyWindow = 8;

  /// Produces a reply for [input].
  Future<AssistantReply> respond({
    required String input,
    required AssistantSettings settings,
    List<ChatMessage> history = const [],
  }) async {
    final query = await _engine.understand(input);

    if (query.intent != AssistantIntent.unknown) {
      return _engine.respondTo(query);
    }

    if (!settings.isUsable) {
      return _engine.respondTo(query);
    }

    try {
      final snapshot = await _engine.buildSnapshot();
      final text = await _llm.complete(
        settings: settings,
        messages: _buildMessages(input, snapshot, history),
      );
      return AssistantReply(
        text: text,
        answeredByCloud: true,
        suggestions: const [
          'Tháng này tôi tiêu bao nhiêu?',
          'Chi tiêu theo danh mục',
        ],
      );
    } on LlmException catch (error) {
      final local = await _engine.respondTo(query);
      return local.copyWith(
        text:
            '${local.text}\n\n(Không dùng được trợ lý cloud: ${error.message})',
        blocks: [
          ...local.blocks,
          NoteBlock(text: error.message, tone: NoteTone.warning),
        ],
      );
    }
  }

  List<LlmMessage> _buildMessages(
    String input,
    FinancialSnapshot snapshot,
    List<ChatMessage> history,
  ) {
    final system = StringBuffer()
      ..writeln('Bạn là trợ lý tài chính cá nhân trong ứng dụng BillTracker.')
      ..writeln('Chỉ dùng số liệu trong phần DỮ LIỆU NGƯỜI DÙNG bên dưới, '
          'không được bịa con số.')
      ..writeln('Trả lời bằng tiếng Việt, ngắn gọn (tối đa 120 từ), '
          'văn bản thuần (không markdown, không bảng).')
      ..writeln('Nếu dữ liệu không đủ để trả lời, nói rõ là chưa có dữ liệu '
          'và gợi ý cách ghi thêm giao dịch.')
      ..writeln('Không nhắc tới việc bạn là mô hình ngôn ngữ.')
      ..writeln()
      ..writeln('DỮ LIỆU NGƯỜI DÙNG:')
      ..write(snapshot.text);

    final messages = <LlmMessage>[
      LlmMessage(role: 'system', content: '$system'),
    ];

    final recent = history
        .where((message) => message.status == ChatMessageStatus.sent)
        .toList();
    final window = recent.length <= _historyWindow
        ? recent
        : recent.sublist(recent.length - _historyWindow);
    for (final message in window) {
      messages.add(
        LlmMessage(
          role: message.isUser ? 'user' : 'assistant',
          content: message.text,
        ),
      );
    }
    messages.add(LlmMessage(role: 'user', content: input));
    return messages;
  }
}
