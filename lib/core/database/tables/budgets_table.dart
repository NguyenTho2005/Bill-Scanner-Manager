import 'package:drift/drift.dart';

/// Budgets table definition for category spending limits and alerts.
@DataClassName('BudgetRow')
class Budgets extends Table {
  /// Unique identifier.
  TextColumn get id => text()();

  /// Foreign key to Categories.id.
  TextColumn get categoryId => text()();

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

  /// Start timestamp of current budget period.
  DateTimeColumn get periodStart => dateTime()();

  /// End timestamp of current budget period.
  DateTimeColumn get periodEnd => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
