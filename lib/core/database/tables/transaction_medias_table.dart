import 'package:bill_tracker/core/database/converters/snake_case_converters.dart';
import 'package:drift/drift.dart';

/// Transaction media table for associated photos (product photos, receipts).
@DataClassName('TransactionMediaRow')
class TransactionMedias extends Table {
  /// Unique identifier.
  TextColumn get id => text()();

  /// Foreign key to Transactions.id.
  TextColumn get transactionId => text()();

  /// Media type (snake_case via converter, A.1.1).
  TextColumn get type => text().map(const MediaTypeConverter())();

  /// Local path to original image (nullable if user chose not to keep original).
  TextColumn get originalPath => text().nullable()();

  /// Local path to compressed image (max 2048px).
  TextColumn get compressedPath => text()();

  /// Local path to 200x200 square thumbnail.
  TextColumn get thumbnailPath => text()();

  /// SHA-256 hash of the image content for deduplication.
  TextColumn get hash => text()();

  /// Image width in pixels.
  IntColumn get width => integer().nullable()();

  /// Image height in pixels.
  IntColumn get height => integer().nullable()();

  /// File size in bytes.
  IntColumn get fileSizeBytes => integer().nullable()();

  /// Timestamp when photo was captured.
  DateTimeColumn get capturedAt => dateTime().nullable()();

  /// Revision number used by the cloud sync protocol (B.1).
  IntColumn get revision => integer().withDefault(const Constant(0))();

  /// Soft-delete timestamp used by cloud sync (B.1).
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Sync state of this row (synced | pending | conflict, B.1).
  TextColumn get syncState => text().withDefault(const Constant('synced'))();

  /// Last successful sync time (B.1).
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
