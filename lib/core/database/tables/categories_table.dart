import 'package:drift/drift.dart';

/// Categories table definition for Drift.
@DataClassName('CategoryRow')
class Categories extends Table {
  /// Unique identifier (e.g. "food_drinks", "cat_123").
  TextColumn get id => text()();

  /// Parent category ID for hierarchical categories (optional).
  TextColumn get parentId => text().nullable()();

  /// Display name (e.g. "Ăn uống").
  TextColumn get name => text()();

  /// Icon name or emoji (e.g. "restaurant", "🍔").
  TextColumn get icon => text()();

  /// Color hex code as integer (e.g. 0xFFFF6B35).
  IntColumn get colorValue => integer()();

  /// Whether this is a predefined system category (cannot be deleted).
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  /// Sort display order.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
