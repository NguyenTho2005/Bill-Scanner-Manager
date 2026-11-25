import 'package:drift/drift.dart';

/// Key-value store for sync protocol metadata (B.1) — e.g. server cursor,
/// last device registration. Values are JSON strings; P3 will consume these.
@DataClassName('SyncMetadataRow')
class SyncMetadata extends Table {
  /// Key (e.g. 'server_cursor', 'device_id').
  TextColumn get key => text()();

  /// Value as JSON string.
  TextColumn get value => text().withDefault(const Constant(''))();
}
