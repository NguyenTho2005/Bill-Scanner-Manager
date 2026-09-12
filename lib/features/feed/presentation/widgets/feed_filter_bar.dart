import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/category_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Horizontal filter bar for filtering transactions by category and search term.
class FeedFilterBar extends ConsumerWidget {
  /// Creates [FeedFilterBar].
  const FeedFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesListProvider);
    final currentFilter = ref.watch(transactionFilterProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // ── Search bar ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 44,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm cửa hàng, món đồ, ghi chú...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outline,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.borderFull,
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                ref.read(transactionFilterProvider.notifier).state =
                    TransactionFilter(
                  categoryId: currentFilter.categoryId,
                  source: currentFilter.source,
                  startDate: currentFilter.startDate,
                  endDate: currentFilter.endDate,
                  searchQuery: val.trim().isEmpty ? null : val.trim(),
                );
              },
            ),
          ),
        ),

        const Gap(10),

        // ── Category chips ──────────────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isAll = currentFilter.categoryId == null;
                return ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: isAll,
                  onSelected: (_) {
                    ref.read(transactionFilterProvider.notifier).state =
                        TransactionFilter(
                      source: currentFilter.source,
                      startDate: currentFilter.startDate,
                      endDate: currentFilter.endDate,
                      searchQuery: currentFilter.searchQuery,
                    );
                  },
                );
              }

              final cat = categories[index - 1];
              final isSelected = currentFilter.categoryId == cat.id;

              return ChoiceChip(
                label: Text(cat.name),
                selected: isSelected,
                avatar: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: cat.color,
                    shape: BoxShape.circle,
                  ),
                ),
                onSelected: (selected) {
                  ref.read(transactionFilterProvider.notifier).state =
                      TransactionFilter(
                    categoryId: selected ? cat.id : null,
                    source: currentFilter.source,
                    startDate: currentFilter.startDate,
                    endDate: currentFilter.endDate,
                    searchQuery: currentFilter.searchQuery,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
