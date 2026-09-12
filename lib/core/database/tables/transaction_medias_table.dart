import 'package:drift/drift.dart';

/// Transaction media table for associated photos (product photos, receipts).
@DataClassName('TransactionMediaRow')
class TransactionMedias extends Table {
  /// Unique identifier.
  TextColumn get id => text()();

  /// Foreign key to Transactions.id.
  TextColumn get transactionId => text()();

  /// Media type: 'product', 'receipt', 'screenshot'.
  TextColumn get type => text()();

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

  @override
  Set<Column> get primaryKey => {id};
}
