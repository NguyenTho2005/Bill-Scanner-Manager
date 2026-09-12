import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/budget/domain/entities/category_budget_progress.dart';
import 'package:bill_tracker/features/budget/presentation/widgets/budget_card.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const category = Category(
    id: 'food_drinks',
    name: 'Ăn uống',
    icon: 'restaurant',
    colorValue: 0xFFFF6B35,
    isSystem: true,
  );

  final now = DateTime(2026, 9, 1);
  final monthEnd = DateTime(2026, 9, 30);

  final budget = Budget(
    id: 'bg_1',
    categoryId: 'food_drinks',
    amountLimit: 1000000,
    periodStart: now,
    periodEnd: monthEnd,
  );

  Widget createWidget(CategoryBudgetProgress progress) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: BudgetCard(progress: progress),
      ),
    );
  }

  testWidgets('BudgetCard renders normal status when spent is below 80%',
      (tester) async {
    final progress = CategoryBudgetProgress(
      budget: budget,
      category: category,
      spentAmount: 500000, // 50%
    );

    await tester.pumpWidget(createWidget(progress));

    expect(find.text('Ăn uống'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Trong tầm kiểm soát'), findsOneWidget);
    expect(find.text('Còn lại 500.000đ'), findsOneWidget);
  });

  testWidgets('BudgetCard renders warning status when spent is at 80%',
      (tester) async {
    final progress = CategoryBudgetProgress(
      budget: budget,
      category: category,
      spentAmount: 850000, // 85%
    );

    await tester.pumpWidget(createWidget(progress));

    expect(find.text('Ăn uống'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('Sắp chạm mức (80%)'), findsOneWidget);
    expect(find.text('Còn lại 150.000đ'), findsOneWidget);
  });

  testWidgets('BudgetCard renders exceeded status when spent exceeds limit',
      (tester) async {
    final progress = CategoryBudgetProgress(
      budget: budget,
      category: category,
      spentAmount: 1200000, // 120%
    );

    await tester.pumpWidget(createWidget(progress));

    expect(find.text('Ăn uống'), findsOneWidget);
    expect(find.text('120%'), findsOneWidget);
    expect(find.text('Đã vượt ngân sách'), findsOneWidget);
    expect(find.text('Vượt 200.000đ'), findsOneWidget);
  });
}
