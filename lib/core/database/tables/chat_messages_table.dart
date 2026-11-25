import 'package:drift/drift.dart';

/// Local chat history for the in-app assistant.
///
/// Everything is stored on-device; cloud AI is strictly opt-in and never
/// required for this table to work.
@DataClassName('ChatMessageRow')
class ChatMessages extends Table {
  /// Unique identifier (UUID v7).
  TextColumn get id => text()();

  /// Message author: 'user' or 'assistant'.
  TextColumn get role => text()();

  /// Plain text body of the message.
  TextColumn get body => text()();

  /// JSON array of rich blocks (metrics, transactions, drafts, notes).
  TextColumn get blocksJson => text().withDefault(const Constant('[]'))();

  /// Suggested follow-up prompts shown as chips.
  TextColumn get suggestionsJson => text().withDefault(const Constant('[]'))();

  /// True when the reply was produced fully on-device.
  BoolColumn get isLocal => boolean().withDefault(const Constant(true))();

  /// True when the user message was filed as support feedback.
  BoolColumn get isFeedback => boolean().withDefault(const Constant(false))();

  /// Message timestamp.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
