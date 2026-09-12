import 'package:bill_tracker/core/router/app_router.dart';
import 'package:bill_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:bill_tracker/features/budget/presentation/widgets/budget_card.dart';
import 'package:bill_tracker/features/budget/presentation/widgets/budget_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Screen displaying list of category budgets with real-time progress and alerts.
class BudgetListScreen extends ConsumerWidget {
  /// Creates [BudgetListScreen].
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressAsync = ref.watch(budgetProgressListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách & Hạn mức'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Thêm ngân sách',
            onPressed: () => context.push(Routes.createBudget),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.createBudget),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm ngân sách'),
      ),
      body: progressAsync.when(
        data: (progressList) {
          if (progressList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withAlpha(80),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pie_chart_outline_rounded,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Gap(20),
                    Text(
                      'Chưa có ngân sách nào',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Thiết lập hạn mức chi tiêu theo danh mục để nhận cảnh báo thông minh khi sắp chạm mức ngân sách.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(24),
                    FilledButton.icon(
                      onPressed: () => context.push(Routes.createBudget),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Tạo ngân sách đầu tiên'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(budgetProgressListProvider);
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96, top: 8),
              children: [
                // ── Overall Summary Card ─────────────────────────────
                BudgetSummaryCard(progressList: progressList),
                const Gap(8),

                // ── Section Title ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh mục có ngân sách (${progressList.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Tháng này',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Budget Cards ─────────────────────────────────────
                ...progressList.map(
                  (progress) => BudgetCard(
                    progress: progress,
                    onTap: () {
                      context.push(
                        '${Routes.editBudget}/${progress.budget.id}',
                      );
                    },
                    onDelete: () async {
                      await ref
                          .read(budgetActionNotifierProvider.notifier)
                          .deleteBudget(progress.budget.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa ngân sách')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('Lỗi: $err'),
        ),
      ),
    );
  }
}
