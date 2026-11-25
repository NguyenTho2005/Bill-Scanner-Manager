import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart';
import 'package:bill_tracker/features/transaction/data/clients/sync_api_client.dart';
import 'package:bill_tracker/features/transaction/data/repositories/category_repository_impl.dart';
import 'package:bill_tracker/features/transaction/data/repositories/sync_repository_impl.dart';
import 'package:bill_tracker/features/transaction/data/services/sync_worker.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/sync_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSyncApiClient extends SyncApiClient {
  _FakeSyncApiClient()
      : super(
          baseUrl: null,
        );

  PushResponse pushResponse = const PushResponse(
    acknowledged: [],
    conflicts: [],
    serverCursor: 'cursor_1',
  );
  PullResponse pullResponse = const PullResponse(
    changes: [],
    nextCursor: '',
    hasMore: false,
  );
  BootstrapResponse bootstrapResponse = const BootstrapResponse(
    entities: [],
    page: 0,
    totalPages: 1,
    bootstrapCursor: '',
  );

  int pushCalls = 0;
  int pullCalls = 0;
  int bootstrapCalls = 0;

  @override
  Future<PushResponse> push({
    required String deviceId,
    required List<SyncOperation> operations,
  }) async {
    pushCalls++;
    return pushResponse;
  }

  @override
  Future<PullResponse> pull({
    required String deviceId,
    required String cursor,
    int limit = 200,
  }) async {
    pullCalls++;
    return pullResponse;
  }

  @override
  Future<BootstrapResponse> bootstrap({
    required String deviceId,
    int page = 0,
    int pageSize = 100,
  }) async {
    bootstrapCalls++;
    return bootstrapResponse;
  }
}

class _FakeSyncRepository implements SyncRepository {
  _FakeSyncRepository({
    this.flushError,
    this.flushSuccesses = 1,
  });

  final Exception? flushError;
  int flushSuccesses;
  int flushCalls = 0;
  int pullCalls = 0;

  @override
  Future<void> syncEntities({required List<SyncOperation> operations}) async {}

  @override
  Future<List<SyncChangeRecord>> pullChanges({
    String cursor = '',
    int limit = 200,
  }) async {
    pullCalls++;
    return <SyncChangeRecord>[];
  }

  @override
  Future<List<SyncChangeRecord>> bootstrap({
    int page = 0,
    int pageSize = 100,
  }) async {
    return <SyncChangeRecord>[];
  }

  @override
  Future<int> flushOutbox() async {
    flushCalls++;
    if (flushError != null && flushCalls <= flushSuccesses) {
      throw flushError!;
    }
    return 0;
  }

  @override
  Future<String> getServerCursor() async => '';

  @override
  Future<void> setServerCursor(String cursor) async {}
}

void main() {
  group('SyncRepositoryImpl', () {
    late AppDatabase db;
    late _FakeSyncApiClient apiClient;
    late SyncRepositoryImpl repo;

    setUp(() async {
      db = DatabaseConnection.inMemory();
      apiClient = _FakeSyncApiClient();
      repo = SyncRepositoryImpl(
        db: db,
        apiClient: apiClient,
        deviceId: 'dev_test',
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('push success removes outbox rows after ack', () async {
      // Insert a category (which enqueues an outbox row).
      final categoryRepo =
          CategoryRepositoryImpl(db);
      await categoryRepo.createCategory(
        const Category(
          id: 'custom_sync',
          name: 'Sync',
          icon: 'sync',
          colorValue: 0xFF000000,
          sortOrder: 50,
        ),
      );

      final rowsBefore = await db.select(db.syncOutbox).get();
      expect(rowsBefore, isNotEmpty);

      apiClient.pushResponse = const PushResponse(
        acknowledged: [
          AcknowledgedOp(
            operationId: 'op',
            entityId: 'custom_sync',
            revision: 1,
            sequence: 1,
          ),
        ],
        conflicts: [],
        serverCursor: 'cursor_1',
      );

      await repo.flushOutbox();

      final rowsAfter = await db.select(db.syncOutbox).get();
      expect(rowsAfter, isEmpty);
    });

    test('conflict server_wins applies server payload without throwing',
        () async {
      apiClient.pushResponse = const PushResponse(
        acknowledged: [],
        conflicts: [
          SyncConflict(
            operationId: 'op',
            entityId: 'tx_1',
            entityType: 'transaction',
            conflictType: 'revision_mismatch',
            serverRevision: 2,
            serverPayload: {
              'id': 'tx_1',
              'type': 'expense',
              'amount': 100.0,
              'currency': 'VND',
              'category_id': 'cat',
              'occurred_at': '2026-01-01T00:00:00.000',
              'source': 'manual',
              'status': 'confirmed',
              'created_at': '2026-01-01T00:00:00.000',
              'updated_at': '2026-01-01T00:00:00.000',
            },
            hint: 'server_wins',
          ),
        ],
        serverCursor: 'cursor_2',
      );

      await expectLater(repo.flushOutbox(), completes);
    });

    test('pull pagination applies all changes', () async {
      apiClient.pullResponse = PullResponse(
        changes: [
          SyncChange(
            entityType: 'category',
            entityId: 'pulled_cat',
            operation: 'upsert',
            revision: 1,
            updatedAt: DateTime(2026, 1, 1),
            payload: const {
              'id': 'pulled_cat',
              'name': 'Pulled',
              'icon': 'inbox',
              'color_value': 0xFF123456,
              'is_system': false,
              'sort_order': 99,
            },
            sequence: 1,
          ),
        ],
        nextCursor: 'cursor_final',
        hasMore: false,
      );

      final result = await repo.pullChanges(cursor: '');
      expect(result.length, 1);

      final query = db.select(db.categories)
        ..where((c) => c.id.equals('pulled_cat'));
      final rows = await query.get();
      expect(rows.length, 1);
      expect(rows.first.name, 'Pulled');
    });

    test('network error surfaces from flushOutbox', () async {
      apiClient.pushResponse = const PushResponse(
        acknowledged: [],
        conflicts: [],
        serverCursor: '',
      );
      // Force a thrown exception by overriding push via subclass? Use a
      // client that throws instead.
      final categoryRepo = CategoryRepositoryImpl(db);
      await categoryRepo.createCategory(
        const Category(
          id: 'net_test',
          name: 'Net',
          icon: 'cloud',
          colorValue: 0xFF000000,
          sortOrder: 60,
        ),
      );

      final throwingClient = _ThrowingSyncApiClient();
      final throwingRepo = SyncRepositoryImpl(
        db: db,
        apiClient: throwingClient,
        deviceId: 'dev_test',
      );
      await expectLater(
        throwingRepo.flushOutbox(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('SyncWorker', () {
    test('retries flushOutbox on network error then succeeds', () async {
      final fakeRepo = _FakeSyncRepository(
        flushError: Exception('network'),
        flushSuccesses: 1,
      );
      final worker = SyncWorker(repository: fakeRepo);
      await worker.runCycle();
      expect(fakeRepo.flushCalls, 2);
    });
  });
}

class _ThrowingSyncApiClient extends SyncApiClient {
  _ThrowingSyncApiClient() : super(baseUrl: null);

  @override
  Future<PushResponse> push({
    required String deviceId,
    required List<SyncOperation> operations,
  }) async {
    throw Exception('network');
  }

  @override
  Future<PullResponse> pull({
    required String deviceId,
    required String cursor,
    int limit = 200,
  }) async {
    return const PullResponse(
      changes: [],
      nextCursor: '',
      hasMore: false,
    );
  }

  @override
  Future<BootstrapResponse> bootstrap({
    required String deviceId,
    int page = 0,
    int pageSize = 100,
  }) async {
    return const BootstrapResponse(
      entities: [],
      page: 0,
      totalPages: 1,
      bootstrapCursor: '',
    );
  }
}
