import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:bill_tracker/features/transaction/domain/services/vietnamese_transaction_query_parser.dart';
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
                    _buildFilterFromQuery(
                  query: val.trim(),
                  currentFilter: currentFilter,
                  categories: categories,
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

  /// Builds a [TransactionFilter] from a free-text query.
  ///
  /// Vietnamese phrases like "ăn uống tháng này", "WinMart tháng trước",
  /// "trên 200 nghìn" or "tuần này" are translated into local date/amount/
  /// category filters. Queries the parser cannot understand fall back to a
  /// plain merchant/note keyword search, exactly like before.
  TransactionFilter _buildFilterFromQuery({
    required String query,
    required TransactionFilter currentFilter,
    required List<Category> categories,
  }) {
    if (query.isEmpty) {
      return TransactionFilter(
        categoryId: currentFilter.categoryId,
        source: currentFilter.source,
      );
    }

    final parsed = VietnameseTransactionQueryParser.parse(query);

    final keyword = parsed.keyword.trim();
    final categoryId =
        VietnameseTransactionQueryParser.resolveCategoryId(keyword, categories);

    return TransactionFilter(
      startDate: parsed.startDate ?? currentFilter.startDate,
      endDate: parsed.endDate ?? currentFilter.endDate,
      // Parsed category wins; unresolved keywords keep chip selection.
      categoryId: categoryId ?? currentFilter.categoryId,
      source: currentFilter.source,
      minAmount: parsed.minAmount ?? currentFilter.minAmount,
      maxAmount: parsed.maxAmount ?? currentFilter.maxAmount,
      // When the keyword already resolved to a category, drop it from the
      // text search — otherwise the AND-combined merchant/note match would
      // hide everything. Fallback unhandled text stays a plain
      // merchant/note keyword search.
      searchQuery: categoryId != null || keyword.isEmpty ? null : keyword,
    );
  }
}
