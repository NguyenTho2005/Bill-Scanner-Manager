import 'dart:convert';
import 'dart:io';

import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/storage/image_storage_service.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Information about app storage consumption.
class StorageUsageInfo {
  /// Creates [StorageUsageInfo].
  const StorageUsageInfo({
    required this.imagesCount,
    required this.imagesSizeBytes,
    required this.databaseSizeBytes,
  });

  /// Total count of saved photo files.
  final int imagesCount;

  /// Size of stored images in bytes.
  final int imagesSizeBytes;

  /// Size of SQLite database file in bytes.
  final int databaseSizeBytes;

  /// Combined total size in bytes.
  int get totalSizeBytes => imagesSizeBytes + databaseSizeBytes;

  /// Formatted total size string (e.g. "12.4 MB").
  String get formattedTotalSize => _formatBytes(totalSizeBytes);

  /// Formatted image size string.
  String get formattedImagesSize => _formatBytes(imagesSizeBytes);

  /// Formatted database size string.
  String get formattedDatabaseSize => _formatBytes(databaseSizeBytes);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

/// Service handling data export/import, storage metrics, and data wiping.
class DataManagementService {
  /// Creates [DataManagementService].
  DataManagementService({
    required AppDatabase db,
    required ImageStorageService imageStorage,
  })  : _db = db,
        _imageStorage = imageStorage;

  final AppDatabase _db;
  final ImageStorageService _imageStorage;

  /// Calculates storage space occupied by photos and database.
  Future<StorageUsageInfo> getStorageUsage() async {
    var imagesCount = 0;
    var imagesSizeBytes = 0;

    try {
      final dir = await _imageStorage.getImagesDirectory();
      if (dir.existsSync()) {
        final files = dir.listSync();
        for (final file in files) {
          if (file is File) {
            imagesCount++;
            imagesSizeBytes += file.lengthSync();
          }
        }
      }
    } on Object catch (_) {}

    var databaseSizeBytes = 0;
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(appDocDir.path, 'bill_tracker.sqlite'));
      if (dbFile.existsSync()) {
        databaseSizeBytes = dbFile.lengthSync();
      }
    } on Object catch (_) {}

    return StorageUsageInfo(
      imagesCount: imagesCount,
      imagesSizeBytes: imagesSizeBytes,
      databaseSizeBytes: databaseSizeBytes,
    );
  }

  /// Exports all transactions, categories, and budgets to a JSON string.
  Future<String> exportDataAsJson() async {
    final transactions = await _db.select(_db.transactions).get();
    final medias = await _db.select(_db.transactionMedias).get();
    final categories = await _db.select(_db.categories).get();
    final budgets = await _db.select(_db.budgets).get();

    final exportObj = {
      'app': 'BillTracker',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'icon': c.icon,
              'colorValue': c.colorValue,
              'isSystem': c.isSystem,
              'sortOrder': c.sortOrder,
            },
          )
          .toList(),
      'transactions': transactions
          .map(
            (t) => {
              'id': t.id,
              'type': t.type,
              'amount': t.amount,
              'currency': t.currency,
              'categoryId': t.categoryId,
              'merchant': t.merchant,
              'occurredAt': t.occurredAt.toIso8601String(),
              'note': t.note,
              'paymentMethod': t.paymentMethod,
              'source': t.source,
              'status': t.status,
              'createdAt': t.createdAt.toIso8601String(),
              'updatedAt': t.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'medias': medias
          .map(
            (m) => {
              'id': m.id,
              'transactionId': m.transactionId,
              'compressedPath': m.compressedPath,
              'thumbnailPath': m.thumbnailPath,
              'hash': m.hash,
            },
          )
          .toList(),
      'budgets': budgets
          .map(
            (b) => {
              'id': b.id,
              'categoryId': b.categoryId,
              'period': b.period,
              'amountLimit': b.amountLimit,
              'alertThresholds': b.alertThresholds,
              'periodStart': b.periodStart.toIso8601String(),
              'periodEnd': b.periodEnd.toIso8601String(),
            },
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportObj);
  }

  /// Exports all transactions to standard RFC 4180 CSV string.
  Future<String> exportDataAsCsv() async {
    final query = _db.select(_db.transactions).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])
      ..orderBy([OrderingTerm.desc(_db.transactions.occurredAt)]);

    final rows = await query.get();
    final buffer = StringBuffer()
      ..writeln(
        'ID,Loại,Số tiền,Tiền tệ,Danh mục,Cửa hàng,Thời gian,Phương thức,Nguồn,Ghi chú',
      );

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (final row in rows) {
      final tx = row.readTable(_db.transactions);
      final cat = row.readTableOrNull(_db.categories);

      final line = [
        _escapeCsv(tx.id),
        _escapeCsv(tx.type == 'expense' ? 'Chi tiêu' : 'Thu nhập'),
        tx.amount.toString(),
        _escapeCsv(tx.currency),
        _escapeCsv(cat?.name ?? tx.categoryId),
        _escapeCsv(tx.merchant ?? ''),
        _escapeCsv(dateFormat.format(tx.occurredAt)),
        _escapeCsv(tx.paymentMethod ?? ''),
        _escapeCsv(tx.source),
        _escapeCsv(tx.note ?? ''),
      ].join(',');

      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Writes export content to a file in documents directory and returns path.
  Future<String> saveExportToFile({
    required String content,
    required String extension,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'bill_tracker_export_$timestamp.$extension';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(content, flush: true);
    return file.path;
  }

  /// Imports transactions, categories, and budgets from a JSON string.
  Future<int> importDataFromJson(String jsonString) async {
    final dynamic decoded = json.decode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Dữ liệu JSON sao lưu không hợp lệ');
    }

    var importedCount = 0;

    await _db.transaction(() async {
      // 1. Import Categories if any
      if (decoded['categories'] is List) {
        for (final item in decoded['categories'] as List) {
          if (item is Map<String, dynamic>) {
            await _db.into(_db.categories).insertOnConflictUpdate(
                  CategoriesCompanion(
                    id: Value(item['id'] as String),
                    name: Value(item['name'] as String),
                    icon: Value(item['icon'] as String),
                    colorValue: Value(item['colorValue'] as int),
                    isSystem: Value((item['isSystem'] as bool?) ?? false),
                    sortOrder: Value((item['sortOrder'] as int?) ?? 0),
                  ),
                );
          }
        }
      }

      // 2. Import Transactions
      if (decoded['transactions'] is List) {
        for (final item in decoded['transactions'] as List) {
          if (item is Map<String, dynamic>) {
            final occurredAt = DateTime.parse(item['occurredAt'] as String);
            final createdAt = item['createdAt'] != null
                ? DateTime.parse(item['createdAt'] as String)
                : occurredAt;
            final updatedAt = item['updatedAt'] != null
                ? DateTime.parse(item['updatedAt'] as String)
                : occurredAt;

            await _db.into(_db.transactions).insertOnConflictUpdate(
                  TransactionsCompanion(
                    id: Value(item['id'] as String),
                    type: Value(item['type'] as String),
                    amount: Value((item['amount'] as num).toDouble()),
                    currency: Value((item['currency'] as String?) ?? 'VND'),
                    categoryId: Value(item['categoryId'] as String),
                    merchant: Value(item['merchant'] as String?),
                    occurredAt: Value(occurredAt),
                    note: Value(item['note'] as String?),
                    paymentMethod: Value(item['paymentMethod'] as String?),
                    source: Value((item['source'] as String?) ?? 'import'),
                    status: Value((item['status'] as String?) ?? 'confirmed'),
                    createdAt: Value(createdAt),
                    updatedAt: Value(updatedAt),
                  ),
                );
            importedCount++;
          }
        }
      }

      // 3. Import Budgets
      if (decoded['budgets'] is List) {
        for (final item in decoded['budgets'] as List) {
          if (item is Map<String, dynamic>) {
            await _db.into(_db.budgets).insertOnConflictUpdate(
                  BudgetsCompanion(
                    id: Value(item['id'] as String),
                    categoryId: Value(item['categoryId'] as String),
                    period: Value((item['period'] as String?) ?? 'monthly'),
                    amountLimit: Value((item['amountLimit'] as num).toDouble()),
                    alertThresholds: Value(
                      (item['alertThresholds'] as String?) ?? '0.8,1.0,1.2',
                    ),
                    periodStart: Value(
                      DateTime.parse(item['periodStart'] as String),
                    ),
                    periodEnd: Value(
                      DateTime.parse(item['periodEnd'] as String),
                    ),
                  ),
                );
          }
        }
      }
    });

    return importedCount;
  }

  /// Completely wipes all data and photo files (PRD Module 5 Acceptance Criteria).
  Future<void> deleteAllData() async {
    // 1. Delete all SQLite table rows
    await _db.transaction(() async {
      await _db.delete(_db.receiptLineItems).go();
      await _db.delete(_db.receiptExtractions).go();
      await _db.delete(_db.aIInferences).go();
      await _db.delete(_db.transactionMedias).go();
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.budgets).go();

      // Delete custom categories
      await (_db.delete(_db.categories)..where((c) => c.isSystem.equals(false)))
          .go();
    });

    // 2. Wipe all stored photos and thumbnails
    try {
      final dir = await _imageStorage.getImagesDirectory();
      if (dir.existsSync()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          try {
            entity.deleteSync(recursive: true);
          } on Object catch (_) {}
        }
      }
    } on Object catch (_) {}
  }

  String _escapeCsv(String field) {
    if (field.contains(',') ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
