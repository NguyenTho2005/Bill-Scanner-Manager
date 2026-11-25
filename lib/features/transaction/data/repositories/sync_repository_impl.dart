import 'dart:convert';

import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/features/transaction/data/clients/sync_api_client.dart';
import 'package:bill_tracker/features/transaction/data/sync/entity_serializer.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction_media.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/sync_repository.dart';
import 'package:drift/drift.dart';

/// Drift-backed implementation of [SyncRepository].
///
/// Coordinates the sync outbox, the cloud sync API client and local database
/// writes (push → ack/conflict → pull → apply). See PROJECT_CONTEXT §3.5.
class SyncRepositoryImpl implements SyncRepository {
  /// Creates a [SyncRepositoryImpl].
  SyncRepositoryImpl({
    required AppDatabase db,
    required SyncApiClient apiClient,
    required String deviceId,
  })  : _db = db,
        _apiClient = apiClient,
        _deviceId = deviceId;

  final AppDatabase _db;
  final SyncApiClient _apiClient;
  final String _deviceId;

  static const int _maxOpsPerPush = 100;
  static const int _maxPullLimit = 200;

  @override
  Future<void> syncEntities({
    required List<SyncOperation> operations,
  }) async {
    final response = await _apiClient.push(
      deviceId: _deviceId,
      operations: operations,
    );
    for (final conflict in response.conflicts) {
      await _applyServerConflict(conflict);
    }
    if (response.serverCursor.isNotEmpty) {
      await _storeCursor(response.serverCursor);
    }
  }

  @override
  Future<List<SyncChangeRecord>> pullChanges({
    String cursor = '',
    int limit = 200,
  }) async {
    final all = <SyncChangeRecord>[];
    var nextCursor = cursor;
    while (true) {
      final response = await _apiClient.pull(
        deviceId: _deviceId,
        cursor: nextCursor,
        limit: limit > _maxPullLimit ? _maxPullLimit : limit,
      );
      for (final change in response.changes) {
        all.add(
          SyncChangeRecord(
            entityType: change.entityType,
            entityId: change.entityId,
            operation: change.operation,
            payload: change.payload,
          ),
        );
      }
      nextCursor = response.nextCursor;
      if (!response.hasMore || response.nextCursor.isEmpty) {
        break;
      }
    }
    for (final change in all) {
      await _applyChange(change);
    }
    await _storeCursor(nextCursor);
    return all;
  }

  @override
  Future<List<SyncChangeRecord>> bootstrap({
    int page = 0,
    int pageSize = 100,
  }) async {
    final response = await _apiClient.bootstrap(
      deviceId: _deviceId,
      page: page,
      pageSize: pageSize,
    );
    final records = <SyncChangeRecord>[];
    for (final entity in response.entities) {
      final record = SyncChangeRecord(
        entityType: entity.entityType,
        entityId: entity.entityId,
        operation: 'upsert',
        payload: entity.payload,
      );
      await _applyChange(record);
      records.add(record);
    }
    return records;
  }

  @override
  Future<int> flushOutbox() async {
    final query = _db.select(_db.syncOutbox)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final limited = query..limit(_maxOpsPerPush);
    final rows = await limited.get();
    if (rows.isEmpty) {
      return 0;
    }

    final operations = <SyncOperation>[];
    for (final row in rows) {
      final payload =
          _payloadFromJson(row.payloadJson) as Map<String, Object?>?;
      operations.add(
        SyncOperation(
          entityType: row.entityType,
          entityId: row.entityId,
          operation: row.operation,
          payload: payload,
          baseRevision: await _localRevision(row.entityType, row.entityId),
        ),
      );
    }

    final response = await _apiClient.push(
      deviceId: _deviceId,
      operations: operations,
    );

    final ackedKeys = response.acknowledged.map((a) => a.entityId).toSet();
    await _db.transaction(() async {
      for (final row in rows) {
        if (ackedKeys.contains(row.entityId)) {
          await (_db.delete(_db.syncOutbox)..where((t) => t.id.equals(row.id)))
              .go();
        }
      }
    });

    for (final conflict in response.conflicts) {
      await _applyServerConflict(conflict);
    }
    if (response.serverCursor.isNotEmpty) {
      await _storeCursor(response.serverCursor);
    }
    return operations.length;
  }

  /// Applies a pulled change (upsert/delete) to the local database.
  Future<void> _applyChange(SyncChangeRecord change) async {
    switch (change.entityType) {
      case 'transaction':
        if (change.operation == 'delete') {
          final stmt = _db.delete(_db.transactions)
            ..where((t) => t.id.equals(change.entityId));
          await stmt.go();
        } else if (change.payload != null) {
          final tx = transactionFromPayload(change.payload!);
          final companion = TransactionsCompanion(
            id: Value(tx.id),
            type: Value(tx.type),
            amount: Value(tx.amount),
            currency: Value(tx.currency),
            categoryId: Value(tx.categoryId),
            merchant: Value(tx.merchant),
            occurredAt: Value(tx.occurredAt),
            note: Value(tx.note),
            paymentMethod: Value(tx.paymentMethod),
            source: Value(tx.source),
            status: Value(tx.status),
            createdAt: Value(tx.createdAt),
            updatedAt: Value(tx.updatedAt),
            isShared: Value(tx.isShared),
            householdId: Value(tx.householdId),
            createdByUserId: Value(tx.createdByUserId),
            createdByName: Value(tx.createdByName),
          );
          await _db.into(_db.transactions).insertOnConflictUpdate(companion);
        }
      case 'category':
        if (change.operation == 'delete') {
          final stmt = _db.delete(_db.categories)
            ..where((t) => t.id.equals(change.entityId));
          await stmt.go();
        } else if (change.payload != null) {
          final category = categoryFromPayload(change.payload!);
          final companion = CategoriesCompanion(
            id: Value(category.id),
            name: Value(category.name),
            icon: Value(category.icon),
            colorValue: Value(category.colorValue),
            parentId: Value(category.parentId),
            isSystem: Value(category.isSystem),
            sortOrder: Value(category.sortOrder),
          );
          await _db.into(_db.categories).insertOnConflictUpdate(companion);
        }
      case 'budget':
        if (change.operation == 'delete') {
          final stmt = _db.delete(_db.budgets)
            ..where((t) => t.id.equals(change.entityId));
          await stmt.go();
        } else if (change.payload != null) {
          final budget = budgetFromPayload(change.payload!);
          final companion = BudgetsCompanion(
            id: Value(budget.id),
            categoryId: Value(budget.categoryId),
            amountLimit: Value(budget.amountLimit),
            periodStart: Value(budget.periodStart),
            periodEnd: Value(budget.periodEnd),
            period: Value(budget.period),
            alertThresholds: Value(budget.alertThresholds.join(',')),
            alertSentAt80: Value(budget.alertSentAt80),
            alertSentAt100: Value(budget.alertSentAt100),
            householdId: Value(budget.householdId),
          );
          await _db.into(_db.budgets).insertOnConflictUpdate(companion);
        }
      case 'media':
        if (change.operation == 'delete') {
          final stmt = _db.delete(_db.transactionMedias)
            ..where((t) => t.transactionId.equals(change.entityId));
          await stmt.go();
        } else if (change.payload != null) {
          final media = _mediaFromPayload(change.payload!);
          final companion = TransactionMediasCompanion(
            id: Value(media.id),
            transactionId: Value(media.transactionId),
            type: Value(media.type),
            originalPath: Value(media.originalPath),
            compressedPath: Value(media.compressedPath),
            thumbnailPath: Value(media.thumbnailPath),
            hash: Value(media.hash),
            width: Value(media.width),
            height: Value(media.height),
            fileSizeBytes: Value(media.fileSizeBytes),
            capturedAt: Value(media.capturedAt),
          );
          await _db
              .into(_db.transactionMedias)
              .insertOnConflictUpdate(companion);
        }
      default:
        break;
    }
  }

  TransactionMedia _mediaFromPayload(Map<String, Object?> payload) {
    return TransactionMedia(
      id: (payload['id'] as String?) ?? '',
      transactionId: (payload['transaction_id'] as String?) ?? '',
      type: MediaType.values.byName((payload['type'] as String?) ?? 'product'),
      compressedPath: (payload['compressed_path'] as String?) ?? '',
      thumbnailPath: (payload['thumbnail_path'] as String?) ?? '',
      hash: (payload['hash'] as String?) ?? '',
      originalPath: payload['original_path'] as String?,
      width: (payload['width'] as num?)?.toInt(),
      height: (payload['height'] as num?)?.toInt(),
      fileSizeBytes: (payload['file_size_bytes'] as num?)?.toInt(),
      capturedAt: DateTime.tryParse((payload['captured_at'] as String?) ?? ''),
    );
  }

  /// Applies a server conflict by taking the server payload when the server
  /// hints `server_wins` (whole-record last-write-wins).
  Future<void> _applyServerConflict(SyncConflict conflict) async {
    if (conflict.hint != 'server_wins') {
      return;
    }
    if (conflict.serverPayload != null) {
      await _applyChange(
        SyncChangeRecord(
          entityType: conflict.entityType,
          entityId: conflict.entityId,
          operation: 'upsert',
          payload: conflict.serverPayload,
        ),
      );
    }
    if (conflict.entityType == 'transaction') {
      await _db.customStatement(
        'UPDATE transactions SET sync_state = ? WHERE id = ?',
        ['conflict', conflict.entityId],
      );
    }
  }

  @override
  Future<void> setServerCursor(String cursor) async {
    await _storeCursor(cursor);
  }

  @override
  Future<String> getServerCursor() async {
    return _readCursor();
  }

  Future<void> _storeCursor(String cursor) async {
    final query = _db.select(_db.syncMetadata)
      ..where((m) => m.key.equals('server_cursor'));
    final rows = await query.get();
    if (rows.isEmpty) {
      await _db.into(_db.syncMetadata).insert(
            SyncMetadataCompanion.insert(
              key: 'server_cursor',
              value: Value(cursor),
            ),
          );
    } else {
      await (_db.update(_db.syncMetadata)
            ..where((m) => m.key.equals('server_cursor')))
          .write(SyncMetadataCompanion(value: Value(cursor)));
    }
  }

  Future<String> _readCursor() async {
    final query = _db.select(_db.syncMetadata)
      ..where((m) => m.key.equals('server_cursor'));
    final rows = await query.get();
    if (rows.isEmpty) {
      return '';
    }
    return rows.first.value;
  }

  Future<int> _localRevision(String entityType, String entityId) async {
    switch (entityType) {
      case 'transaction':
        final query = _db.select(_db.transactions)
          ..where((t) => t.id.equals(entityId));
        final rows = await query.get();
        return rows.isEmpty ? 0 : rows.first.revision;
      case 'category':
        final query = _db.select(_db.categories)
          ..where((t) => t.id.equals(entityId));
        final rows = await query.get();
        return rows.isEmpty ? 0 : rows.first.revision;
      case 'budget':
        final query = _db.select(_db.budgets)
          ..where((t) => t.id.equals(entityId));
        final rows = await query.get();
        return rows.isEmpty ? 0 : rows.first.revision;
      default:
        return 0;
    }
  }

  Map<String, Object?> _payloadFromJson(String raw) {
    if (raw.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, Object?>) return decoded;
    return <String, Object?>{};
  }
}
