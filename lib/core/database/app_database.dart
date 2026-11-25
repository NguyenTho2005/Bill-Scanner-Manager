import 'package:bill_tracker/core/database/converters/snake_case_converters.dart';
import 'package:bill_tracker/core/database/tables/ai_inferences_table.dart';
import 'package:bill_tracker/core/database/tables/budgets_table.dart';
import 'package:bill_tracker/core/database/tables/categories_table.dart';
import 'package:bill_tracker/core/database/tables/chat_messages_table.dart';
import 'package:bill_tracker/core/database/tables/household_members_table.dart';
import 'package:bill_tracker/core/database/tables/receipt_extractions_table.dart';
import 'package:bill_tracker/core/database/tables/receipt_line_items_table.dart';
import 'package:bill_tracker/core/database/tables/recurring_rules_table.dart';
import 'package:bill_tracker/core/database/tables/sync_metadata_table.dart';
import 'package:bill_tracker/core/database/tables/sync_outbox_table.dart';
import 'package:bill_tracker/core/database/tables/transaction_medias_table.dart';
import 'package:bill_tracker/core/database/tables/transactions_table.dart';
import 'package:bill_tracker/features/transaction/domain/entities/recurring_rule.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction_media.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Predefined system categories to seed on first launch.
final List<CategoriesCompanion> defaultCategories = [
  const CategoriesCompanion(
    id: Value('food_drinks'),
    name: Value('Ăn uống'),
    icon: Value('restaurant'),
    colorValue: Value(0xFFFF6B35),
    isSystem: Value(true),
    sortOrder: Value(1),
  ),
  const CategoriesCompanion(
    id: Value('transport'),
    name: Value('Di chuyển'),
    icon: Value('directions_car'),
    colorValue: Value(0xFF2196F3),
    isSystem: Value(true),
    sortOrder: Value(2),
  ),
  const CategoriesCompanion(
    id: Value('shopping'),
    name: Value('Mua sắm'),
    icon: Value('shopping_bag'),
    colorValue: Value(0xFF9C27B0),
    isSystem: Value(true),
    sortOrder: Value(3),
  ),
  const CategoriesCompanion(
    id: Value('entertainment'),
    name: Value('Giải trí'),
    icon: Value('movie'),
    colorValue: Value(0xFFE91E63),
    isSystem: Value(true),
    sortOrder: Value(4),
  ),
  const CategoriesCompanion(
    id: Value('health'),
    name: Value('Sức khỏe'),
    icon: Value('medical_services'),
    colorValue: Value(0xFF4CAF50),
    isSystem: Value(true),
    sortOrder: Value(5),
  ),
  const CategoriesCompanion(
    id: Value('education'),
    name: Value('Giáo dục'),
    icon: Value('school'),
    colorValue: Value(0xFF00BCD4),
    isSystem: Value(true),
    sortOrder: Value(6),
  ),
  const CategoriesCompanion(
    id: Value('bills'),
    name: Value('Hóa đơn'),
    icon: Value('receipt'),
    colorValue: Value(0xFFFF9800),
    isSystem: Value(true),
    sortOrder: Value(7),
  ),
  const CategoriesCompanion(
    id: Value('work'),
    name: Value('Công việc'),
    icon: Value('work'),
    colorValue: Value(0xFF607D8B),
    isSystem: Value(true),
    sortOrder: Value(8),
  ),
  const CategoriesCompanion(
    id: Value('travel'),
    name: Value('Du lịch'),
    icon: Value('flight'),
    colorValue: Value(0xFF009688),
    isSystem: Value(true),
    sortOrder: Value(9),
  ),
  const CategoriesCompanion(
    id: Value('other'),
    name: Value('Khác'),
    icon: Value('more_horiz'),
    colorValue: Value(0xFF9E9E9E),
    isSystem: Value(true),
    sortOrder: Value(10),
  ),
];

/// The central Drift database for BillTracker.
@DriftDatabase(
  tables: [
    Categories,
    Transactions,
    TransactionMedias,
    Budgets,
    AIInferences,
    ReceiptExtractions,
    ReceiptLineItems,
    ChatMessages,
    SyncOutbox,
    SyncMetadata,
    RecurringRules,
    HouseholdMembers,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Standard constructor accepting a [QueryExecutor].
  AppDatabase(super.e);

  @override
  int get schemaVersion => 6;

  /// SQLite can't add an existing column — swallow duplicate errors so the
  /// migration can be re-run after createAll (used by migration tests).
  Future<void> _safeAddColumn(
    Migrator m,
    TableInfo<Table, dynamic> table,
    GeneratedColumn column,
  ) async {
    try {
      await m.addColumn(table, column);
    } on Object {
      // Ignore: duplicate column is fine when re-running after createAll.
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Seed the default system categories
          await batch((batch) {
            batch.insertAll(categories, defaultCategories);
          });
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // v2 adds the on-device assistant chat history.
          if (from < 2) {
            await m.createTable(chatMessages);
          }
          // v3: enum snake_case normalization (A.1.2 + A.2.2)
          if (from < 3) {
            await _safeAddColumn(
              m,
              transactions,
              transactions.revision,
            );
            await _safeAddColumn(
              m,
              transactions,
              transactions.deletedAt,
            );
            await _safeAddColumn(
              m,
              transactions,
              transactions.syncState,
            );
            await _safeAddColumn(
              m,
              transactions,
              transactions.lastSyncedAt,
            );
            await _safeAddColumn(
              m,
              transactionMedias,
              transactionMedias.revision,
            );
            await _safeAddColumn(
              m,
              transactionMedias,
              transactionMedias.deletedAt,
            );
            await _safeAddColumn(
              m,
              transactionMedias,
              transactionMedias.syncState,
            );
            await _safeAddColumn(
              m,
              transactionMedias,
              transactionMedias.lastSyncedAt,
            );
            await m.createTable(syncOutbox);
            await m.createTable(syncMetadata);

            // A.1.2 + B.1 — sync columns on every syncable table.
            await _safeAddColumn(
              m,
              categories,
              categories.revision,
            );
            await _safeAddColumn(
              m,
              categories,
              categories.deletedAt,
            );
            await _safeAddColumn(
              m,
              categories,
              categories.syncState,
            );
            await _safeAddColumn(
              m,
              categories,
              categories.lastSyncedAt,
            );
            await _safeAddColumn(
              m,
              budgets,
              budgets.revision,
            );
            await _safeAddColumn(
              m,
              budgets,
              budgets.deletedAt,
            );
            await _safeAddColumn(
              m,
              budgets,
              budgets.syncState,
            );
            await _safeAddColumn(
              m,
              budgets,
              budgets.lastSyncedAt,
            );
            await _safeAddColumn(
              m,
              receiptExtractions,
              receiptExtractions.revision,
            );
            await _safeAddColumn(
              m,
              receiptExtractions,
              receiptExtractions.deletedAt,
            );
            await _safeAddColumn(
              m,
              receiptExtractions,
              receiptExtractions.syncState,
            );
            await _safeAddColumn(
              m,
              receiptExtractions,
              receiptExtractions.lastSyncedAt,
            );
            await _safeAddColumn(
              m,
              receiptLineItems,
              receiptLineItems.revision,
            );
            await _safeAddColumn(
              m,
              receiptLineItems,
              receiptLineItems.deletedAt,
            );
            await _safeAddColumn(
              m,
              receiptLineItems,
              receiptLineItems.syncState,
            );
            await _safeAddColumn(
              m,
              receiptLineItems,
              receiptLineItems.lastSyncedAt,
            );

            // A.2.2 — backfill legacy camelCase enum values in-place.
            const legacyBackfills = [
              ['transactions', 'source', 'productSnap', 'product_snap'],
              ['transactions', 'source', 'receiptScan', 'receipt_scan'],
              ['transactions', 'source', 'import_', 'import'],
              ['transactions', 'status', 'needsReview', 'needs_review'],
            ];
            for (final row in legacyBackfills) {
              await customStatement(
                'UPDATE ${row[0]} SET ${row[1]} = ? WHERE ${row[1]} = ?;',
                [row[3], row[2]],
              );
            }
          }
          // v4: 120% budget alert flag (§4.6 #16).
          if (from < 4 && to >= 4) {
            await _safeAddColumn(
              m,
              budgets,
              budgets.alertSentAt120,
            );
          }
          // v5: recurring transaction rules table.
          if (from < 5 && to >= 5) {
            try {
              await m.createTable(recurringRules);
            } on Object {
              // Ignore: table may already exist after onCreate's createAll.
            }
          }
          // v6: households & per-transaction sharing flag (isShared).
          if (from < 6 && to >= 6) {
            try {
              await m.createTable(householdMembers);
            } on Object {
              // Ignore if already created.
            }
            await _safeAddColumn(m, budgets, budgets.householdId);
            await _safeAddColumn(m, transactions, transactions.isShared);
            await _safeAddColumn(m, transactions, transactions.householdId);
            await _safeAddColumn(
              m,
              transactions,
              transactions.createdByUserId,
            );
            await _safeAddColumn(m, transactions, transactions.createdByName);
          }
        },
      );
}
