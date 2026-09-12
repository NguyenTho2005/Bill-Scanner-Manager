import 'package:bill_tracker/core/ai/label_to_category_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LabelToCategoryMapper', () {
    test('maps food & drink labels to food_drinks', () {
      final labels = {'coffee': 0.94, 'cup': 0.88, 'table': 0.70};
      final result = LabelToCategoryMapper.mapLabels(labels);

      expect(result, isNotNull);
      expect(result!.categoryId, 'food_drinks');
      expect(result.confidence, 0.94);
      expect(result.matchedLabel, 'coffee');
    });

    test('maps vehicle labels to transport', () {
      final labels = {'motorcycle': 0.85, 'vehicle': 0.80};
      final result = LabelToCategoryMapper.mapLabels(labels);

      expect(result, isNotNull);
      expect(result!.categoryId, 'transport');
      expect(result.confidence, 0.85);
    });

    test('maps clothing & electronics to shopping', () {
      final apparelLabels = {'t-shirt': 0.91, 'textile': 0.75};
      final apparelResult = LabelToCategoryMapper.mapLabels(apparelLabels);
      expect(apparelResult!.categoryId, 'shopping');

      final electronicLabels = {'smartphone': 0.95, 'gadget': 0.90};
      final electronicResult =
          LabelToCategoryMapper.mapLabels(electronicLabels);
      expect(electronicResult!.categoryId, 'shopping');
    });

    test('maps books and stationery to education', () {
      final labels = {'textbook': 0.89, 'paper': 0.72};
      final result = LabelToCategoryMapper.mapLabels(labels);

      expect(result, isNotNull);
      expect(result!.categoryId, 'education');
    });

    test('maps pills and medical items to health', () {
      final labels = {'medicine': 0.92, 'capsule': 0.88};
      final result = LabelToCategoryMapper.mapLabels(labels);

      expect(result, isNotNull);
      expect(result!.categoryId, 'health');
    });

    test('returns null when all labels are below confidence threshold', () {
      final lowConfidenceLabels = {'coffee': 0.55, 'bread': 0.60};
      final result = LabelToCategoryMapper.mapLabels(
        lowConfidenceLabels,
        minConfidence: 0.65,
      );

      expect(result, isNull);
    });

    test('returns null when no labels match known keywords', () {
      final unknownLabels = {'cloud': 0.95, 'sky': 0.90, 'tree': 0.85};
      final result = LabelToCategoryMapper.mapLabels(unknownLabels);

      expect(result, isNull);
    });
  });
}
