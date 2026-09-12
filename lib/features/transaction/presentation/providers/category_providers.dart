import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/category_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [CategoryRepository].
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return getIt<CategoryRepository>();
});

/// Stream provider for all categories, ordered by sortOrder.
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchAllCategories();
});

/// Synchronous categories list provider (empty list while loading).
final categoriesListProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoriesStreamProvider).valueOrNull ?? const [];
});
