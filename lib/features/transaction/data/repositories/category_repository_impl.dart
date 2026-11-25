import 'dart:convert';

import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/features/transaction/data/sync/entity_serializer.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/category_repository.dart';
import 'package:drift/drift.dart';

/// Implementation of [CategoryRepository] backed by Drift SQLite database.
class CategoryRepositoryImpl implements CategoryRepository {
  /// Creates [CategoryRepositoryImpl] with [AppDatabase].
  CategoryRepositoryImpl(this._db);

  final AppDatabase _db;

  /// Enqueues a sync outbox row inside the caller's transaction.
  Future<void> _enqueueOutbox({
    required String entityType,
    required String entityId,
    required String operation,
    Map<String, Object?>? payload,
  }) async {
    await _db.into(_db.syncOutbox).insert(
          SyncOutboxCompanion.insert(
            id: 'sync_${entityType}_${entityId}_${DateTime.now().millisecondsSinceEpoch}',
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payloadJson: Value(jsonEncode(payload ?? {})),
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final query = _db.select(_db.categories)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    final rows = await query.get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Stream<List<Category>> watchAllCategories() {
    final query = _db.select(_db.categories)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final query = _db.select(_db.categories)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<void> createCategory(Category category) async {
    await _db.into(_db.categories).insert(category.toCompanion());
    await _enqueueOutbox(
      entityType: 'category',
      entityId: category.id,
      operation: 'upsert',
      payload: categoryPayload(category),
    );
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _db.update(_db.categories).replace(category.toCompanion());
    await _enqueueOutbox(
      entityType: 'category',
      entityId: category.id,
      operation: 'upsert',
      payload: categoryPayload(category),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    // Only allow deletion of non-system categories
    final query = _db.delete(_db.categories)
      ..where((t) => t.id.equals(id) & t.isSystem.equals(false));
    await query.go();
    await _enqueueOutbox(
      entityType: 'category',
      entityId: id,
      operation: 'delete',
    );
  }
}

/// Mapper extension from Drift [CategoryRow] to domain [Category].
extension CategoryRowX on CategoryRow {
  /// Converts Drift row to domain entity.
  Category toDomain() => Category(
        id: id,
        name: name,
        icon: icon,
        colorValue: colorValue,
        parentId: parentId,
        isSystem: isSystem,
        sortOrder: sortOrder,
      );
}

/// Mapper extension from domain [Category] to Drift [CategoriesCompanion].
extension CategoryX on Category {
  /// Converts domain entity to Drift companion for insertion/update.
  CategoriesCompanion toCompanion() => CategoriesCompanion(
        id: Value(id),
        name: Value(name),
        icon: Value(icon),
        colorValue: Value(colorValue),
        parentId: Value(parentId),
        isSystem: Value(isSystem),
        sortOrder: Value(sortOrder),
      );
}
