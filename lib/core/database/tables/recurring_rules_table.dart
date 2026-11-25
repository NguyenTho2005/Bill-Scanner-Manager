import 'package:bill_tracker/core/database/converters/snake_case_converters.dart';
import 'package:drift/drift.dart';

/// Recurring rules table (local MVP, schema v5).
@DataClassName('RecurringRuleRow')
class RecurringRules extends Table {

  /// Unique identifier (ULID / UUID v7).
  TextColumn get id => text()();

  /// Amount per occurrence (money).
  RealColumn get amount => real()();

  /// Expense or income (snake_case via converter, A.1.1).
  TextColumn get type => text().map(const TransactionTypeConverter())();

  /// Currency code.
  TextColumn get currency => text().withDefault(const Constant('VND'))();

  /// Foreign key to Categories.id (template).
  TextColumn get categoryId => text()();

  /// Optional merchant / store name.
  TextColumn get merchant => text().nullable()();

  /// Optional note / description.
  TextColumn get note => text().nullable()();

  /// Frequency: 'daily', 'weekly', 'monthly' (converter, domain enum).
  TextColumn get frequency => text().map(const RecurringFrequencyConverter())();

  /// Day of month for monthly rules (1-28/31).
  IntColumn get dayOfMonth => integer().nullable()();

  /// Weekday for weekly rules (Dart DateTime.weekday, Monday=1).
  IntColumn get dayOfWeek => integer().nullable()();

  /// First day the rule may fire.
  DateTimeColumn get startDate => dateTime()();

  /// Optional last day after which the rule stops.
  DateTimeColumn get endDate => dateTime().nullable()();

  /// Next scheduled fire time.
  DateTimeColumn get nextRunAt => dateTime()();

  /// Active flag (toggle in UI).
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();

  /// Creation timestamp.
  DateTimeColumn get createdAt =>
      dateTime().withDefault(Constant(DateTime.now()))();

  @override
  Set<Column> get primaryKey => {id};
}
