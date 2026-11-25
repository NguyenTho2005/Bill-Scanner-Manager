import 'package:bill_tracker/core/database/converters/snake_case_converters.dart';
import 'package:drift/drift.dart';

/// Transactions table definition for Drift.
@DataClassName('TransactionRow')
class Transactions extends Table {
  /// Unique identifier (ULID / UUID v7).
  TextColumn get id => text()();

  /// Transaction type: 'expense' or 'income' (snake_case via converter, A.1.1).
  TextColumn get type => text().map(const TransactionTypeConverter())();

  /// Monetary amount.
  RealColumn get amount => real()();

  /// Currency code (e.g. 'VND').
  TextColumn get currency => text().withDefault(const Constant('VND'))();

  /// Foreign key to Categories.id.
  TextColumn get categoryId => text()();

  /// Merchant or store name (e.g. "Highlands Coffee").
  TextColumn get merchant => text().nullable()();

  /// Timestamp when the transaction took place.
  DateTimeColumn get occurredAt => dateTime()();

  /// Optional user notes.
  TextColumn get note => text().nullable()();

  /// Payment method (snake_case via converter, A.1.1).
  TextColumn get paymentMethod =>
      text().nullable().map(const PaymentMethodConverter())();

  /// Source (snake_case via converter, A.1.1).
  TextColumn get source => text().map(const TransactionSourceConverter())();

  /// Status (snake_case via converter, A.1.1).
  TextColumn get status => text().map(const TransactionStatusConverter())();

  /// Creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  /// Last updated timestamp.
  DateTimeColumn get updatedAt => dateTime()();

  /// Revision number used by the cloud sync protocol (B.1).
  IntColumn get revision => integer().withDefault(const Constant(0))();

  /// Soft-delete timestamp used by cloud sync (B.1).
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Sync state of this row (synced | pending | conflict, B.1).
  TextColumn get syncState => text().withDefault(const Constant('synced'))();

  /// Last successful sync time (B.1).
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Privacy opt-in flag: only shared transactions are visible to household.
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();

  /// Optional household ID when [isShared] is true.
  TextColumn get householdId => text().nullable()();

  /// Creator user ID populated by server for shared transactions.
  TextColumn get createdByUserId => text().nullable()();

  /// Creator display name populated for shared transactions.
  TextColumn get createdByName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
