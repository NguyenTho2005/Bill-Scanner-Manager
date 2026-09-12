import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/budget/domain/entities/category_budget_progress.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Card displaying progress for a specific category budget.
class BudgetCard extends StatelessWidget {
  /// Creates [BudgetCard].
  const BudgetCard({
    required this.progress,
    this.onTap,
    this.onDelete,
    super.key,
  });

  /// Progress information for the category budget.
  final CategoryBudgetProgress progress;

  /// Optional tap callback (e.g. to edit).
  final VoidCallback? onTap;

  /// Optional delete callback.
  final VoidCallback? onDelete;

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'receipt':
        return Icons.receipt_long_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'flight':
        return Icons.flight_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cat = progress.category;
    final budget = progress.budget;
    final catColor = cat.color;

    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    if (progress.isExceeded) {
      statusColor = colorScheme.error;
      statusLabel = 'Đã vượt ngân sách';
      statusIcon = Icons.error_outline_rounded;
    } else if (progress.isNearLimit) {
      statusColor = Colors.orange;
      statusLabel = 'Sắp chạm mức (80%)';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = colorScheme.primary;
      statusLabel = 'Trong tầm kiểm soát';
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderLg,
        side: BorderSide(
          color: progress.isExceeded
              ? colorScheme.error.withAlpha(120)
              : colorScheme.outlineVariant.withAlpha(60),
          width: progress.isExceeded ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Icon, Name, More Actions ─────────────
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: catColor.withAlpha(35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _resolveIcon(cat.icon),
                      color: catColor,
                      size: 22,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          budget.period == 'monthly'
                              ? 'Ngân sách hàng tháng'
                              : 'Ngân sách theo chu kỳ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (action) {
                      if (action == 'edit') {
                        onTap?.call();
                      } else if (action == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            Gap(8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            const Gap(8),
                            Text(
                              'Xóa',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(14),

              // ── Spent vs Limit & Percentage ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: progress.spentAmount.toVnd(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${budget.amountLimit.toVnd()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${progress.percent}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const Gap(8),

              // ── Linear Progress Bar ──────────────────────────
              ClipRRect(
                borderRadius: AppRadius.borderFull,
                child: LinearProgressIndicator(
                  value: progress.clampedProgress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: statusColor,
                ),
              ),
              const Gap(10),

              // ── Status Banner ────────────────────────────────
              Row(
                children: [
                  Icon(statusIcon, size: 16, color: statusColor),
                  const Gap(6),
                  Text(
                    statusLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    progress.isExceeded
                        ? 'Vượt ${progress.remainingAmount.abs().toVnd()}'
                        : 'Còn lại ${progress.remainingAmount.toVnd()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
