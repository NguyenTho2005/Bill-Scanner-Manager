import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/category_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Interactive category selection widget.
class CategoryPicker extends ConsumerWidget {
  /// Creates [CategoryPicker].
  const CategoryPicker({
    required this.selectedCategoryId,
    required this.onCategorySelected,
    super.key,
  });

  /// The currently selected category ID.
  final String? selectedCategoryId;

  /// Callback fired when a category is tapped.
  final ValueChanged<Category> onCategorySelected;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Center(child: Text('Lỗi tải danh mục: $e')),
      data: (categories) {
        return SizedBox(
          height: 90,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.id == selectedCategoryId;
              final catColor = category.color;

              return GestureDetector(
                onTap: () => onCategorySelected(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? catColor.withAlpha(40)
                        : Colors.transparent,
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(
                      color: isSelected ? catColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: catColor.withAlpha(isSelected ? 255 : 40),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _resolveIcon(category.icon),
                          size: 22,
                          color: isSelected ? Colors.white : catColor,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? catColor
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
