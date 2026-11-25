import 'package:drift/drift.dart';

/// Cached household membership table for shared budgets & creator attribution.
@DataClassName('HouseholdMemberRow')
class HouseholdMembers extends Table {
  /// Household identifier.
  TextColumn get householdId => text()();

  /// Household display name (denormalized for offline display).
  TextColumn get householdName => text().withDefault(const Constant(''))();

  /// Member user ID.
  TextColumn get userId => text()();

  /// Role within household: 'owner' or 'member'.
  TextColumn get role => text().withDefault(const Constant('member'))();

  /// Member display name shown on shared transactions.
  TextColumn get displayName => text().nullable()();

  /// Timestamp when member joined.
  DateTimeColumn get joinedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {householdId, userId};
}
