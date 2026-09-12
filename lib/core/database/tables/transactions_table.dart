import 'package:drift/drift.dart';

/// Transactions table definition for Drift.
@DataClassName('TransactionRow')
class Transactions extends Table {
  /// Unique identifier (ULID / UUID v7).
  TextColumn get id => text()();

  /// Transaction type: 'expense' or 'income'.
  TextColumn get type => text()();

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

  /// Payment method: 'cash', 'card', 'transfer', 'ewallet', 'other'.
  TextColumn get paymentMethod => text().nullable()();

  /// Source: 'product_snap', 'receipt_scan', 'manual', 'import'.
  TextColumn get source => text()();

  /// Status: 'draft', 'confirmed', 'needs_review', 'failed'.
  TextColumn get status => text()();

  /// Creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  /// Last updated timestamp.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
