import 'dart:convert';

import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/utils/id_generator.dart';
import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/households/data/clients/household_api_client.dart';
import 'package:bill_tracker/features/households/domain/entities/household.dart';
import 'package:bill_tracker/features/households/domain/repositories/household_repository.dart';
import 'package:bill_tracker/features/transaction/data/sync/entity_serializer.dart';
import 'package:drift/drift.dart';

/// Drift + Cloud API implementation of [HouseholdRepository].
///
/// Works offline-first using cached `HouseholdMembers`, `Budgets`, and
/// `isShared == true` `Transactions`; synchronizes with [HouseholdApiClient]
/// when a remote backend URL is configured.
class HouseholdRepositoryImpl implements HouseholdRepository {
  /// Creates a [HouseholdRepositoryImpl].
  HouseholdRepositoryImpl({
    required AppDatabase db,
    HouseholdApiClient? apiClient,
  })  : _db = db,
        _apiClient = apiClient ?? HouseholdApiClient();

  final AppDatabase _db;
  final HouseholdApiClient _apiClient;

  @override
  Future<List<Household>> getHouseholds() async {
    if (_apiClient.isConfigured) {
      final remote = await _apiClient.listHouseholds();
      await _cacheHouseholds(remote);
      return remote;
    }

    final rows = await _db.select(_db.householdMembers).get();
    final byHh = <String, List<HouseholdMemberRow>>{};
    for (final row in rows) {
      byHh.putIfAbsent(row.householdId, () => []).add(row);
    }

    return byHh.entries.map((entry) {
      final members = entry.value
          .map(
            (r) => HouseholdMember(
              householdId: r.householdId,
              userId: r.userId,
              role: r.role == 'owner'
                  ? HouseholdRole.owner
                  : HouseholdRole.member,
              displayName: r.displayName,
              joinedAt: r.joinedAt,
            ),
          )
          .toList();
      final owner = members.firstWhere(
        (m) => m.role == HouseholdRole.owner,
        orElse: () => members.first,
      );
      final name = entry.value.first.householdName;
      return Household(
        id: entry.key,
        name: name.isNotEmpty ? name : 'Nhóm gia đình',
        createdBy: owner.userId,
        createdAt: owner.joinedAt,
        members: members,
      );
    }).toList();
  }

  @override
  Future<Household> createHousehold({
    required String name,
    String? displayName,
  }) async {
    if (_apiClient.isConfigured) {
      final hh = await _apiClient.createHousehold(
        name: name,
        displayName: displayName,
      );
      await _cacheHouseholds([hh]);
      return hh;
    }

    final now = DateTime.now();
    final hhId = 'hh_${IdGenerator.generateV7()}';
    const localUserId = 'local_owner';
    await _db.into(_db.householdMembers).insertOnConflictUpdate(
          HouseholdMembersCompanion(
            householdId: Value(hhId),
            householdName: Value(name.trim()),
            userId: const Value(localUserId),
            role: const Value('owner'),
            displayName: Value(displayName ?? 'Bạn'),
            joinedAt: Value(now),
          ),
        );
    return Household(
      id: hhId,
      name: name.trim(),
      createdBy: localUserId,
      createdAt: now,
      members: [
        HouseholdMember(
          householdId: hhId,
          userId: localUserId,
          role: HouseholdRole.owner,
          displayName: displayName ?? 'Bạn',
          joinedAt: now,
        ),
      ],
    );
  }

  @override
  Future<HouseholdInvite> createInvite({
    required String householdId,
    int expiresInHours = 72,
  }) async {
    if (_apiClient.isConfigured) {
      return _apiClient.createInvite(
        householdId: householdId,
        expiresInHours: expiresInHours,
      );
    }

    final now = DateTime.now();
    final suffix = IdGenerator.generateV7()
        .replaceAll('-', '')
        .toUpperCase()
        .substring(0, 6);
    final code = 'BT-$suffix';
    return HouseholdInvite(
      id: 'inv_${IdGenerator.generateV7()}',
      householdId: householdId,
      code: code,
      inviteLink: 'billtracker://household/join?code=$code',
      expiresAt: now.add(Duration(hours: expiresInHours)),
      createdAt: now,
    );
  }

  @override
  Future<Household> acceptInvite({
    required String code,
    String? displayName,
  }) async {
    if (_apiClient.isConfigured) {
      final hh = await _apiClient.acceptInvite(
        code: code,
        displayName: displayName,
      );
      await _cacheHouseholds([hh]);
      return hh;
    }

    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Mã mời không hợp lệ');
    }

    final now = DateTime.now();
    final hhId = 'hh_joined_${trimmed.toLowerCase()}';
    const userId = 'local_member';
    await _db.into(_db.householdMembers).insertOnConflictUpdate(
          HouseholdMembersCompanion(
            householdId: Value(hhId),
            householdName: Value('Gia đình ($trimmed)'),
            userId: const Value(userId),
            role: const Value('member'),
            displayName: Value(displayName ?? 'Thành viên'),
            joinedAt: Value(now),
          ),
        );
    return Household(
      id: hhId,
      name: 'Gia đình ($trimmed)',
      createdBy: 'owner',
      createdAt: now,
      members: [
        HouseholdMember(
          householdId: hhId,
          userId: userId,
          role: HouseholdRole.member,
          displayName: displayName ?? 'Thành viên',
          joinedAt: now,
        ),
      ],
    );
  }

  @override
  Future<void> removeMember({
    required String householdId,
    required String userId,
  }) async {
    if (_apiClient.isConfigured) {
      await _apiClient.removeMember(householdId: householdId, userId: userId);
    }
    await (_db.delete(_db.householdMembers)
          ..where(
            (m) => m.householdId.equals(householdId) & m.userId.equals(userId),
          ))
        .go();
  }

  @override
  Future<List<SharedBudgetSummary>> getSharedBudgets(String householdId) async {
    if (_apiClient.isConfigured) {
      return _apiClient.listSharedBudgets(householdId);
    }

    final budgetRows = await (_db.select(_db.budgets)
          ..where((b) => b.householdId.equals(householdId)))
        .get();
    final sharedTxs = await getSharedTransactions(householdId);

    return budgetRows.map((b) {
      final matching = sharedTxs
          .where(
            (t) =>
                t.categoryId == b.categoryId &&
                t.type == 'expense' &&
                !t.occurredAt.isBefore(b.periodStart) &&
                !t.occurredAt.isAfter(b.periodEnd),
          )
          .toList();
      final spent = matching.fold<double>(0, (acc, t) => acc + t.amount);
      final limit = b.amountLimit;
      final thresholds = b.alertThresholds
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((s) => double.tryParse(s.trim()) ?? 0.8)
          .toList();
      return SharedBudgetSummary(
        budget: Budget(
          id: b.id,
          householdId: b.householdId,
          categoryId: b.categoryId,
          period: b.period,
          amountLimit: b.amountLimit,
          alertThresholds: thresholds,
          alertSentAt80: b.alertSentAt80,
          alertSentAt100: b.alertSentAt100,
          alertSentAt120: b.alertSentAt120,
          periodStart: b.periodStart,
          periodEnd: b.periodEnd,
        ),
        spentAmount: spent,
        progressRatio: limit > 0 ? spent / limit : 0,
        recentTransactions: matching.take(10).toList(),
      );
    }).toList();
  }

  @override
  Future<SharedBudgetSummary> createSharedBudget({
    required String householdId,
    required String categoryId,
    required double amountLimit,
    required DateTime periodStart,
    required DateTime periodEnd,
    String period = 'monthly',
  }) async {
    if (_apiClient.isConfigured) {
      return _apiClient.createSharedBudget(
        householdId: householdId,
        categoryId: categoryId,
        amountLimit: amountLimit,
        periodStart: periodStart,
        periodEnd: periodEnd,
        period: period,
      );
    }

    final budget = Budget(
      id: 'bg_${IdGenerator.generateV7()}',
      householdId: householdId,
      categoryId: categoryId,
      period: period,
      amountLimit: amountLimit,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );

    await _db.transaction(() async {
      await _db.into(_db.budgets).insertOnConflictUpdate(
            BudgetsCompanion(
              id: Value(budget.id),
              householdId: Value(householdId),
              categoryId: Value(categoryId),
              period: Value(period),
              amountLimit: Value(amountLimit),
              periodStart: Value(periodStart),
              periodEnd: Value(periodEnd),
            ),
          );
      await _db.into(_db.syncOutbox).insert(
            SyncOutboxCompanion.insert(
              id: 'sync_budget_${budget.id}_${DateTime.now().millisecondsSinceEpoch}',
              entityType: 'budget',
              entityId: budget.id,
              operation: 'upsert',
              payloadJson: Value(jsonEncode(budgetPayload(budget))),
              createdAt: DateTime.now(),
            ),
          );
    });

    return SharedBudgetSummary(
      budget: budget,
      spentAmount: 0,
      progressRatio: 0,
    );
  }

  @override
  Future<List<SharedExpenseItem>> getSharedTransactions(
    String householdId,
  ) async {
    if (_apiClient.isConfigured) {
      return _apiClient.listSharedTransactions(householdId);
    }

    final members = await (_db.select(_db.householdMembers)
          ..where((m) => m.householdId.equals(householdId)))
        .get();
    final nameByUserId = <String, String>{
      for (final m in members)
        m.userId: (m.displayName != null && m.displayName!.trim().isNotEmpty)
            ? m.displayName!.trim()
            : m.userId,
    };

    // Privacy guard: ONLY query transactions with isShared == true.
    final rows = await (_db.select(_db.transactions)
          ..where(
            (t) =>
                t.householdId.equals(householdId) &
                t.isShared.equals(true) &
                t.status.equals('confirmed'),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
        .get();

    return rows.map((tx) {
      final creatorId = tx.createdByUserId ?? 'local_owner';
      final creatorName = tx.createdByName ??
          nameByUserId[creatorId] ??
          'Bạn';
      return SharedExpenseItem(
        id: tx.id,
        householdId: householdId,
        categoryId: tx.categoryId,
        type: tx.type.name,
        amount: tx.amount,
        currency: tx.currency,
        merchant: tx.merchant,
        note: tx.note,
        occurredAt: tx.occurredAt,
        isShared: tx.isShared,
        createdByUserId: creatorId,
        createdByName: creatorName,
      );
    }).toList();
  }

  Future<void> _cacheHouseholds(List<Household> households) async {
    await _db.transaction(() async {
      for (final hh in households) {
        await (_db.delete(_db.householdMembers)
              ..where((m) => m.householdId.equals(hh.id)))
            .go();
        for (final m in hh.members) {
          await _db.into(_db.householdMembers).insertOnConflictUpdate(
                HouseholdMembersCompanion(
                  householdId: Value(hh.id),
                  householdName: Value(hh.name),
                  userId: Value(m.userId),
                  role: Value(m.role.name),
                  displayName: Value(m.displayName),
                  joinedAt: Value(m.joinedAt),
                ),
              );
        }
      }
    });
  }
}
