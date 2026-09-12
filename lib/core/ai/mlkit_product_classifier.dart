import 'package:bill_tracker/core/ai/label_to_category_mapper.dart';
import 'package:bill_tracker/core/ai/product_classifier.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// On-device implementation of [ProductClassifier] using Google ML Kit.
class MlKitProductClassifier implements ProductClassifier {
  /// Creates [MlKitProductClassifier].
  MlKitProductClassifier({
    double confidenceThreshold = 0.5,
  }) : _labeler = ImageLabeler(
          options: ImageLabelerOptions(
            confidenceThreshold: confidenceThreshold,
          ),
        );

  final ImageLabeler _labeler;

  static const _modelVersion = 'google_mlkit_image_labeling_v1';

  @override
  Future<ProductClassificationResult> classifyImage(String imagePath) async {
    final stopwatch = Stopwatch()..start();
    final inputImage = InputImage.fromFilePath(imagePath);

    final labels = await _labeler.processImage(inputImage);
    stopwatch.stop();

    final detectedLabels = labels
        .map(
          (l) => DetectedLabel(
            text: l.label,
            confidence: l.confidence,
            index: l.index,
          ),
        )
        .toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    // Map labels to BillTracker category
    final labelMap = {
      for (final l in detectedLabels) l.text: l.confidence,
    };
    final suggestion = LabelToCategoryMapper.mapLabels(labelMap);

    return ProductClassificationResult(
      labels: detectedLabels,
      suggestedCategoryId: suggestion?.categoryId,
      suggestedCategoryConfidence: suggestion?.confidence,
      latencyMs: stopwatch.elapsedMilliseconds,
      modelVersion: _modelVersion,
      source: 'on_device',
    );
  }

  @override
  void dispose() {
    _labeler.close();
  }
}
