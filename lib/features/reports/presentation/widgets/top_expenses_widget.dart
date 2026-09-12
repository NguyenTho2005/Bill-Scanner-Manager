import 'dart:io';

import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/router/app_router.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Displays top 5 largest expense transactions with thumbnail images (PRD BR-03).
class TopExpensesWidget extends StatelessWidget {
  /// Creates [TopExpensesWidget].
  const TopExpensesWidget({
    required this.topExpenses,
    super.key,
  });

  /// Top 5 expense transactions.
  final List<Transaction> topExpenses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (topExpenses.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top 5 khoản chi lớn nhất',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Icon(
                Icons.photo_library_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
            ],
          ),
          const Gap(10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topExpenses.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              final tx = topExpenses[index];
              final hasThumbnail = tx.thumbnailPath != null &&
                  File(tx.thumbnailPath!).existsSync();
              final catColor = tx.category?.color ?? colorScheme.primary;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withAlpha(50),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    context.push('${Routes.feed}/transaction/${tx.id}');
                  },
                  borderRadius: AppRadius.borderMd,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // ── Rank Badge ───────────────────────────────
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: index < 3
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: index < 3
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Gap(10),

                        // ── Thumbnail or Category Icon ───────────────
                        ClipRRect(
                          borderRadius: AppRadius.borderSm,
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: hasThumbnail
                                ? Image.file(
                                    File(tx.thumbnailPath!),
                                    fit: BoxFit.cover,
                                  )
                                : ColoredBox(
                                    color: catColor.withAlpha(30),
                                    child: Icon(
                                      Icons.receipt_long_rounded,
                                      color: catColor,
                                      size: 24,
                                    ),
                                  ),
                          ),
                        ),
                        const Gap(12),

                        // ── Details ──────────────────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (tx.merchant != null && tx.merchant!.isNotEmpty)
                                    ? tx.merchant!
                                    : (tx.note != null && tx.note!.isNotEmpty)
                                        ? tx.note!
                                        : (tx.category?.name ?? 'Chi tiêu'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(2),
                              Text(
                                '${tx.category?.name ?? "Chi tiêu"} · ${tx.occurredAt.toDisplayDate()}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Amount ───────────────────────────────────
                        Text(
                          tx.amount.toVnd(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
