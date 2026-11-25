import 'dart:async';
import 'dart:convert';

import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/households/domain/entities/household.dart';
import 'package:http/http.dart' as http;

/// Exception thrown by [HouseholdApiClient] on non-2xx HTTP responses.
class HouseholdApiException implements Exception {
  /// Creates a [HouseholdApiException].
  const HouseholdApiException(this.statusCode, this.message);

  /// HTTP status code.
  final int statusCode;

  /// Error detail message.
  final String message;

  @override
  String toString() => 'HouseholdApiException($statusCode, $message)';
}

/// REST client for `/v1/households/*` endpoints.
class HouseholdApiClient {
  /// Creates a [HouseholdApiClient].
  HouseholdApiClient({
    http.Client? httpClient,
    this.baseUrl,
    this.authTokenProvider,
    this.timeout = const Duration(seconds: 30),
  }) : _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Optional API base URL (e.g. `https://api.example.com`).
  final String? baseUrl;

  /// Callback returning current Bearer token when configured.
  final Future<String?> Function()? authTokenProvider;

  /// HTTP timeout.
  final Duration timeout;

  /// Whether a remote backend URL is configured.
  bool get isConfigured => baseUrl != null && baseUrl!.trim().isNotEmpty;

  Uri _uri(String path) {
    final base = (baseUrl ?? '').replaceAll(RegExp(r'/+$'), '');
    final full = base.isEmpty ? '/v1$path' : '$base/v1$path';
    return Uri.parse(full);
  }

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await authTokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
  }) async {
    final uri = _uri(path);
    final headers = await _headers();
    final encoded = body == null ? null : jsonEncode(body);
    final http.Response res;
    switch (method) {
      case 'GET':
        res = await _http.get(uri, headers: headers).timeout(timeout);
      case 'POST':
        res = await _http
            .post(uri, headers: headers, body: encoded)
            .timeout(timeout);
      case 'DELETE':
        res = await _http.delete(uri, headers: headers).timeout(timeout);
      default:
        throw UnsupportedError('Unsupported HTTP method $method');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HouseholdApiException(res.statusCode, res.body);
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  /// Lists households the current user belongs to.
  Future<List<Household>> listHouseholds() async {
    final decoded = await _send('GET', '/households');
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_householdFromJson)
        .toList();
  }

  /// Creates a new household (authenticated user becomes owner).
  Future<Household> createHousehold({
    required String name,
    String? displayName,
  }) async {
    final decoded = await _send(
      'POST',
      '/households',
      body: {
        'name': name,
        if (displayName != null && displayName.trim().isNotEmpty)
          'display_name': displayName.trim(),
      },
    );
    return _householdFromJson(decoded as Map<String, dynamic>);
  }

  /// Creates an invite code + deep link for [householdId].
  Future<HouseholdInvite> createInvite({
    required String householdId,
    int expiresInHours = 72,
  }) async {
    final decoded = await _send(
      'POST',
      '/households/$householdId/invites',
      body: {'expires_in_hours': expiresInHours},
    ) as Map<String, dynamic>;

    return HouseholdInvite(
      id: (decoded['id'] as String?) ?? '',
      householdId: (decoded['household_id'] as String?) ?? householdId,
      code: (decoded['code'] as String?) ?? '',
      inviteLink: (decoded['invite_link'] as String?) ?? '',
      expiresAt: DateTime.parse(decoded['expires_at'] as String),
      createdAt: DateTime.parse(decoded['created_at'] as String),
    );
  }

  /// Accepts an invite code and joins the household.
  Future<Household> acceptInvite({
    required String code,
    String? displayName,
  }) async {
    final decoded = await _send(
      'POST',
      '/households/invites/accept',
      body: {
        'code': code.trim(),
        if (displayName != null && displayName.trim().isNotEmpty)
          'display_name': displayName.trim(),
      },
    ) as Map<String, dynamic>;
    return _householdFromJson(decoded);
  }

  /// Removes a member from [householdId].
  Future<void> removeMember({
    required String householdId,
    required String userId,
  }) async {
    await _send('DELETE', '/households/$householdId/members/$userId');
  }

  /// Lists shared budgets for [householdId].
  Future<List<SharedBudgetSummary>> listSharedBudgets(
    String householdId,
  ) async {
    final decoded = await _send('GET', '/households/$householdId/budgets');
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_budgetSummaryFromJson)
        .toList();
  }

  /// Creates a shared budget in [householdId].
  Future<SharedBudgetSummary> createSharedBudget({
    required String householdId,
    required String categoryId,
    required double amountLimit,
    required DateTime periodStart,
    required DateTime periodEnd,
    String period = 'monthly',
  }) async {
    final decoded = await _send(
      'POST',
      '/households/$householdId/budgets',
      body: {
        'household_id': householdId,
        'category_id': categoryId,
        'period': period,
        'amount_limit': amountLimit,
        'period_start': periodStart.toUtc().toIso8601String(),
        'period_end': periodEnd.toUtc().toIso8601String(),
      },
    ) as Map<String, dynamic>;
    return _budgetSummaryFromJson(decoded);
  }

  /// Lists shared transactions in [householdId].
  Future<List<SharedExpenseItem>> listSharedTransactions(
    String householdId,
  ) async {
    final decoded =
        await _send('GET', '/households/$householdId/transactions');
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_sharedTxFromJson)
        .toList();
  }

  Household _householdFromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List? ?? const [];
    return Household(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      createdBy: (json['created_by'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ??
          DateTime.now(),
      members: rawMembers
          .whereType<Map<String, dynamic>>()
          .map(
            (m) => HouseholdMember(
              householdId: (m['household_id'] as String?) ?? '',
              userId: (m['user_id'] as String?) ?? '',
              role: (m['role'] as String?) == 'owner'
                  ? HouseholdRole.owner
                  : HouseholdRole.member,
              displayName: m['display_name'] as String?,
              joinedAt:
                  DateTime.tryParse((m['joined_at'] as String?) ?? '') ??
                      DateTime.now(),
            ),
          )
          .toList(),
    );
  }

  SharedBudgetSummary _budgetSummaryFromJson(Map<String, dynamic> json) {
    final rawRecent = json['recent_transactions'] as List? ?? const [];
    final budget = Budget(
      id: (json['id'] as String?) ?? '',
      householdId: json['household_id'] as String?,
      categoryId: (json['category_id'] as String?) ?? '',
      period: (json['period'] as String?) ?? 'monthly',
      amountLimit: (json['amount_limit'] as num?)?.toDouble() ?? 0,
      periodStart:
          DateTime.tryParse((json['period_start'] as String?) ?? '') ??
              DateTime.now(),
      periodEnd: DateTime.tryParse((json['period_end'] as String?) ?? '') ??
          DateTime.now(),
    );
    return SharedBudgetSummary(
      budget: budget,
      spentAmount: (json['spent_amount'] as num?)?.toDouble() ?? 0,
      progressRatio: (json['progress_ratio'] as num?)?.toDouble() ?? 0,
      recentTransactions: rawRecent
          .whereType<Map<String, dynamic>>()
          .map(_sharedTxFromJson)
          .toList(),
    );
  }

  SharedExpenseItem _sharedTxFromJson(Map<String, dynamic> json) {
    return SharedExpenseItem(
      id: (json['id'] as String?) ?? '',
      householdId: (json['household_id'] as String?) ?? '',
      categoryId: (json['category_id'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'expense',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'VND',
      merchant: json['merchant'] as String?,
      note: json['note'] as String?,
      occurredAt: DateTime.tryParse((json['occurred_at'] as String?) ?? '') ??
          DateTime.now(),
      isShared: (json['is_shared'] as bool?) ?? true,
      createdByUserId: (json['created_by_user_id'] as String?) ?? '',
      createdByName: (json['created_by_name'] as String?) ??
          (json['created_by_user_id'] as String?) ??
          'Thành viên',
    );
  }
}
