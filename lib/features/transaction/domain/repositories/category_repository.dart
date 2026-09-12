import 'package:bill_tracker/features/transaction/domain/entities/category.dart';

/// Repository interface for managing transaction categories.
abstract class CategoryRepository {
  /// Retrieves all categories ordered by [Category.sortOrder].
  Future<List<Category>> getAllCategories();

  /// Emits updates whenever the categories table changes.
  Stream<List<Category>> watchAllCategories();

  /// Finds a category by its unique ID.
  Future<Category?> getCategoryById(String id);

  /// Adds a new custom category.
  Future<void> createCategory(Category category);

  /// Updates an existing category.
  Future<void> updateCategory(Category category);

  /// Deletes a custom category (system categories cannot be deleted).
  Future<void> deleteCategory(String id);
}
