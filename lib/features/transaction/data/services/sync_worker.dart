import 'package:bill_tracker/features/transaction/data/clients/sync_api_client.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/sync_repository.dart';

/// Background cloud-sync worker (P3).
///
/// Runs one full sync cycle:
///  1. Pull — bootstrap a fresh device, then follow the pull cursor until the
///     server reports `hasMore == false`.
///  2. Flush — push pending outbox operations (≤ [maxOpsPerPush]) to the server.
///
/// Retry policy:
///  - Network-level failures and 5xx responses → exponential backoff retry.
///  - 4xx API errors → no retry (permanent; surfaced to the caller).
///  - After [maxAttempts] failed attempts the last error is rethrown.
class SyncWorker {
  /// Creates a [SyncWorker].
  SyncWorker({
    required SyncRepository repository,
    this.maxOpsPerPush = 100,
    this.maxPullLimit = 200,
    this.maxAttempts = 5,
    this.initialBackoffSeconds = 2,
    this.maxBackoffSeconds = 60,
  })  : _repository = repository;

  final SyncRepository _repository;

  /// Maximum operations per push request (server contract: ≤ 100).
  final int maxOpsPerPush;

  /// Maximum changes per pull request (server contract: ≤ 200).
  final int maxPullLimit;

  /// Maximum retry attempts before giving up.
  final int maxAttempts;

  /// Backoff starts at this many seconds and doubles each attempt.
  final int initialBackoffSeconds;

  /// Backoff ceiling in seconds.
  final int maxBackoffSeconds;

  /// Runs one full sync cycle (pull → flush) with retry handling.
  Future<void> runCycle() async {
    await _withRetry(_pullLatest);
    await _withRetry(_flushOutbox);
  }

  /// Pulls the latest server state: bootstrap for a fresh device, otherwise
  /// incremental changes via the stored server cursor.
  Future<void> _pullLatest() async {
    final cursor = await _repository.getServerCursor();
    if (cursor.isEmpty) {
      // Fresh device: bootstrap all pages of entities.
      var page = 0;
      var exhausted = false;
      while (!exhausted) {
        final records = await _repository.bootstrap(
          page: page,
          pageSize: maxPullLimit,
        );
        exhausted = records.length < maxPullLimit;
        if (records.isNotEmpty) {
          final last = records.last;
          final updatedAt = last.payload?['updated_at'];
          if (updatedAt is String && updatedAt.isNotEmpty) {
            await _repository.setServerCursor(updatedAt);
          }
        }
        page++;
        if (exhausted) {
          break;
        }
      }
      return;
    }
    await _repository.pullChanges(
      cursor: cursor,
      limit: maxPullLimit,
    );
  }

  /// Pushes pending outbox operations with retry/backoff handling.
  Future<void> _flushOutbox() async {
    var attempt = 0;
    while (true) {
      try {
        await _repository.flushOutbox();
        return;
      } on SyncApiException catch (error) {
        if (error.statusCode < 500 || attempt >= maxAttempts) {
          // 4xx → permanent; 5xx → retryable but attempts exhausted.
          rethrow;
        }
      } on Object {
        // Network-level failure → retryable.
      }
      if (attempt >= maxAttempts) {
        throw StateError('Sync flush failed after $maxAttempts attempts');
      }
      attempt++;
      final delaySeconds =
          initialBackoffSeconds * (1 << attempt).clamp(1, maxBackoffSeconds);
      await Future<void>.delayed(Duration(seconds: delaySeconds));
    }
  }

  /// Runs [action], retrying with exponential backoff on retryable errors.
  Future<void> _withRetry(Future<void> Function() action) async {
    var attempt = 0;
    while (true) {
      try {
        await action();
        return;
      } on SyncApiException catch (error) {
        if (error.statusCode < 500 || attempt >= maxAttempts) {
          rethrow;
        }
      } on Object {
        // Network-level failure → retryable.
      }
      if (attempt >= maxAttempts) {
        throw StateError(
          'Sync worker action failed after $maxAttempts attempts',
        );
      }
      attempt++;
      final delaySeconds =
          (initialBackoffSeconds * (1 << attempt)).clamp(1, maxBackoffSeconds);
      await Future<void>.delayed(Duration(seconds: delaySeconds));
    }
  }
}
