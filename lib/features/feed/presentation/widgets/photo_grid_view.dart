import 'dart:io';

import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/router/app_router.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// 2-column visual photo grid for transactions with thumbnails and amount badges.
class PhotoGridView extends StatelessWidget {
  /// Creates [PhotoGridView].
  const PhotoGridView({
    required this.transactions,
    super.key,
  });

  /// Transactions to display in grid.
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _PhotoGridCard(transaction: tx);
      },
    );
  }
}

class _PhotoGridCard extends StatelessWidget {
  const _PhotoGridCard({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cat = transaction.category;
    final catColor = cat?.color ?? colorScheme.primary;
    final isExpense = transaction.type == TransactionType.expense;
    final hasThumbnail = transaction.thumbnailPath != null &&
        File(transaction.thumbnailPath!).existsSync();

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(60),
        ),
      ),
      child: InkWell(
        onTap: () {
          context.push('${Routes.feed}/transaction/${transaction.id}');
        },
        child: Stack(
          children: [
            // ── Background image or category illustration ───────────
            Positioned.fill(
              child: hasThumbnail
                  ? Image.file(
                      File(transaction.thumbnailPath!),
                      fit: BoxFit.cover,
                    )
                  : ColoredBox(
                      color: catColor.withAlpha(25),
                      child: Center(
                        child: Icon(
                          Icons.category_rounded,
                          size: 48,
                          color: catColor.withAlpha(100),
                        ),
                      ),
                    ),
            ),

            // ── Top Bar: Source Badge & Date ────────────────────────
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(160),
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          transaction.source == TransactionSource.productSnap
                              ? Icons.camera_alt
                              : transaction.source ==
                                      TransactionSource.receiptScan
                                  ? Icons.receipt
                                  : Icons.edit,
                          color: Colors.white,
                          size: 11,
                        ),
                        const Gap(4),
                        Text(
                          cat?.name ?? 'Khác',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Gradient Overlay & Details ───────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(200),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (transaction.merchant != null)
                      Text(
                        transaction.merchant!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Gap(2),
                    Text(
                      '${isExpense ? '-' : '+'}${transaction.amount.toVnd()}',
                      style: TextStyle(
                        color: isExpense
                            ? const Color(0xFFFF8A80)
                            : const Color(0xFFB9F6CA),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
