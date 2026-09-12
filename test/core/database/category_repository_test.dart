import 'package:bill_tracker/core/database/app_database.dart';
import 'package:bill_tracker/core/database/database_connection.dart';
import 'package:bill_tracker/features/transaction/data/repositories/category_repository_impl.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CategoryRepositoryImpl repo;

  setUp(() async {
    db = DatabaseConnection.inMemory();
    repo = CategoryRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepositoryImpl', () {
    test('seeds 10 system categories on database creation', () async {
      final categories = await repo.getAllCategories();
      expect(categories.length, 10);
      expect(categories.every((c) => c.isSystem), isTrue);

      final foodDrinks = categories.firstWhere((c) => c.id == 'food_drinks');
      expect(foodDrinks.name, 'Ăn uống');
      expect(foodDrinks.sortOrder, 1);
    });

    test('getCategoryById returns matching category or null', () async {
      final found = await repo.getCategoryById('food_drinks');
      expect(found, isNotNull);
      expect(found!.name, 'Ăn uống');

      final notFound = await repo.getCategoryById('non_existent');
      expect(notFound, isNull);
    });

    test('createCategory adds custom category', () async {
      const newCat = Category(
        id: 'custom_gaming',
        name: 'Gaming',
        icon: 'sports_esports',
        colorValue: 0xFF5C6BC0,
        sortOrder: 11,
      );

      await repo.createCategory(newCat);

      final retrieved = await repo.getCategoryById('custom_gaming');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Gaming');
      expect(retrieved.isSystem, isFalse);

      final all = await repo.getAllCategories();
      expect(all.length, 11);
    });

    test('updateCategory modifies category fields', () async {
      const newCat = Category(
        id: 'custom_hobby',
        name: 'Sở thích',
        icon: 'palette',
        colorValue: 0xFFE91E63,
        sortOrder: 12,
      );
      await repo.createCategory(newCat);

      const updatedCat = Category(
        id: 'custom_hobby',
        name: 'Nghệ thuật & Sở thích',
        icon: 'brush',
        colorValue: 0xFF880E4F,
        sortOrder: 12,
      );
      await repo.updateCategory(updatedCat);

      final retrieved = await repo.getCategoryById('custom_hobby');
      expect(retrieved!.name, 'Nghệ thuật & Sở thích');
      expect(retrieved.icon, 'brush');
    });

    test('deleteCategory prevents deleting system categories', () async {
      // Attempt to delete system category
      await repo.deleteCategory('food_drinks');

      final stillExists = await repo.getCategoryById('food_drinks');
      expect(stillExists, isNotNull);
    });

    test('deleteCategory deletes custom category', () async {
      const custom = Category(
        id: 'temp_cat',
        name: 'Tạm thời',
        icon: 'help',
        colorValue: 0xFF000000,
        sortOrder: 20,
      );
      await repo.createCategory(custom);

      final before = await repo.getCategoryById('temp_cat');
      expect(before, isNotNull);

      await repo.deleteCategory('temp_cat');

      final after = await repo.getCategoryById('temp_cat');
      expect(after, isNull);
    });

    test('watchAllCategories emits updates reactively', () async {
      final initial = await repo.watchAllCategories().first;
      expect(initial.length, 10);

      final expectation = expectLater(
        repo.watchAllCategories(),
        emitsThrough(
          predicate<List<Category>>((list) => list.length == 11),
        ),
      );

      await repo.createCategory(
        const Category(
          id: 'reactive_cat',
          name: 'Reactive',
          icon: 'bolt',
          colorValue: 0xFFFFEB3B,
          sortOrder: 99,
        ),
      );

      await expectation;
    });
  });
}
