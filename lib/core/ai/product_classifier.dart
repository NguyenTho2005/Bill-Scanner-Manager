import 'package:equatable/equatable.dart';

/// Single detected label with confidence score.
class DetectedLabel extends Equatable {
  /// Creates [DetectedLabel].
  const DetectedLabel({
    required this.text,
    required this.confidence,
    this.index,
  });

  /// The label text (e.g. "Coffee").
  final String text;

  /// Confidence score between 0.0 and 1.0.
  final double confidence;

  /// Optional model index.
  final int? index;

  @override
  List<Object?> get props => [text, confidence, index];
}

/// Output result from a product classification inference run.
class ProductClassificationResult extends Equatable {
  /// Creates [ProductClassificationResult].
  const ProductClassificationResult({
    required this.labels,
    required this.latencyMs,
    required this.modelVersion,
    this.suggestedCategoryId,
    this.suggestedCategoryConfidence,
    this.source = 'on_device',
  });

  /// All detected labels from the vision model.
  final List<DetectedLabel> labels;

  /// Category suggested by rules/classifier (null if below confidence threshold).
  final String? suggestedCategoryId;

  /// Confidence of the suggested category.
  final double? suggestedCategoryConfidence;

  /// Latency of inference in milliseconds.
  final int latencyMs;

  /// Model name and version identifier.
  final String modelVersion;

  /// Source of inference ('on_device' or 'cloud').
  final String source;

  @override
  List<Object?> get props => [
        labels,
        suggestedCategoryId,
        suggestedCategoryConfidence,
        latencyMs,
        modelVersion,
        source,
      ];
}

/// Abstract contract for product visual classification.
abstract class ProductClassifier {
  /// Analyzes an image at [imagePath] and returns classification results.
  Future<ProductClassificationResult> classifyImage(String imagePath);

  /// Releases ML resources when no longer needed.
  void dispose();
}
