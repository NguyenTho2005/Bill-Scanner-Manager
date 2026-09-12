import 'dart:math';

import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/reports/domain/entities/report_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Bar chart visualizing month-over-month spending trend over the past 6 months.
class MonthlyTrendChart extends StatelessWidget {
  /// Creates [MonthlyTrendChart].
  const MonthlyTrendChart({
    required this.trends,
    required this.selectedMonth,
    super.key,
  });

  /// 6-month historical trends.
  final List<MonthlyTrend> trends;

  /// The currently selected month.
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (trends.isEmpty) return const SizedBox.shrink();

    double maxExpense = 0;
    for (final t in trends) {
      if (t.expense > maxExpense) maxExpense = t.expense;
    }
    final maxY = maxExpense > 0 ? (maxExpense * 1.25) : 1000000.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xu hướng chi tiêu 6 tháng gần nhất',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const Gap(10),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(80),
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: colorScheme.outlineVariant.withAlpha(50),
              ),
            ),
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final trend = trends[groupIndex];
                        return BarTooltipItem(
                          '${trend.label}: ${trend.expense.toVnd()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= trends.length) {
                            return const SizedBox.shrink();
                          }
                          final t = trends[idx];
                          final isSelected = t.year == selectedMonth.year &&
                              t.month == selectedMonth.month;

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(trends.length, (i) {
                    final t = trends[i];
                    final isSelected = t.year == selectedMonth.year &&
                        t.month == selectedMonth.month;

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: max(t.expense, 0),
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.primary.withAlpha(90),
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
