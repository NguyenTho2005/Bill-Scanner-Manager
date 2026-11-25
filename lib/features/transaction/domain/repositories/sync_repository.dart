/// Cloud sync domain types and API contract types (P3).
library;

/// Cloud sync operations — implemented by the sync repository implementation
/// via the sync API client (see PROJECT_CONTEXT §3.4 / §3.5 / §3.8).
abstract class SyncRepository {
  /// Upserts/deletes entities by entity ID and returns the local revision.
  Future<void> syncEntities({
    required List<SyncOperation> operations,
  });

  /// Pulls changes since [cursor] (empty cursor → bootstrap semantics are
  /// handled by the worker). Follows pages until `hasMore == false`.
  Future<List<SyncChangeRecord>> pullChanges({
    String cursor = '',
    int limit = 200,
  });

  /// Bootstrap entities for a fresh device at [page] (page size ≤ 100).
  Future<List<SyncChangeRecord>> bootstrap({
    int page = 0,
    int pageSize = 100,
  });

  /// Flushes queued outbox rows (P3).
  Future<int> flushOutbox();

  /// Returns the last server cursor, or empty when the device is fresh.
  Future<String> getServerCursor();

  /// Persists the server cursor after a successful pull.
  Future<void> setServerCursor(String cursor);
}

/// One sync operation to be executed (client or server side, phase 3).
class SyncOperation {
  /// Constructs a new [SyncOperation].
  const SyncOperation({
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    this.baseRevision = 0,
  });

  /// 'transaction' | 'category' | 'budget' | 'media' | ...
  final String entityType;

  /// Entity primary key.
  final String entityId;

  /// 'upsert' or 'delete'.
  final String operation;

  /// Entity payload (optional for deletes).
  final Map<String, Object?>? payload;

  /// Last known server revision for optimistic concurrency.
  final int baseRevision;
}

/// A single pulled change (phase 3).
class SyncChangeRecord {
  /// Constructs a new [SyncChangeRecord].
  const SyncChangeRecord({
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.payload,
  });

  /// Entity type string (e.g. 'transaction').
  final String entityType;

  /// Entity primary key.
  final String entityId;

  /// 'upsert' or 'delete'.
  final String operation;

  /// Entity payload when available.
  final Map<String, Object?>? payload;
}

/// Acknowledged operation as returned by the server in `PushResponse`.
class AcknowledgedOp {
  /// Constructs an [AcknowledgedOp].
  const AcknowledgedOp({
    required this.operationId,
    required this.entityId,
    required this.revision,
    required this.sequence,
  });

  /// Server-assigned operation id.
  final String operationId;

  /// Entity primary key.
  final String entityId;

  /// Server revision after applying the operation.
  final int revision;

  /// Server change sequence assigned to this operation.
  final int sequence;
}

/// Conflict entry as returned by the server in `PushResponse`.
class SyncConflict {
  /// Constructs a [SyncConflict].
  const SyncConflict({
    required this.operationId,
    required this.entityId,
    required this.entityType,
    required this.conflictType,
    required this.serverRevision,
    required this.serverPayload,
    required this.hint,
  });

  /// Operation id that conflicted.
  final String operationId;

  /// Entity primary key.
  final String entityId;

  /// Entity type string.
  final String entityType;

  /// Conflict type, e.g. 'revision_mismatch' or 'tombstone_wins'.
  final String conflictType;

  /// Server revision at conflict time.
  final int serverRevision;

  /// Server-side winning payload (null when tombstoned).
  final Map<String, Object?>? serverPayload;

  /// Server hint, e.g. 'server_wins'.
  final String hint;
}

/// Response of `POST /v1/sync/push`.
class PushResponse {
  /// Constructs a [PushResponse].
  const PushResponse({
    required this.acknowledged,
    required this.conflicts,
    required this.serverCursor,
  });

  /// Successfully applied operations.
  final List<AcknowledgedOp> acknowledged;

  /// Conflicting operations (client should reconcile per [SyncConflict.hint]).
  final List<SyncConflict> conflicts;

  /// Server cursor to use for the next pull.
  final String serverCursor;
}

/// A single change returned by `GET /v1/sync/pull`.
class SyncChange {
  /// Constructs a [SyncChange].
  const SyncChange({
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.revision,
    required this.updatedAt,
    required this.payload,
    required this.sequence,
  });

  /// Entity type string (e.g. 'transaction').
  final String entityType;

  /// Entity primary key.
  final String entityId;

  /// 'upsert' or 'delete'.
  final String operation;

  /// Server revision after applying the change.
  final int revision;

  /// Server timestamp of the change.
  final DateTime updatedAt;

  /// Entity payload (null for deletes).
  final Map<String, Object?>? payload;

  /// Server change sequence.
  final int sequence;
}

/// Response of `GET /v1/sync/pull`.
class PullResponse {
  /// Constructs a [PullResponse].
  const PullResponse({
    required this.changes,
    required this.nextCursor,
    required this.hasMore,
  });

  /// Ordered list of changes since the cursor.
  final List<SyncChange> changes;

  /// Cursor for the next page (empty when `hasMore == false`).
  final String nextCursor;

  /// Whether more changes are available.
  final bool hasMore;
}

/// One entity in a bootstrap response.
class BootstrapEntity {
  /// Constructs a [BootstrapEntity].
  const BootstrapEntity({
    required this.entityType,
    required this.entityId,
    required this.revision,
    required this.updatedAt,
    required this.payload,
  });

  /// Entity type string (e.g. 'transaction').
  final String entityType;

  /// Entity primary key.
  final String entityId;

  /// Entity revision.
  final int revision;

  /// Entity timestamp.
  final DateTime updatedAt;

  /// Entity payload.
  final Map<String, Object?>? payload;
}

/// Response of `GET /v1/sync/bootstrap`.
class BootstrapResponse {
  /// Constructs a [BootstrapResponse].
  const BootstrapResponse({
    required this.entities,
    required this.page,
    required this.totalPages,
    required this.bootstrapCursor,
  });

  /// Page entities (may be fewer than the page size).
  final List<BootstrapEntity> entities;

  /// Zero-based page index.
  final int page;

  /// Total number of pages.
  final int totalPages;

  /// Cursor to resume bootstrap from (empty when fully consumed).
  final String bootstrapCursor;
}
