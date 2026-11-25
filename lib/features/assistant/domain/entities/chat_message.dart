import 'dart:convert';

import 'package:bill_tracker/features/assistant/domain/entities/assistant_block.dart';
import 'package:equatable/equatable.dart';

/// Author of a chat message.
enum ChatRole {
  /// The person using the app.
  user,

  /// The in-app assistant.
  assistant,
}

/// Delivery state of a message.
enum ChatMessageStatus {
  /// Waiting for a reply / still being written.
  sending,

  /// Stored and rendered normally.
  sent,

  /// Something went wrong while answering.
  failed,
}

/// One persisted turn of the assistant conversation.
class ChatMessage extends Equatable {
  /// Creates a [ChatMessage].
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.status = ChatMessageStatus.sent,
    this.blocks = const [],
    this.suggestions = const [],
    this.isLocal = true,
    this.isFeedback = false,
  });

  /// Unique identifier (UUID v7).
  final String id;

  /// Who wrote the message.
  final ChatRole role;

  /// Plain text body.
  final String text;

  /// Timestamp used for ordering and display.
  final DateTime createdAt;

  /// Delivery state.
  final ChatMessageStatus status;

  /// Rich content blocks rendered under the text.
  final List<AssistantBlock> blocks;

  /// Follow-up prompt chips.
  final List<String> suggestions;

  /// True when no network request was involved.
  final bool isLocal;

  /// True when a user message was filed as support feedback.
  final bool isFeedback;

  /// Whether this message came from the user.
  bool get isUser => role == ChatRole.user;

  /// Returns a copy with selected fields replaced.
  ChatMessage copyWith({
    String? text,
    DateTime? createdAt,
    ChatMessageStatus? status,
    List<AssistantBlock>? blocks,
    List<String>? suggestions,
    bool? isLocal,
    bool? isFeedback,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      blocks: blocks ?? this.blocks,
      suggestions: suggestions ?? this.suggestions,
      isLocal: isLocal ?? this.isLocal,
      isFeedback: isFeedback ?? this.isFeedback,
    );
  }

  /// Serialized blocks for the `blocks_json` column.
  String encodeBlocks() => jsonEncode(
        blocks.map((block) => block.toJson()).toList(),
      );

  /// Serialized suggestions for the `suggestions_json` column.
  String encodeSuggestions() => jsonEncode(suggestions);

  /// Decodes a stored `blocks_json` value, ignoring malformed entries.
  static List<AssistantBlock> decodeBlocks(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(AssistantBlock.fromJson)
          .whereType<AssistantBlock>()
          .toList();
    } on FormatException {
      return const [];
    }
  }

  /// Decodes a stored `suggestions_json` value.
  static List<String> decodeSuggestions(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.whereType<String>().toList();
    } on FormatException {
      return const [];
    }
  }

  @override
  List<Object?> get props => [
        id,
        role,
        text,
        createdAt,
        status,
        blocks,
        suggestions,
        isLocal,
        isFeedback,
      ];
}
