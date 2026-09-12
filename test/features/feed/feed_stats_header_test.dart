import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/feed/presentation/widgets/feed_stats_header.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 9);

  testWidgets('FeedStatsHeader correctly computes and formats balance',
      (tester) async {
    final transactions = [
      Transaction(
        id: 'tx_1',
        type: TransactionType.expense,
        amount: 50000,
        currency: 'VND',
        categoryId: 'food_drinks',
        occurredAt: now,
        source: TransactionSource.manual,
        status: TransactionStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_2',
        type: TransactionType.expense,
        amount: 30000,
        currency: 'VND',
        categoryId: 'transport',
        occurredAt: now,
        source: TransactionSource.manual,
        status: TransactionStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_3',
        type: TransactionType.income,
        amount: 200000,
        currency: 'VND',
        categoryId: 'work',
        occurredAt: now,
        source: TransactionSource.manual,
        status: TransactionStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: FeedStatsHeader(transactions: transactions),
        ),
      ),
    );

    // Total expense: 80.000đ
    expect(find.text('80.000đ'), findsOneWidget);
    // Total income: 200.000đ
    expect(find.text('200.000đ'), findsOneWidget);
    // Net balance: 120.000đ
    expect(find.text('120.000đ'), findsOneWidget);
  });
}
