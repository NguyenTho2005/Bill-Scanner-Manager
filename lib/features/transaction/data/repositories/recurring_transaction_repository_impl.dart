import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/features/transaction/domain/entities/recurring_rule.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/recurring_transaction_repository.dart';
import 'package:drift/drift.dart';

/// Drift implementation of [RecurringTransactionRepository].
class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  /// Creates [RecurringTransactionRepositoryImpl] with [AppDatabase].
  RecurringTransactionRepositoryImpl(this._db);

  final AppDatabase _db;

  static RecurringRule _mapRow(RecurringRuleRow row) {
    return RecurringRule(
      id: row.id,
      amount: row.amount,
      type: row.type,
      currency: row.currency,
      categoryId: row.categoryId,
      merchant: row.merchant,
      note: row.note,
      frequency: row.frequency,
      dayOfMonth: row.dayOfMonth,
      dayOfWeek: row.dayOfWeek,
      startDate: row.startDate,
      endDate: row.endDate,
      nextRunAt: row.nextRunAt,
      isActive: row.isActive,
      createdAt: row.createdAt,
    );
  }

  @override
  Future<List<RecurringRule>> watchAll() {
    return (_db.select(_db.recurringRules)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get()
        .then((rows) => rows.map(_mapRow).toList());
  }

  @override
  Future<List<RecurringRule>> getAll() {
    return watchAll();
  }

  @override
  Future<List<RecurringRule>> getDueRules(DateTime now) {
    return (_db.select(_db.recurringRules)
          ..where((t) => t.isActive & t.nextRunAt.isSmallerOrEqualValue(now)))
        .get()
        .then((rows) => rows.map(_mapRow).toList());
  }

  @override
  Future<RecurringRule?> getById(String id) {
    return (_db.select(_db.recurringRules)..where((t) => t.id.equals(id)))
        .getSingleOrNull()
        .then((row) => row == null ? null : _mapRow(row));
  }

  @override
  Future<void> save(RecurringRule rule) {
    return _db.into(_db.recurringRules).insert(_toCompanion(rule));
  }

  @override
  Future<void> update(RecurringRule rule) {
    return _db.update(_db.recurringRules).replace(_toCompanion(rule));
  }

  @override
  Future<void> setIsActive(String id, {required bool isActive}) async {
    await (_db.update(_db.recurringRules)..where((t) => t.id.equals(id)))
        .write(RecurringRulesCompanion(isActive: Value(isActive)));
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.recurringRules)..where((t) => t.id.equals(id))).go();
  }

  static RecurringRulesCompanion _toCompanion(RecurringRule rule) {
    return RecurringRulesCompanion(
      id: Value(rule.id),
      amount: Value(rule.amount),
      type: Value(rule.type),
      currency: Value(rule.currency),
      categoryId: Value(rule.categoryId),
      merchant: Value(rule.merchant),
      note: Value(rule.note),
      frequency: Value(rule.frequency),
      dayOfMonth: Value(rule.dayOfMonth),
      dayOfWeek: Value(rule.dayOfWeek),
      startDate: Value(rule.startDate),
      endDate: Value(rule.endDate),
      nextRunAt: Value(rule.nextRunAt),
      isActive: Value(rule.isActive),
      createdAt: Value(rule.effectiveCreatedAt),
    );
  }
}
