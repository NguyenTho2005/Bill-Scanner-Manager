import 'dart:convert';
import 'dart:io';

import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart';
import 'package:bill_tracker/core/storage/data_management_service.dart';
import 'package:bill_tracker/core/storage/local_image_storage_service.dart';
import 'package:bill_tracker/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late LocalImageStorageService imageStorage;
  late DataManagementService service;
  late TransactionRepositoryImpl txRepo;

  setUp(() async {
    db = DatabaseConnection.inMemory();
    tempDir = await Directory.systemTemp.createTemp('bt_data_mgmt_test_');
    imageStorage = LocalImageStorageService(
      baseDirProvider: () async => tempDir,
    );
    service = DataManagementService(
      db: db,
      imageStorage: imageStorage,
    );
    txRepo = TransactionRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DataManagementService', () {
    test('exportDataAsJson produces valid JSON with version and items',
        () async {
      final now = DateTime(2026, 9, 9, 12);
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_exp_1',
          type: TransactionType.expense,
          amount: 55000,
          currency: 'VND',
          categoryId: 'food_drinks',
          merchant: 'Highlands Coffee',
          occurredAt: now,
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final jsonStr = await service.exportDataAsJson();
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;

      expect(decoded['app'], 'BillTracker');
      expect(decoded['version'], '1.0.0');
      expect(decoded['transactions'], isNotEmpty);
      final txList =
          (decoded['transactions'] as List).cast<Map<String, dynamic>>();
      expect(txList.first['id'], 'tx_exp_1');
      expect(txList.first['amount'], 55000.0);
      expect(txList.first['merchant'], 'Highlands Coffee');
    });

    test('exportDataAsCsv produces formatted CSV table with correct headers',
        () async {
      final now = DateTime(2026, 9, 9, 10, 30);
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_csv_1',
          type: TransactionType.expense,
          amount: 120000,
          currency: 'VND',
          categoryId: 'food_drinks',
          merchant: 'Phúc Long',
          occurredAt: now,
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final csv = await service.exportDataAsCsv();
      expect(
        csv,
        contains(
          'ID,Loại,Số tiền,Tiền tệ,Danh mục,Cửa hàng,Thời gian,Phương thức,Nguồn,Ghi chú',
        ),
      );
      expect(csv, contains('tx_csv_1'));
      expect(csv, contains('120000.0'));
      expect(csv, contains('Phúc Long'));
    });

    test('importDataFromJson imports transactions and budgets into database',
        () async {
      final backupJson = json.encode({
        'app': 'BillTracker',
        'version': '1.0.0',
        'transactions': [
          {
            'id': 'tx_imp_1',
            'type': 'expense',
            'amount': 85000.0,
            'currency': 'VND',
            'categoryId': 'food_drinks',
            'merchant': 'Cơm tấm Sài Gòn',
            'occurredAt': '2026-09-08T12:00:00.000',
            'note': 'Ăn trưa',
            'paymentMethod': 'cash',
            'source': 'manual',
            'status': 'confirmed',
            'createdAt': '2026-09-08T12:00:00.000',
            'updatedAt': '2026-09-08T12:00:00.000',
          }
        ],
        'budgets': [
          {
            'id': 'bg_imp_1',
            'categoryId': 'food_drinks',
            'period': 'monthly',
            'amountLimit': 4000000.0,
            'alertThresholds': '0.8,1.0',
            'periodStart': '2026-09-01T00:00:00.000',
            'periodEnd': '2026-09-30T23:59:59.999',
          },
        ],
      });

      final count = await service.importDataFromJson(backupJson);
      expect(count, 1);

      final savedTx = await txRepo.getTransactionById('tx_imp_1');
      expect(savedTx, isNotNull);
      expect(savedTx!.merchant, 'Cơm tấm Sài Gòn');
      expect(savedTx.amount, 85000.0);
    });

    test('Scenario: Xóa dữ liệu hoàn toàn (PRD Module 5 Acceptance Criteria)',
        () async {
      // 1. Seed some transactions and create mock image files
      final now = DateTime.now();
      await txRepo.createTransaction(
        Transaction(
          id: 'tx_wipe_1',
          type: TransactionType.expense,
          amount: 50000,
          currency: 'VND',
          categoryId: 'food_drinks',
          occurredAt: now,
          source: TransactionSource.manual,
          status: TransactionStatus.confirmed,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final imagesDir = await imageStorage.getImagesDirectory();
      final mockPhoto = File('${imagesDir.path}/test_photo.jpg');
      await mockPhoto.writeAsString('mock image content');
      expect(mockPhoto.existsSync(), isTrue);

      // 2. Perform deleteAllData
      await service.deleteAllData();

      // 3. Verify transactions are wiped
      final allTx = await txRepo.getTransactions();
      expect(allTx, isEmpty);

      // 4. Verify photos are removed
      expect(mockPhoto.existsSync(), isFalse);
    });
  });
}
