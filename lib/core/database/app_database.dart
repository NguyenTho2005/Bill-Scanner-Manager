import 'package:bill_tracker/core/database/tables/ai_inferences_table.dart';
import 'package:bill_tracker/core/database/tables/budgets_table.dart';
import 'package:bill_tracker/core/database/tables/categories_table.dart';
import 'package:bill_tracker/core/database/tables/receipt_extractions_table.dart';
import 'package:bill_tracker/core/database/tables/receipt_line_items_table.dart';
import 'package:bill_tracker/core/database/tables/transaction_medias_table.dart';
import 'package:bill_tracker/core/database/tables/transactions_table.dart';
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
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Standard constructor accepting a [QueryExecutor].
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Seed the default system categories
          await batch((batch) {
            batch.insertAll(categories, defaultCategories);
          });
        },
      );
}
