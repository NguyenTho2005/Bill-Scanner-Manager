import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/features/reports/domain/entities/report_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Donut chart visualizing category spending distribution.
class CategoryDonutChart extends StatefulWidget {
  /// Creates [CategoryDonutChart].
  const CategoryDonutChart({
    required this.spendings,
    required this.totalExpense,
    super.key,
  });

  /// Spending items per category.
  final List<CategorySpending> spendings;

  /// Overall expense total.
  final double totalExpense;

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.spendings.isEmpty || widget.totalExpense <= 0) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 48,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có dữ liệu chi tiêu tháng này',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final activeSpending =
        _touchedIndex >= 0 && _touchedIndex < widget.spendings.length
            ? widget.spendings[_touchedIndex]
            : null;

    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 62,
              sections: List.generate(widget.spendings.length, (i) {
                final isTouched = i == _touchedIndex;
                final item = widget.spendings[i];
                final radius = isTouched ? 34.0 : 26.0;

                return PieChartSectionData(
                  color: item.category.color,
                  value: item.amount,
                  title: item.percentage >= 8
                      ? '${item.percentage.toStringAsFixed(0)}%'
                      : '',
                  radius: radius,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
          // ── Center Hole Label ───────────────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activeSpending != null
                    ? activeSpending.category.name
                    : 'Tổng chi',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                activeSpending != null
                    ? activeSpending.amount.toVnd()
                    : widget.totalExpense.toVnd(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: activeSpending != null
                      ? activeSpending.category.color
                      : colorScheme.onSurface,
                ),
              ),
              if (activeSpending != null)
                Text(
                  '${activeSpending.percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
