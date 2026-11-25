import 'package:bill_tracker/features/assistant/domain/entities/assistant_block.dart';
import 'package:equatable/equatable.dart';

/// What the assistant wants to show after handling a user message.
class AssistantReply extends Equatable {
  /// Creates an [AssistantReply].
  const AssistantReply({
    required this.text,
    this.blocks = const [],
    this.suggestions = const [],
    this.answeredByCloud = false,
    this.isFeedback = false,
  });

  /// Plain text answer.
  final String text;

  /// Rich blocks rendered under the text.
  final List<AssistantBlock> blocks;

  /// Follow-up chips offered to the user.
  final List<String> suggestions;

  /// True when a third-party LLM produced the text.
  final bool answeredByCloud;

  /// True when this reply acknowledges locally stored feedback.
  final bool isFeedback;

  /// Returns a copy with selected fields replaced.
  AssistantReply copyWith({
    String? text,
    List<AssistantBlock>? blocks,
    List<String>? suggestions,
    bool? answeredByCloud,
    bool? isFeedback,
  }) {
    return AssistantReply(
      text: text ?? this.text,
      blocks: blocks ?? this.blocks,
      suggestions: suggestions ?? this.suggestions,
      answeredByCloud: answeredByCloud ?? this.answeredByCloud,
      isFeedback: isFeedback ?? this.isFeedback,
    );
  }

  @override
  List<Object?> get props =>
      [text, blocks, suggestions, answeredByCloud, isFeedback];
}
