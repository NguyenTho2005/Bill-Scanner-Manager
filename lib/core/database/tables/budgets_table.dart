import 'package:drift/drift.dart';

/// Budgets table definition for category spending limits and alerts.
@DataClassName('BudgetRow')
class Budgets extends Table {
  /// Unique identifier.
  TextColumn get id => text()();

  /// Foreign key to Categories.id.
  TextColumn get categoryId => text()();

  /// Optional household ID for shared family budgets.
  TextColumn get householdId => text().nullable()();

  /// Budget period: 'monthly', 'weekly', 'custom'.
  TextColumn get period => text().withDefault(const Constant('monthly'))();

  /// Spending limit amount.
  RealColumn get amountLimit => real()();

  /// Comma-separated list of alert thresholds (e.g. "0.8,1.0,1.2").
  TextColumn get alertThresholds =>
      text().withDefault(const Constant('0.8,1.0,1.2'))();

  /// Whether the 80% alert has already been sent for this cycle.
  BoolColumn get alertSentAt80 =>
      boolean().withDefault(const Constant(false))();

  /// Whether the 100% alert has already been sent for this cycle.
  BoolColumn get alertSentAt100 =>
      boolean().withDefault(const Constant(false))();

  /// Whether the 120% critical alert has already been sent for this cycle
  /// (§4.6 #16).
  BoolColumn get alertSentAt120 =>
      boolean().withDefault(const Constant(false))();

  /// Start timestamp of current budget period.
  DateTimeColumn get periodStart => dateTime()();

  /// End timestamp of current budget period.
  DateTimeColumn get periodEnd => dateTime()();

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
