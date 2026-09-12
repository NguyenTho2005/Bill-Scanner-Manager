import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/reports/domain/entities/report_data.dart';
import 'package:bill_tracker/features/reports/presentation/widgets/category_spending_list.dart';
import 'package:bill_tracker/features/reports/presentation/widgets/report_metrics_overview.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const foodCat = Category(
    id: 'food_drinks',
    name: 'Ăn uống',
    icon: 'restaurant',
    colorValue: 0xFFFF6B35,
    isSystem: true,
  );

  const transportCat = Category(
    id: 'transport',
    name: 'Di chuyển',
    icon: 'directions_car',
    colorValue: 0xFF2196F3,
    isSystem: true,
  );

  final summary = ReportSummary(
    month: DateTime(2026, 9),
    totalExpense: 3000000,
    totalIncome: 10000000,
    previousMonthExpense: 2000000, // +50%
    categorySpendings: const [
      CategorySpending(
        category: foodCat,
        amount: 2000000,
        percentage: 66.7,
        transactionCount: 15,
      ),
      CategorySpending(
        category: transportCat,
        amount: 1000000,
        percentage: 33.3,
        transactionCount: 8,
      ),
    ],
    topExpenses: const [],
    monthlyTrends: const [],
  );

  testWidgets('ReportMetricsOverview displays total expense and MoM change',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ReportMetricsOverview(summary: summary),
        ),
      ),
    );

    expect(find.text('Tổng chi tiêu tháng này'), findsOneWidget);
    expect(find.text('3.000.000đ'), findsOneWidget);
    expect(find.text('50.0% so với tháng trước'), findsOneWidget);
    expect(find.text('10.000.000đ'), findsOneWidget);
    expect(find.text('7.000.000đ'), findsOneWidget);
  });

  testWidgets('CategorySpendingList renders category spendings and counts',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CategorySpendingList(
            spendings: summary.categorySpendings,
          ),
        ),
      ),
    );

    expect(find.text('Chi tiêu theo danh mục'), findsOneWidget);
    expect(find.text('Ăn uống'), findsOneWidget);
    expect(find.text('15 giao dịch'), findsOneWidget);
    expect(find.text('2.000.000đ'), findsOneWidget);
    expect(find.text('66.7%'), findsOneWidget);

    expect(find.text('Di chuyển'), findsOneWidget);
    expect(find.text('8 giao dịch'), findsOneWidget);
    expect(find.text('1.000.000đ'), findsOneWidget);
    expect(find.text('33.3%'), findsOneWidget);
  });
}
