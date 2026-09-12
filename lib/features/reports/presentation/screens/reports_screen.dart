import 'package:bill_tracker/features/reports/presentation/providers/report_providers.dart';
import 'package:bill_tracker/features/reports/presentation/widgets/category_donut_chart.dart';
import 'package:bill_tracker/features/reports/presentation/widgets/category_spending_list.dart';
import 'package:bill_tracker/features/reports/presentation/widgets/month_picker_bar.dart';
import 'package:bill_tracker/features/reports/presentation/widgets/monthly_trend_chart.dart';
import 'package:bill_tracker/features/reports/presentation/widgets/report_metrics_overview.dart';
import 'package:bill_tracker/features/reports/presentation/widgets/top_expenses_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Screen presenting visual financial charts, donut breakdown, and monthly trends.
class ReportsScreen extends ConsumerWidget {
  /// Creates [ReportsScreen].
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedMonth = ref.watch(selectedReportMonthProvider);
    final reportAsync = ref.watch(monthlyReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo chi tiêu'),
      ),
      body: Column(
        children: [
          // ── Month Picker Header ──────────────────────────────────────
          MonthPickerBar(
            selectedMonth: selectedMonth,
            onMonthChanged: (newMonth) {
              ref.read(selectedReportMonthProvider.notifier).state = newMonth;
            },
          ),
          const Divider(height: 1),

          // ── Report Content ──────────────────────────────────────────
          Expanded(
            child: reportAsync.when(
              data: (summary) {
                if (summary.totalExpense == 0 && summary.totalIncome == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 64,
                            color: colorScheme.outlineVariant,
                          ),
                          const Gap(16),
                          Text(
                            'Chưa có giao dịch trong tháng',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            'Ghi chép chi tiêu bằng chụp ảnh sản phẩm hoặc quét hóa đơn để xem phân tích trực quan.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(bottom: 96, top: 12),
                  children: [
                    // ── Summary Cards & MoM Change ────────────────────
                    ReportMetricsOverview(summary: summary),
                    const Gap(20),

                    // ── Donut Chart ───────────────────────────────────
                    CategoryDonutChart(
                      spendings: summary.categorySpendings,
                      totalExpense: summary.totalExpense,
                    ),
                    const Gap(20),

                    // ── Detailed Category Spending Breakdown ──────────
                    CategorySpendingList(
                      spendings: summary.categorySpendings,
                    ),
                    const Gap(24),

                    // ── Top 5 Expenses with Photos (PRD BR-03) ─────────
                    TopExpensesWidget(
                      topExpenses: summary.topExpenses,
                    ),
                    const Gap(24),

                    // ── 6-Month Historical Trend (PRD BR-04) ───────────
                    MonthlyTrendChart(
                      trends: summary.monthlyTrends,
                      selectedMonth: selectedMonth,
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Text('Lỗi: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
