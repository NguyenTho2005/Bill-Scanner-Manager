import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/budget/domain/entities/category_budget_progress.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Summary card displaying overall budget allocation, total spent, and progress.
class BudgetSummaryCard extends StatelessWidget {
  /// Creates [BudgetSummaryCard].
  const BudgetSummaryCard({
    required this.progressList,
    super.key,
  });

  /// All category budget progress models.
  final List<CategoryBudgetProgress> progressList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    double totalLimit = 0;
    double totalSpent = 0;

    for (final p in progressList) {
      totalLimit += p.budget.amountLimit;
      totalSpent += p.spentAmount;
    }

    final ratio = totalLimit > 0 ? (totalSpent / totalLimit) : 0.0;
    final clampedRatio = ratio.clamp(0.0, 1.0);
    final isExceeded = totalSpent >= totalLimit && totalLimit > 0;
    final isNearLimit = !isExceeded && totalSpent >= (totalLimit * 0.8);

    final Color statusColor;
    if (isExceeded) {
      statusColor = colorScheme.error;
    } else if (isNearLimit) {
      statusColor = Colors.orange;
    } else {
      statusColor = colorScheme.primary;
    }

    final remaining = totalLimit - totalSpent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng ngân sách tháng này',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  '${(ratio * 100).toInt()}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalSpent.toVnd(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
              const Gap(8),
              Text(
                '/ ${totalLimit.toVnd()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: AppRadius.borderFull,
            child: LinearProgressIndicator(
              value: clampedRatio,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: statusColor,
            ),
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isExceeded ? 'Vượt quá hạn mức:' : 'Còn lại có thể chi:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                remaining.abs().toVnd(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isExceeded ? colorScheme.error : colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
