import 'package:drift/drift.dart';

/// AI inference audit log table.
@DataClassName('AIInferenceRow')
class AIInferences extends Table {
  /// Unique identifier.
  TextColumn get id => text()();

  /// Foreign key to TransactionMedias.id.
  TextColumn get mediaId => text()();

  /// Model version string (e.g. "mlkit-image-labeling-v1").
  TextColumn get modelVersion => text()();

  /// JSON string of detected labels [{name: "coffee", confidence: 0.94}].
  TextColumn get labelsJson => text().withDefault(const Constant('[]'))();

  /// Suggested category ID if any.
  TextColumn get suggestedCategoryId => text().nullable()();

  /// Suggested category confidence (0.0 to 1.0).
  RealColumn get suggestedCategoryConfidence => real().nullable()();

  /// JSON string of detected amounts.
  TextColumn get extractedAmountsJson =>
      text().withDefault(const Constant('[]'))();

  /// Overall inference confidence.
  RealColumn get confidence => real()();

  /// Latency in milliseconds.
  IntColumn get latencyMs => integer()();

  /// Inference source: 'on_device' or 'cloud'.
  TextColumn get source => text().withDefault(const Constant('on_device'))();

  @override
  Set<Column> get primaryKey => {id};
}
