import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/reports/domain/entities/report_data.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Cards displaying key monthly metrics and month-over-month comparisons.
class ReportMetricsOverview extends StatelessWidget {
  /// Creates [ReportMetricsOverview].
  const ReportMetricsOverview({
    required this.summary,
    super.key,
  });

  /// The report summary data.
  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final change = summary.expenseChangePercent;

    final isIncreased = change > 0;
    final changeText = change.abs().toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // ── Main Expense Card ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer.withAlpha(150),
                  colorScheme.surfaceContainerHighest.withAlpha(120),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                      'Tổng chi tiêu tháng này',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (summary.previousMonthExpense > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isIncreased ? colorScheme.error : Colors.green)
                                  .withAlpha(30),
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isIncreased
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 14,
                              color: isIncreased
                                  ? colorScheme.error
                                  : Colors.green,
                            ),
                            const Gap(4),
                            Text(
                              '$changeText% so với tháng trước',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isIncreased
                                    ? colorScheme.error
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Gap(8),
                Text(
                  summary.totalExpense.toVnd(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),

          // ── Income & Net Balance ────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(80),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(
                      color: colorScheme.outlineVariant.withAlpha(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thu nhập',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        summary.totalIncome.toVnd(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(80),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(
                      color: colorScheme.outlineVariant.withAlpha(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số dư ròng',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        summary.netBalance.toVnd(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: summary.netBalance >= 0
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
