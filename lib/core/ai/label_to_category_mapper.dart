/// Mapping result with detected category ID and confidence.
class CategorySuggestion {
  /// Creates [CategorySuggestion].
  const CategorySuggestion({
    required this.categoryId,
    required this.confidence,
    required this.matchedLabel,
  });

  /// Suggested Category ID.
  final String categoryId;

  /// Confidence score between 0.0 and 1.0.
  final double confidence;

  /// The label that triggered this category match.
  final String matchedLabel;
}

/// Rule-based keyword matcher mapping ML Kit image labels to BillTracker categories.
class LabelToCategoryMapper {
  LabelToCategoryMapper._();

  static const _foodKeywords = {
    'food',
    'drink',
    'beverage',
    'coffee',
    'tea',
    'beer',
    'wine',
    'bread',
    'noodle',
    'rice',
    'meat',
    'fruit',
    'vegetable',
    'dessert',
    'snack',
    'dish',
    'cuisine',
    'pizza',
    'hamburger',
    'sandwich',
    'restaurant',
    'fast food',
    'meal',
    'breakfast',
    'lunch',
    'dinner',
    'cocktail',
    'juice',
    'cup',
    'bottle',
    'tableware',
  };

  static const _transportKeywords = {
    'car',
    'automobile',
    'vehicle',
    'motorcycle',
    'scooter',
    'bicycle',
    'bike',
    'bus',
    'train',
    'metro',
    'taxi',
    'fuel',
    'gasoline',
    'petrol',
    'parking',
    'tire',
    'wheel',
    'transport',
  };

  static const _shoppingKeywords = {
    'clothing',
    'apparel',
    'shirt',
    't-shirt',
    'pants',
    'trousers',
    'dress',
    'skirt',
    'jacket',
    'coat',
    'shoe',
    'footwear',
    'sneakers',
    'bag',
    'handbag',
    'backpack',
    'wallet',
    'watch',
    'jewelry',
    'cosmetics',
    'perfume',
    'electronics',
    'gadget',
    'laptop',
    'computer',
    'mobile phone',
    'smartphone',
    'headphones',
    'camera',
  };

  static const _entertainmentKeywords = {
    'toy',
    'game',
    'board game',
    'video game',
    'movie',
    'cinema',
    'ticket',
    'musical instrument',
    'guitar',
    'piano',
    'sports equipment',
    'ball',
    'comic book',
  };

  static const _healthKeywords = {
    'medicine',
    'pharmacy',
    'pill',
    'tablet',
    'capsule',
    'medical',
    'health',
    'vitamin',
    'supplement',
    'bandage',
    'hospital',
    'clinic',
    'fitness',
    'gym',
  };

  static const _educationKeywords = {
    'book',
    'textbook',
    'notebook',
    'pen',
    'pencil',
    'stationery',
    'school',
    'paper',
    'document',
    'library',
  };

  static const _travelKeywords = {
    'luggage',
    'suitcase',
    'passport',
    'airplane',
    'flight',
    'airport',
    'hotel',
    'resort',
    'beach',
    'tourism',
  };

  static const _workKeywords = {
    'office',
    'desk',
    'briefcase',
    'business',
    'paperwork',
  };

  static const _billsKeywords = {
    'utility',
    'electricity',
    'water meter',
    'invoice',
    'bill',
  };

  /// Maps a list of detected labels (sorted by confidence descending) to the best category.
  /// Minimum confidence threshold is [minConfidence] (default 0.65 as per PRD).
  static CategorySuggestion? mapLabels(
    Map<String, double> labelConfidences, {
    double minConfidence = 0.65,
  }) {
    for (final entry in labelConfidences.entries) {
      final label = entry.key.toLowerCase().trim();
      final conf = entry.value;

      if (conf < minConfidence) continue;

      if (_foodKeywords.any(label.contains)) {
        return CategorySuggestion(
          categoryId: 'food_drinks',
          confidence: conf,
          matchedLabel: entry.key,
        );
      }
      if (_transportKeywords.any(label.contains)) {
        return CategorySuggestion(
          categoryId: 'transport',
          confidence: conf,
          matchedLabel: entry.key,
        );
      }
      if (_shoppingKeywords.any(label.contains)) {
        return CategorySuggestion(
          categoryId: 'shopping',
          confidence: conf,
          matchedLabel: entry.key,
        );
      }
      if (_entertainmentKeywords.any(label.contains)) {
        return CategorySuggestion(
          categoryId: 'entertainment',
          confidence: conf,
          matchedLabel: entry.key,
        );
      }
      if (_healthKeywords.any(label.contains)) {
        return CategorySuggestion(
          categoryId: 'health',
          confidence: conf,
          matchedLabel: entry.key,
        );
      }
      if (_educationKeywords.any(label.contains)) {
        return CategorySuggestion(
          categoryId: 'education',
          confidence: conf,
          matchedLabel: entry.key,
        );
      }
      if (_travelKeywords.any(label.contains)) {
        return CategorySuggestion(
          categoryId: 'travel',
          confidence: conf,
          matchedLabel: entry.key,
        );
      }
      if (_workKeywords.any(label.contains)) {
        return CategorySuggestion(
          categoryId: 'work',
          confidence: conf,
          matchedLabel: entry.key,
        );
      }
      if (_billsKeywords.any(label.contains)) {
        return CategorySuggestion(
          categoryId: 'bills',
          confidence: conf,
          matchedLabel: entry.key,
        );
      }
    }

    return null;
  }
}
