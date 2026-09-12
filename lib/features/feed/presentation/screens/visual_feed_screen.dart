import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/router/app_router.dart';
import 'package:bill_tracker/features/feed/presentation/widgets/feed_filter_bar.dart';
import 'package:bill_tracker/features/feed/presentation/widgets/feed_stats_header.dart';
import 'package:bill_tracker/features/feed/presentation/widgets/photo_grid_view.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// State provider for toggling between Photo Grid and Timeline List view modes.
final feedViewModeProvider = StateProvider<bool>((ref) => true); // true = Grid

/// Primary visual feed screen integrating monthly stats, category filters, and dual view modes.
class VisualFeedScreen extends ConsumerWidget {
  /// Creates [VisualFeedScreen].
  const VisualFeedScreen({super.key});

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
    final isGrid = ref.watch(feedViewModeProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BillTracker',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
            tooltip: isGrid ? 'Dạng danh sách' : 'Dạng lưới ảnh',
            onPressed: () {
              ref.read(feedViewModeProvider.notifier).state = !isGrid;
            },
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (transactions) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(transactionsStreamProvider);
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Quick monthly financial overview ──────────────
                  FeedStatsHeader(transactions: transactions),

                  // ── Search and Category filters ───────────────────
                  const FeedFilterBar(),

                  const Gap(12),

                  // ── Feed Content ──────────────────────────────────
                  if (transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 64,
                              color: colorScheme.outline,
                            ),
                            const Gap(12),
                            Text(
                              'Không có giao dịch nào',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              'Chụp món đồ hoặc quét hóa đơn ngay!',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Gap(20),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.push(Routes.createTransaction),
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm giao dịch'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (isGrid)
                    PhotoGridView(transactions: transactions)
                  else
                    _buildTimelineList(context, transactions),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineList(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    final grouped = _groupByDate(transactions);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 96),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
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
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < dayTransactions.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: 64,
                          color: colorScheme.outlineVariant.withAlpha(50),
                        ),
                      ListTile(
                        onTap: () {
                          context.push(
                            '${Routes.feed}/transaction/${dayTransactions[i].id}',
                          );
                        },
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (dayTransactions[i].category?.color ??
                                    colorScheme.primary)
                                .withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _resolveCategoryIcon(
                              dayTransactions[i].category?.icon,
                            ),
                            color: dayTransactions[i].category?.color ??
                                colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          dayTransactions[i].merchant ??
                              dayTransactions[i].category?.name ??
                              'Giao dịch',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          dayTransactions[i].occurredAt.toDisplayTime(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Text(
                          '${dayTransactions[i].type == TransactionType.expense ? '-' : '+'}${dayTransactions[i].amount.toVnd()}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: dayTransactions[i].type ==
                                    TransactionType.expense
                                ? colorScheme.error
                                : colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
