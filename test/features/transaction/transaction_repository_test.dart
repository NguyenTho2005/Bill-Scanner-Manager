import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart';
import 'package:bill_tracker/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction_media.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl repo;

  setUp(() {
    db = DatabaseConnection.inMemory();
    repo = TransactionRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  final now = DateTime(2026, 9, 9, 14, 30);

  Transaction makeTx({
    required String id,
    double amount = 45000,
    String categoryId = 'food_drinks',
    String? merchant = 'Highlands Coffee',
    DateTime? occurredAt,
    String? note = 'Cà phê sáng',
    TransactionSource source = TransactionSource.manual,
  }) {
    return Transaction(
      id: id,
      type: TransactionType.expense,
      amount: amount,
      currency: 'VND',
      categoryId: categoryId,
      merchant: merchant,
      occurredAt: occurredAt ?? now,
      note: note,
      paymentMethod: PaymentMethod.cash,
      source: source,
      status: TransactionStatus.confirmed,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('TransactionRepositoryImpl', () {
    test('create and retrieve transaction by ID', () async {
      final tx = makeTx(id: 'tx_1');
      await repo.createTransaction(tx);

      final retrieved = await repo.getTransactionById('tx_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'tx_1');
      expect(retrieved.amount, 45000);
      expect(retrieved.merchant, 'Highlands Coffee');
      expect(retrieved.category, isNotNull);
      expect(retrieved.category!.name, 'Ăn uống');
    });

    test('create transaction with attached media and retrieve media', () async {
      final tx = makeTx(id: 'tx_with_media');
      const media = TransactionMedia(
        id: 'media_1',
        transactionId: 'tx_with_media',
        type: MediaType.product,
        compressedPath: '/data/compressed/img_1.jpg',
        thumbnailPath: '/data/thumbnails/thumb_1.jpg',
        hash: 'abc123hash',
        width: 1080,
        height: 1080,
        fileSizeBytes: 204800,
      );

      await repo.createTransaction(tx, media: media);

      final retrievedTx = await repo.getTransactionById('tx_with_media');
      expect(retrievedTx, isNotNull);
      expect(retrievedTx!.thumbnailPath, '/data/thumbnails/thumb_1.jpg');

      final medias = await repo.getMediasForTransaction('tx_with_media');
      expect(medias.length, 1);
      expect(medias.first.hash, 'abc123hash');
      expect(medias.first.type, MediaType.product);
    });

    test('filter transactions by category', () async {
      await repo.createTransaction(
        makeTx(id: 'tx_food', categoryId: 'food_drinks'),
      );
      await repo.createTransaction(
        makeTx(id: 'tx_transport', categoryId: 'transport'),
      );

      final foodOnly = await repo.getTransactions(
        filter: const TransactionFilter(categoryId: 'food_drinks'),
      );
      expect(foodOnly.length, 1);
      expect(foodOnly.first.id, 'tx_food');
    });

    test('filter transactions by date range', () async {
      await repo.createTransaction(
        makeTx(id: 'tx_old', occurredAt: DateTime(2026, 8, 1)),
      );
      await repo.createTransaction(
        makeTx(id: 'tx_recent', occurredAt: DateTime(2026, 9, 5)),
      );

      final filtered = await repo.getTransactions(
        filter: TransactionFilter(
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 30),
        ),
      );
      expect(filtered.length, 1);
      expect(filtered.first.id, 'tx_recent');
    });

    test('filter transactions by search query', () async {
      await repo.createTransaction(
        makeTx(id: 'tx_cgv', merchant: 'CGV Cinema', note: 'Xem phim'),
      );
      await repo.createTransaction(
        makeTx(id: 'tx_cafe', merchant: 'Phúc Long', note: 'Trà sen vàng'),
      );

      final searchResult = await repo.getTransactions(
        filter: const TransactionFilter(searchQuery: 'CGV'),
      );
      expect(searchResult.length, 1);
      expect(searchResult.first.merchant, 'CGV Cinema');

      final noteResult = await repo.getTransactions(
        filter: const TransactionFilter(searchQuery: 'sen vàng'),
      );
      expect(noteResult.length, 1);
      expect(noteResult.first.id, 'tx_cafe');
    });

    test('update transaction details', () async {
      final tx = makeTx(id: 'tx_update', amount: 50000);
      await repo.createTransaction(tx);

      final updated = tx.copyWith(
        amount: 65000,
        merchant: 'Highlands Coffee Cầu Giấy',
      );
      await repo.updateTransaction(updated);

      final retrieved = await repo.getTransactionById('tx_update');
      expect(retrieved!.amount, 65000);
      expect(retrieved.merchant, 'Highlands Coffee Cầu Giấy');
    });

    test('delete transaction cascades to attached media', () async {
      final tx = makeTx(id: 'tx_to_delete');
      const media = TransactionMedia(
        id: 'media_to_delete',
        transactionId: 'tx_to_delete',
        type: MediaType.receipt,
        compressedPath: '/path/comp.jpg',
        thumbnailPath: '/path/thumb.jpg',
        hash: 'hash_delete',
      );
      await repo.createTransaction(tx, media: media);

      expect(await repo.getTransactionById('tx_to_delete'), isNotNull);
      expect(
        (await repo.getMediasForTransaction('tx_to_delete')).length,
        1,
      );

      await repo.deleteTransaction('tx_to_delete');

      expect(await repo.getTransactionById('tx_to_delete'), isNull);
      expect(
        (await repo.getMediasForTransaction('tx_to_delete')).length,
        0,
      );
    });

    test('watchTransactions emits updates reactively', () async {
      final initial = await repo.watchTransactions().first;
      expect(initial.length, 0);

      final expectation = expectLater(
        repo.watchTransactions(),
        emitsThrough(
          predicate<List<Transaction>>((list) => list.length == 1),
        ),
      );

      await repo.createTransaction(makeTx(id: 'tx_stream'));
      await expectation;
    });
  });
}
