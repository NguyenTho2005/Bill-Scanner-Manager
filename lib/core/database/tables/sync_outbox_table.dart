import 'package:drift/drift.dart';

/// Staging table for pending sync operations (P3 will read/process these).
/// Schema is prepared now (B); repository logic lands in a later phase.
@DataClassName('SyncOutboxRow')
class SyncOutbox extends Table {
  /// Unique operation id (ULID) — immutable across retries.
  TextColumn get id => text()();

  /// Entity type, e.g. 'transaction' (shared constants, see sync protocol).
  TextColumn get entityType => text()();

  /// Entity primary key.
  TextColumn get entityId => text()();

  /// 'upsert' or 'delete'.
  TextColumn get operation => text()();

  /// Serialized JSON payload.
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();

  /// Local time the row was queued.
  DateTimeColumn get createdAt => dateTime()();

  /// Retry counter; reset on successful push.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}
