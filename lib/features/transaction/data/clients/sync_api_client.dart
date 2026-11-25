import 'dart:async';
import 'dart:convert';

import 'package:bill_tracker/features/transaction/domain/repositories/sync_repository.dart';
import 'package:http/http.dart' as http;

/// Error raised for non-2xx sync API responses.
///
/// Carries the HTTP status so callers can decide retry vs. abort semantics
/// (4xx → do not retry; network error → retry with backoff).
class SyncApiException implements Exception {
  /// Creates a [SyncApiException].
  const SyncApiException(this.statusCode, this.message);

  /// HTTP status code of the failed response.
  final int statusCode;

  /// Human-readable error message from the server/body.
  final String message;

  @override
  String toString() => 'SyncApiException($statusCode, $message)';
}

/// Client for the cloud sync REST API (`/v1/sync/*`).
///
/// Implements the contract in PROJECT_CONTEXT §3.4 (API surface) and §3.8
/// (schemas): push (≤100 ops), pull (cursor, ≤200), bootstrap (page ≤100).
class SyncApiClient {
  /// Creates a [SyncApiClient].
  SyncApiClient({
    http.Client? httpClient,
    this.baseUrl,
    this.timeout = const Duration(seconds: 30),
  }) : _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Optional base URL (e.g. `https://api.example.com/v1`); sync paths are
  /// mounted under `/v1/sync/...`.
  final String? baseUrl;

  /// Request timeout.
  final Duration timeout;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = (baseUrl ?? '').replaceAll(RegExp(r'/+$'), '');
    final pathPart = base.isEmpty ? '/v1/sync$path' : '$base/v1/sync$path';
    if (query == null || query.isEmpty) {
      return Uri.parse(pathPart);
    }
    final qs = query.entries.map((e) => '${e.key}=${e.value}').join('&');
    return Uri.parse('$pathPart?$qs');
  }

  /// Pushes up to 100 operations to the server.
  Future<PushResponse> push({
    required String deviceId,
    required List<SyncOperation> operations,
  }) async {
    final body = jsonEncode({
      'device_id': deviceId,
      'operations': operations
          .map(
            (op) => {
              'operation_id': '${deviceId}_${op.entityId}_${op.operation}',
              'entity_type': op.entityType,
              'entity_id': op.entityId,
              'operation': op.operation,
              'base_revision': op.baseRevision,
              'occurred_at': DateTime.now().toIso8601String(),
              'payload': op.payload,
            },
          )
          .toList(),
    });

    final response = await _send(
      'POST',
      '/push',
      body: body,
    );

    final decoded = _decodeEnvelope(response.body);
    final rawAck = decoded['acknowledged'];
    final rawConflicts = decoded['conflicts'];
    final acknowledged = <AcknowledgedOp>[];
    final conflicts = <SyncConflict>[];
    if (rawAck is List) {
      for (final e in rawAck) {
        if (e is Map<String, dynamic>) {
          acknowledged.add(
            AcknowledgedOp(
              operationId: (e['operation_id'] as String?) ?? '',
              entityId: (e['entity_id'] as String?) ?? '',
              revision: (e['revision'] as num?)?.toInt() ?? 0,
              sequence: (e['sequence'] as num?)?.toInt() ?? 0,
            ),
          );
        }
      }
    }
    if (rawConflicts is List) {
      for (final e in rawConflicts) {
        if (e is Map<String, dynamic>) {
          conflicts.add(
            SyncConflict(
              operationId: (e['operation_id'] as String?) ?? '',
              entityId: (e['entity_id'] as String?) ?? '',
              entityType: (e['entity_type'] as String?) ?? '',
              conflictType: (e['conflict_type'] as String?) ?? '',
              serverRevision: (e['server_revision'] as num?)?.toInt() ?? 0,
              serverPayload: e['server_payload'] as Map<String, dynamic>?,
              hint: (e['hint'] as String?) ?? '',
            ),
          );
        }
      }
    }
    return PushResponse(
      acknowledged: acknowledged,
      conflicts: conflicts,
      serverCursor: (decoded['server_cursor'] as String?) ?? '',
    );
  }

  /// Pulls incremental changes since [cursor] (limit ≤ 200).
  Future<PullResponse> pull({
    required String deviceId,
    required String cursor,
    int limit = 200,
  }) async {
    final response = await _send(
      'GET',
      '/pull',
      query: {
        'cursor': cursor,
        'limit': '$limit',
      },
    );

    final decoded = _decodeEnvelope(response.body);
    final rawChanges = decoded['changes'];
    final changes = <SyncChange>[];
    if (rawChanges is List) {
      for (final e in rawChanges) {
        if (e is Map<String, dynamic>) {
          changes.add(
            SyncChange(
              entityType: (e['entity_type'] as String?) ?? '',
              entityId: (e['entity_id'] as String?) ?? '',
              operation: (e['operation'] as String?) ?? '',
              revision: (e['revision'] as num?)?.toInt() ?? 0,
              updatedAt:
                  DateTime.tryParse((e['updated_at'] as String?) ?? '') ??
                      DateTime.now(),
              payload: e['payload'] as Map<String, dynamic>?,
              sequence: (e['sequence'] as num?)?.toInt() ?? 0,
            ),
          );
        }
      }
    }
    return PullResponse(
      changes: changes,
      nextCursor: decoded['next_cursor'] as String? ?? '',
      hasMore: decoded['has_more'] as bool? ?? false,
    );
  }

  /// Fetches a bootstrap page for a fresh device.
  Future<BootstrapResponse> bootstrap({
    required String deviceId,
    int page = 0,
    int pageSize = 100,
  }) async {
    final response = await _send(
      'GET',
      '/bootstrap',
      query: {
        'page': '$page',
        'page_size': '$pageSize',
      },
    );

    final decoded = _decodeEnvelope(response.body);
    final rawEntities = decoded['entities'];
    final entities = <BootstrapEntity>[];
    if (rawEntities is List) {
      for (final e in rawEntities) {
        if (e is Map<String, dynamic>) {
          entities.add(
            BootstrapEntity(
              entityType: (e['entity_type'] as String?) ?? '',
              entityId: (e['entity_id'] as String?) ?? '',
              revision: (e['revision'] as num?)?.toInt() ?? 0,
              updatedAt:
                  DateTime.tryParse((e['updated_at'] as String?) ?? '') ??
                      DateTime.now(),
              payload: e['payload'] as Map<String, dynamic>?,
            ),
          );
        }
      }
    }
    return BootstrapResponse(
      entities: entities,
      page: (decoded['page'] as num?)?.toInt() ?? 0,
      totalPages: (decoded['total_pages'] as num?)?.toInt() ?? 1,
      bootstrapCursor: (decoded['bootstrap_cursor'] as String?) ?? '',
    );
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _uri(path, query);
    final request = http.Request(method, uri);
    request.headers['Content-Type'] = 'application/json';
    if (body != null) {
      request.bodyBytes = utf8.encode(body is String ? body : jsonEncode(body));
    }
    final streamed = await _http.send(request).timeout(timeout);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SyncApiException(response.statusCode, response.body);
    }
    return response;
  }

  Map<String, dynamic> _decodeEnvelope(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const SyncApiException(0, 'Invalid sync response envelope');
  }
}
