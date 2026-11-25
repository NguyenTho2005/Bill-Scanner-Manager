import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/households/domain/entities/household.dart';
import 'package:bill_tracker/features/households/presentation/providers/household_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/category_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Screen for managing household groups, inviting members, viewing shared
/// budgets, and seeing who spent what (`createdByName`).
class HouseholdBudgetScreen extends ConsumerStatefulWidget {
  /// Creates [HouseholdBudgetScreen].
  const HouseholdBudgetScreen({super.key});

  @override
  ConsumerState<HouseholdBudgetScreen> createState() =>
      _HouseholdBudgetScreenState();
}

class _HouseholdBudgetScreenState extends ConsumerState<HouseholdBudgetScreen> {
  Future<void> _showCreateHouseholdDialog() async {
    final nameCtrl = TextEditingController();
    final displayCtrl = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo nhóm ngân sách chung'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên nhóm (vd. Gia đình)',
              ),
            ),
            const Gap(12),
            TextField(
              controller: displayCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị của bạn',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tạo nhóm'),
          ),
        ],
      ),
    );
    if ((created ?? false) && nameCtrl.text.trim().isNotEmpty && mounted) {
      final hh = await ref.read(householdRepositoryProvider).createHousehold(
            name: nameCtrl.text.trim(),
            displayName: displayCtrl.text.trim().isEmpty
                ? null
                : displayCtrl.text.trim(),
          );
      ref
        ..invalidate(householdsListProvider)
        ..read(selectedHouseholdIdProvider.notifier).state = hh.id;
    }
  }

  Future<void> _showAcceptInviteDialog() async {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tham gia nhóm bằng mã mời'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Mã mời (vd. BT-XXXXXX)',
              ),
            ),
            const Gap(12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị của bạn',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
    if ((accepted ?? false) && codeCtrl.text.trim().isNotEmpty && mounted) {
      try {
        final hh = await ref.read(householdRepositoryProvider).acceptInvite(
              code: codeCtrl.text.trim(),
              displayName:
                  nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
            );
        ref
          ..invalidate(householdsListProvider)
          ..read(selectedHouseholdIdProvider.notifier).state = hh.id;
      } on Object catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể tham gia: $e')),
          );
        }
      }
    }
  }

  Future<void> _showInviteMemberDialog(String householdId) async {
    try {
      final invite = await ref
          .read(householdRepositoryProvider)
          .createInvite(householdId: householdId);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mời thành viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chia sẻ mã hoặc đường dẫn này cho thành viên:'),
              const Gap(12),
              SelectableText(
                invite.code,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Gap(8),
              SelectableText(
                invite.inviteLink,
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: invite.inviteLink));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép liên kết mời')),
                );
              },
              child: const Text('Sao chép link'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo mã mời: $e')),
        );
      }
    }
  }

  Future<void> _showCreateSharedBudgetDialog(String householdId) async {
    final amountCtrl = TextEditingController();
    final categories = ref.read(categoriesListProvider);
    var selectedCatId =
        categories.isNotEmpty ? categories.first.id : 'food_drinks';
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tạo ngân sách chung'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedCatId,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items: categories
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedCatId = val);
                },
              ),
              const Gap(12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hạn mức tháng (VND)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    final limit = double.tryParse(amountCtrl.text.trim());
    if ((created ?? false) && limit != null && limit > 0 && mounted) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month);
      final end = DateTime(now.year, now.month + 1)
          .subtract(const Duration(milliseconds: 1));
      await ref.read(householdRepositoryProvider).createSharedBudget(
            householdId: householdId,
            categoryId: selectedCatId,
            amountLimit: limit,
            periodStart: start,
            periodEnd: end,
          );
      ref.invalidate(sharedBudgetsProvider(householdId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final householdsAsync = ref.watch(householdsListProvider);
    final selectedId = ref.watch(selectedHouseholdIdProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách chung & Gia đình'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Tham gia qua mã mời',
            onPressed: _showAcceptInviteDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add_home_outlined),
            tooltip: 'Tạo nhóm mới',
            onPressed: _showCreateHouseholdDialog,
          ),
        ],
      ),
      body: householdsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (households) {
          if (households.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups_2_outlined,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const Gap(16),
                    Text(
                      'Chưa có nhóm ngân sách chung',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(8),
                    const Text(
                      'Tạo nhóm gia đình hoặc nhập mã mời để quản lý ngân sách chung. Giao dịch cá nhân mặc định luôn riêng tư trừ khi bạn bật chia sẻ.',
                      textAlign: TextAlign.center,
                    ),
                    const Gap(20),
                    Wrap(
                      spacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: _showCreateHouseholdDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Tạo nhóm'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _showAcceptInviteDialog,
                          icon: const Icon(Icons.vpn_key_outlined),
                          label: const Text('Nhập mã mời'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          final activeHousehold = households.firstWhere(
            (h) => h.id == selectedId,
            orElse: () => households.first,
          );

          return _HouseholdDetailBody(
            households: households,
            activeHousehold: activeHousehold,
            onSelectHousehold: (id) {
              ref.read(selectedHouseholdIdProvider.notifier).state = id;
            },
            onInviteMember: () => _showInviteMemberDialog(activeHousehold.id),
            onCreateBudget: () =>
                _showCreateSharedBudgetDialog(activeHousehold.id),
          );
        },
      ),
    );
  }
}

class _HouseholdDetailBody extends ConsumerWidget {
  const _HouseholdDetailBody({
    required this.households,
    required this.activeHousehold,
    required this.onSelectHousehold,
    required this.onInviteMember,
    required this.onCreateBudget,
  });

  final List<Household> households;
  final Household activeHousehold;
  final ValueChanged<String> onSelectHousehold;
  final VoidCallback onInviteMember;
  final VoidCallback onCreateBudget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final budgetsAsync = ref.watch(sharedBudgetsProvider(activeHousehold.id));
    final sharedTxAsync =
        ref.watch(sharedTransactionsProvider(activeHousehold.id));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (households.length > 1) ...[
          DropdownButtonFormField<String>(
            initialValue: activeHousehold.id,
            decoration: const InputDecoration(labelText: 'Nhóm đang xem'),
            items: households
                .map(
                  (h) => DropdownMenuItem(value: h.id, child: Text(h.name)),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) onSelectHousehold(val);
            },
          ),
          const Gap(12),
        ],

        // ── Members Card ────────────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Thành viên (${activeHousehold.members.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onInviteMember,
                      icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                      label: const Text('Mời thêm'),
                    ),
                  ],
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: activeHousehold.members.map((m) {
                    return Chip(
                      avatar: Icon(
                        m.role == HouseholdRole.owner
                            ? Icons.star_rounded
                            : Icons.person_outline,
                        size: 16,
                      ),
                      label: Text(
                        '${m.effectiveName}'
                        '${m.role == HouseholdRole.owner ? ' (Chủ nhóm)' : ''}',
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const Gap(16),

        // ── Shared Budgets ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ngân sách chung',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: onCreateBudget,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm hạn mức'),
            ),
          ],
        ),
        budgetsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Không tải được ngân sách chung: $e'),
          data: (budgets) {
            if (budgets.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Chưa có ngân sách chung nào trong nhóm này.'),
                ),
              );
            }
            return Column(
              children: budgets.map((item) {
                final clamped = item.progressRatio.clamp(0.0, 1.0);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.budget.categoryId,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${item.spentAmount.toVnd()} / '
                              '${item.budget.amountLimit.toVnd()}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        ClipRRect(
                          borderRadius: AppRadius.borderFull,
                          child: LinearProgressIndicator(
                            value: clamped,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const Gap(16),

        // ── Shared Spending Attribution ("Ai chi tiêu gì") ─────────────
        Text(
          'Chi tiêu đã chia sẻ (Ai chi tiêu gì)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(8),
        sharedTxAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Không tải được giao dịch chia sẻ: $e'),
          data: (txs) {
            if (txs.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Chưa có giao dịch nào được bật chia sẻ (isShared). Giao dịch cá nhân được giữ riêng tư.',
                  ),
                ),
              );
            }
            return Column(
              children: txs.map((tx) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        tx.createdByName.isNotEmpty
                            ? tx.createdByName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(tx.merchant ?? tx.categoryId),
                    subtitle: Text(
                      'Người chi: ${tx.createdByName} · '
                      '${tx.occurredAt.toDisplayDateTime()}',
                    ),
                    trailing: Text(
                      '-${tx.amount.toVnd()}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
