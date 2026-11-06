import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/features/budget/domain/entities/category_budget_progress.dart';
import 'package:bill_tracker/features/budget/domain/services/budget_forecaster.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Friendly end-of-period forecast banner, computed fully on-device from
/// average daily spending — no AI API or cloud involved.
///
/// Shows nothing when every budget is comfortably on track.
class BudgetForecastBanner extends StatelessWidget {
  /// Creates [BudgetForecastBanner] from budget progress items.
  const BudgetForecastBanner({
    required this.progressList,
    super.key,
  });

  /// Current budget progress list (budget + category + spent so far).
  final List<CategoryBudgetProgress> progressList;

  @override
  Widget build(BuildContext context) {
    const forecaster = BudgetForecaster();
    final now = DateTime.now();

    final warnings = <String>[];
    var worstSeverity = BudgetForecastSeverity.onTrack;

    for (final progress in progressList) {
      final forecast = forecaster.forecast(
        spentAmount: progress.spentAmount,
        amountLimit: progress.budget.amountLimit,
        periodStart: progress.budget.periodStart,
        periodEnd: progress.budget.periodEnd,
        now: now,
      );
      switch (forecast.severity) {
        case BudgetForecastSeverity.onTrack:
          continue;
        case BudgetForecastSeverity.nearLimit:
          worstSeverity = BudgetForecastSeverity.nearLimit;
          warnings.add(_nearLimitMessage(progress, forecast));
        case BudgetForecastSeverity.likelyExceed:
          worstSeverity = BudgetForecastSeverity.likelyExceed;
          warnings.add(_exceedMessage(progress, forecast));
      }
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = worstSeverity == BudgetForecastSeverity.likelyExceed
        ? colorScheme.error
        : colorScheme.tertiary;
    final containerColor = worstSeverity == BudgetForecastSeverity.likelyExceed
        ? colorScheme.errorContainer.withAlpha(110)
        : colorScheme.tertiaryContainer.withAlpha(110);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: containerColor,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: iconColor,
                  size: 20,
                ),
                const Gap(8),
                Text(
                  'Dự báo đến cuối kỳ',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const Gap(8),
            for (final warning in warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  warning,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _nearLimitMessage(
    CategoryBudgetProgress progress,
    BudgetForecast forecast,
  ) {
    final name = progress.category.name;
    if (forecast.projectedOverspend > 0) {
      return _exceedMessage(progress, forecast);
    }
    return '$name: đang chi ~'
        '${forecast.avgDailySpend.toVnd()}/ngày, dự tính hết tháng '
        'chi ~${forecast.projectedTotal.toVnd()} — sắp chạm hạn mức '
        '${progress.budget.amountLimit.toVnd()}.';
  }

  String _exceedMessage(
    CategoryBudgetProgress progress,
    BudgetForecast forecast,
  ) {
    final name = progress.category.name;
    return '$name: đang chi ~${forecast.avgDailySpend.toVnd()}/ngày, '
        'nếu giữ nhịp này hết tháng bạn sẽ chi '
        '~${forecast.projectedTotal.toVnd()}, vượt '
        '~${forecast.projectedOverspend.toVnd()} so với hạn mức '
        '${progress.budget.amountLimit.toVnd()}.';
  }
}
