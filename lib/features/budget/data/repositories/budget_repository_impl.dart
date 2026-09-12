import 'package:bill_tracker/core/analytics/analytics_service.dart';
import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/notifications/notification_service.dart';
import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/budget/domain/entities/category_budget_progress.dart';
import 'package:bill_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:bill_tracker/features/transaction/data/repositories/category_repository_impl.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:drift/drift.dart';

/// Drift implementation of [BudgetRepository].
class BudgetRepositoryImpl implements BudgetRepository {
  /// Creates [BudgetRepositoryImpl].
  BudgetRepositoryImpl({
    required AppDatabase db,
    required NotificationService notificationService,
    required AnalyticsService analyticsService,
  })  : _db = db,
        _notificationService = notificationService,
        _analyticsService = analyticsService;

  final AppDatabase _db;
  final NotificationService _notificationService;
  final AnalyticsService _analyticsService;

  @override
  Future<List<Budget>> getAllBudgets() async {
    final query = _db.select(_db.budgets).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.budgets.categoryId),
      ),
    ]);
    final rows = await query.get();
    return rows.map(_mapRowToBudget).toList();
  }

  @override
  Stream<List<Budget>> watchAllBudgets() {
    final query = _db.select(_db.budgets).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.budgets.categoryId),
      ),
    ]);
    return query.watch().map((rows) => rows.map(_mapRowToBudget).toList());
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final query = _db.select(_db.budgets).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.budgets.categoryId),
      ),
    ])
      ..where(_db.budgets.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRowToBudget(row);
  }

  @override
  Future<Budget?> getBudgetByCategoryId(String categoryId) async {
    final query = _db.select(_db.budgets).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.budgets.categoryId),
      ),
    ])
      ..where(_db.budgets.categoryId.equals(categoryId));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRowToBudget(row);
  }

  @override
  Stream<List<CategoryBudgetProgress>> watchBudgetProgressList({
    DateTime? month,
  }) {
    final targetMonth = month ?? DateTime.now();
    final periodStart = DateTime(targetMonth.year, targetMonth.month);
    final periodEnd = DateTime(targetMonth.year, targetMonth.month + 1)
        .subtract(const Duration(milliseconds: 1));

    final amountSum = _db.transactions.amount.sum();

    final query = _db.select(_db.budgets).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.budgets.categoryId),
      ),
      leftOuterJoin(
        _db.transactions,
        _db.transactions.categoryId.equalsExp(_db.budgets.categoryId) &
            _db.transactions.type.equals('expense') &
            _db.transactions.occurredAt.isBiggerOrEqualValue(periodStart) &
            _db.transactions.occurredAt.isSmallerOrEqualValue(periodEnd),
      ),
    ])
      ..addColumns([amountSum])
      ..groupBy([_db.budgets.id]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final budgetRow = row.readTable(_db.budgets);
        final categoryRow = row.readTable(_db.categories);
        final spent = row.read(amountSum) ?? 0.0;

        final category = categoryRow.toDomain();
        final budget = _budgetRowToEntity(budgetRow, category: category);

        return CategoryBudgetProgress(
          budget: budget,
          category: category,
          spentAmount: spent,
        );
      }).toList();
    });
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    final companion = budget.toCompanion();
    await _db.into(_db.budgets).insertOnConflictUpdate(companion);
    await _analyticsService.logEvent(
      AnalyticsEvents.budgetCreated,
      parameters: {
        'categoryId': budget.categoryId,
        'period': budget.period,
      },
    );
    await checkAndTriggerAlerts();
  }

  @override
  Future<void> deleteBudget(String id) async {
    await (_db.delete(_db.budgets)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> checkAndTriggerAlerts() async {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month);
    final currentMonthEnd = DateTime(now.year, now.month + 1)
        .subtract(const Duration(milliseconds: 1));

    final budgets = await getAllBudgets();

    for (final budget in budgets) {
      var activeBudget = budget;

      // Handle monthly rollover: reset flags if period ended
      if (budget.period == 'monthly' && budget.periodEnd.isBefore(now)) {
        activeBudget = budget.copyWith(
          periodStart: currentMonthStart,
          periodEnd: currentMonthEnd,
          alertSentAt80: false,
          alertSentAt100: false,
        );
        await _db.update(_db.budgets).replace(activeBudget.toCompanion());
      }

      // Compute spent amount in this active period
      final amountSum = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..addColumns([amountSum])
        ..where(
          _db.transactions.categoryId.equals(activeBudget.categoryId) &
              _db.transactions.type.equals('expense') &
              _db.transactions.occurredAt
                  .isBiggerOrEqualValue(activeBudget.periodStart) &
              _db.transactions.occurredAt
                  .isSmallerOrEqualValue(activeBudget.periodEnd),
        );

      final result = await query.getSingle();
      final spent = result.read(amountSum) ?? 0.0;
      final categoryName = activeBudget.category?.name ?? 'Ngân sách';
      final notifId = activeBudget.categoryId.hashCode.abs();

      // Check 100% exceeded threshold
      if (spent >= activeBudget.amountLimit && !activeBudget.alertSentAt100) {
        await _notificationService.showBudgetAlert(
          id: notifId,
          title: 'Vượt ngân sách: $categoryName',
          body:
              'Bạn đã chi ${spent.toVnd()}, vượt hạn mức ${activeBudget.amountLimit.toVnd()}!',
        );

        await _db.update(_db.budgets).replace(
              activeBudget
                  .copyWith(
                    alertSentAt80: true,
                    alertSentAt100: true,
                  )
                  .toCompanion(),
            );

        await _analyticsService.logEvent(
          AnalyticsEvents.budgetThresholdReached,
          parameters: {
            'categoryId': activeBudget.categoryId,
            'threshold': 1.0,
          },
        );
        await _analyticsService.logEvent(
          AnalyticsEvents.budgetExceeded,
          parameters: {
            'categoryId': activeBudget.categoryId,
          },
        );
        continue;
      }

      // Check 80% warning threshold
      if (spent >= (activeBudget.amountLimit * 0.8) &&
          !activeBudget.alertSentAt80) {
        await _notificationService.showBudgetAlert(
          id: notifId,
          title: 'Cảnh báo ngân sách: $categoryName',
          body:
              'Bạn đã chi ${spent.toVnd()} / ${activeBudget.amountLimit.toVnd()} (80% ngân sách).',
        );

        await _db.update(_db.budgets).replace(
              activeBudget
                  .copyWith(
                    alertSentAt80: true,
                  )
                  .toCompanion(),
            );

        await _analyticsService.logEvent(
          AnalyticsEvents.budgetThresholdReached,
          parameters: {
            'categoryId': activeBudget.categoryId,
            'threshold': 0.8,
          },
        );
      }
    }
  }

  Budget _mapRowToBudget(TypedResult row) {
    final budgetRow = row.readTable(_db.budgets);
    final categoryRow = row.readTableOrNull(_db.categories);
    return _budgetRowToEntity(budgetRow, category: categoryRow?.toDomain());
  }

  Budget _budgetRowToEntity(BudgetRow row, {Category? category}) {
    final thresholds = row.alertThresholds
        .split(',')
        .map((s) => double.tryParse(s.trim()) ?? 0.8)
        .toList();

    return Budget(
      id: row.id,
      categoryId: row.categoryId,
      period: row.period,
      amountLimit: row.amountLimit,
      alertThresholds: thresholds,
      alertSentAt80: row.alertSentAt80,
      alertSentAt100: row.alertSentAt100,
      periodStart: row.periodStart,
      periodEnd: row.periodEnd,
      category: category,
    );
  }
}

/// Extension mapping domain [Budget] to Drift [BudgetsCompanion].
extension BudgetCompanionX on Budget {
  /// Converts to Drift companion.
  BudgetsCompanion toCompanion() {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      period: Value(period),
      amountLimit: Value(amountLimit),
      alertThresholds: Value(alertThresholds.join(',')),
      alertSentAt80: Value(alertSentAt80),
      alertSentAt100: Value(alertSentAt100),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
    );
  }
}
