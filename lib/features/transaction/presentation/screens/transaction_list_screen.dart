import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/router/app_router.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Transaction List Screen displaying chronologically grouped transactions.
class TransactionListScreen extends ConsumerWidget {
  /// Creates [TransactionListScreen].
  const TransactionListScreen({super.key});

  IconData _resolveCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'receipt':
        return Icons.receipt_long_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'flight':
        return Icons.flight_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final groups = <String, List<Transaction>>{};
    for (final tx in transactions) {
      final key = DateFormat('yyyy-MM-dd').format(tx.occurredAt);
      groups.putIfAbsent(key, () => []).add(tx);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi tải dữ liệu: $err')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 72,
                    color: colorScheme.outline,
                  ),
                  const Gap(16),
                  Text(
                    'Chưa có giao dịch nào',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Chụp món đồ, quét hóa đơn hoặc nhập thủ công ngay!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(24),
                  FilledButton.icon(
                    onPressed: () => context.push(Routes.createTransaction),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm giao dịch đầu tiên'),
                  ),
                ],
              ),
            );
          }

          final grouped = _groupByDate(transactions);

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: grouped.keys.length,
            itemBuilder: (context, index) {
              final dateKey = grouped.keys.elementAt(index);
              final dayTransactions = grouped[dateKey]!;
              final firstTx = dayTransactions.first;
              final dayTotal = dayTransactions.fold<double>(
                0,
                (sum, t) =>
                    sum +
                    (t.type == TransactionType.expense ? -t.amount : t.amount),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Date header ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          firstTx.occurredAt.toRelativeLabel(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          dayTotal.toVnd(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: dayTotal < 0
                                ? colorScheme.error
                                : colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Transaction tiles ───────────────────────────────
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < dayTransactions.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              indent: 64,
                              color: colorScheme.outlineVariant.withAlpha(50),
                            ),
                          _TransactionTile(
                            transaction: dayTransactions[i],
                            icon: _resolveCategoryIcon(
                              dayTransactions[i].category?.icon,
                            ),
                            onTap: () {
                              context.push(
                                '${Routes.feed}/transaction/${dayTransactions[i].id}',
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.icon,
    required this.onTap,
  });

  final Transaction transaction;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cat = transaction.category;
    final catColor = cat?.color ?? colorScheme.primary;
    final isExpense = transaction.type == TransactionType.expense;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: catColor.withAlpha(40),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: catColor, size: 22),
      ),
      title: Text(
        transaction.merchant ?? cat?.name ?? 'Giao dịch',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          if (transaction.note != null && transaction.note!.isNotEmpty)
            transaction.note,
          transaction.occurredAt.toDisplayTime(),
        ].whereType<String>().join(' · '),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${isExpense ? '-' : '+'}${transaction.amount.toVnd()}',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: isExpense ? colorScheme.error : colorScheme.primary,
        ),
      ),
    );
  }
}
