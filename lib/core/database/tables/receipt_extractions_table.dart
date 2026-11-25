import 'package:bill_tracker/core/database/converters/snake_case_converters.dart';
import 'package:drift/drift.dart';

/// Receipt extraction results table.
@DataClassName('ReceiptExtractionRow')
class ReceiptExtractions extends Table {
  /// Foreign key to Transactions.id (1-to-1 relationship, acts as PK).
  TextColumn get transactionId => text()();

  /// Extracted merchant name.
  TextColumn get merchant => text().nullable()();

  /// Confidence for merchant extraction.
  RealColumn get merchantConfidence => real().nullable()();

  /// Whether user manually edited the merchant field.
  BoolColumn get merchantUserEdited =>
      boolean().withDefault(const Constant(false))();

  /// Extracted transaction date.
  DateTimeColumn get transactionDate => dateTime().nullable()();

  /// Confidence for transaction date extraction.
  RealColumn get dateConfidence => real().nullable()();

  /// Extracted total amount.
  RealColumn get total => real().nullable()();

  /// Confidence for total amount extraction.
  RealColumn get totalConfidence => real().nullable()();

  /// Subtotal if extracted.
  RealColumn get subtotal => real().nullable()();

  /// Tax amount if extracted.
  RealColumn get tax => real().nullable()();

  /// Detected payment method (snake_case via converter, A.1.1).
  TextColumn get paymentMethod =>
      text().nullable().map(const PaymentMethodConverter())();

  /// Overall extraction confidence (0.0 to 1.0).
  RealColumn get overallConfidence => real()();

  /// Full raw OCR text.
  TextColumn get rawText => text().nullable()();

  /// Whether the extraction was flagged for human review (confidence < 0.70).
  BoolColumn get requiresReview =>
      boolean().withDefault(const Constant(false))();

  /// Revision number used by the cloud sync protocol (B.1).
  IntColumn get revision => integer().withDefault(const Constant(0))();

  /// Soft-delete timestamp used by cloud sync (B.1).
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Sync state of this row (synced | pending | conflict, B.1).
  TextColumn get syncState => text().withDefault(const Constant('synced'))();

  /// Last successful sync time (B.1).
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {transactionId};
}
