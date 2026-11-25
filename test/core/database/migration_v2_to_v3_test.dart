// Migration v2 → v3 (A.1 + B.1):
// - new sync columns + outbox/metadata tables exist,
// - enum values are persisted as snake_case (A.1.1).
import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart'
    as app_db_connection;
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _newDb() => app_db_connection.DatabaseConnection.inMemory();

void main() {
  test('schema is v6 and includes recurring rules and household members',
      () async {
    final db = _newDb();
    expect(db.schemaVersion, 6);
    final tables = db.allTables.map((t) => t.actualTableName).toSet();
    expect(tables, contains('sync_outbox'));
    expect(tables, contains('sync_metadata'));
    expect(tables, contains('transactions'));
    expect(tables, contains('transaction_medias'));
    expect(tables, contains('recurring_rules'));
    expect(tables, contains('household_members'));
    await db.close();
  });

  test('v3→v4: budgets gain alert_sent_at_120 and keep defaults', () async {
    final db = _newDb();
    // Fresh v4 table already has the column; simulate the upgrade path too.
    await db.migration.onUpgrade(Migrator(db), 3, 4);

    final columns = await db
        .customSelect('PRAGMA table_info(budgets)')
        .get();
    expect(
      columns.map((row) => row.read<String>('name')),
      contains('alert_sent_at120'),
    );

    final now = DateTime.utc(2026, 1, 1);
    await db.into(db.budgets).insert(
          BudgetsCompanion.insert(
            id: 'bg_v4',
            categoryId: 'food_drinks',
            amountLimit: 1000000,
            periodStart: now,
            periodEnd: now.add(const Duration(days: 30)),
          ),
        );
    final row = await db.select(db.budgets).getSingle();
    expect(row.alertSentAt120, isFalse);
    await db.close();
  });

  test('v2→v3: onUpgrade runs twice without error', () async {
    final db = _newDb();
    final migrator = Migrator(db);
    // Simulate "from v2": run the v3 steps twice — safe due to _safeAddColumn.
    await db.migration.onUpgrade(migrator, 2, 3);
    await db.migration.onUpgrade(migrator, 2, 3);
    expect(db.schemaVersion, 6);
    await db.close();
  });

  test('v5→v6: adds household_members and privacy is_shared columns', () async {
    final db = _newDb();
    await db.migration.onUpgrade(Migrator(db), 5, 6);

    final txCols = await db.customSelect('PRAGMA table_info(transactions)').get();
    final txColNames = txCols.map((r) => r.read<String>('name')).toSet();
    expect(txColNames, containsAll(['is_shared', 'household_id', 'created_by_name']));

    final budgetCols = await db.customSelect('PRAGMA table_info(budgets)').get();
    expect(
      budgetCols.map((r) => r.read<String>('name')),
      contains('household_id'),
    );
    await db.close();
  });

  test('v2→v3: enum values are stored as snake_case (A.1.1)', () async {
    final db = _newDb();
    final now = DateTime.utc(2026, 1, 1);
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            id: 'tx_enum_test',
            type: TransactionType.expense,
            amount: 10.5,
            source: TransactionSource.productSnap,
            status: TransactionStatus.needsReview,
            paymentMethod: const Value(PaymentMethod.ewallet),
            categoryId: 'other',
            occurredAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Raw SQL: the stored strings must be snake_case (not camelCase).
    final rows = await db
        .customSelect(
          'SELECT type, source, status, payment_method FROM transactions '
          "WHERE id = 'tx_enum_test'",
        )
        .get();
    expect(rows.first.read<String>('source'), 'product_snap');
    expect(rows.first.read<String>('status'), 'needs_review');
    expect(rows.first.read<String>('type'), 'expense');
    expect(rows.first.read<String>('payment_method'), 'ewallet');

    // Domain read: enum comes back as enum.
    final rawRow = await db.select(db.transactions).getSingle();
    expect(rawRow.source, TransactionSource.productSnap);
    expect(rawRow.status, TransactionStatus.needsReview);
    expect(rawRow.paymentMethod, PaymentMethod.ewallet);

    // Sync columns exist with defaults.
    expect(rawRow.revision, 0);
    expect(rawRow.syncState, 'synced');

    await db.close();
  });

  test('v2→v3: legacy camelCase backfill (A.2.2)', () async {
    final db = _newDb();
    // Seed legacy camelCase data, then run the migration statements.
    await db.customStatement(
      'INSERT INTO transactions (id, type, amount, currency, category_id, '
      'occurred_at, merchant, source, status, created_at, updated_at) '
      "VALUES ('tx_legacy', 'expense', 100, 'VND', 'other', "
      "'2026-01-01 00:00:00.000000', 'Test', 'productSnap', 'needsReview', "
      "'2026-01-01 00:00:00.000000', '2026-01-01 00:00:00.000000')",
    );
    await db.migration.onUpgrade(Migrator(db), 2, 3);

    final row = await db
        .customSelect(
          "SELECT source, status FROM transactions WHERE id = 'tx_legacy'",
        )
        .getSingle();
    expect(row.read<String>('source'), 'product_snap');
    expect(row.read<String>('status'), 'needs_review');
    await db.close();
  });
}
