import 'package:bill_tracker/core/ai/price_text_extractor.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device price OCR for the Product Snap flow (§4.6 #15).
///
/// Runs ML Kit Latin text recognition on the same stored image that the
/// image labeler sees, then extracts VND-style price candidates with
/// [PriceTextExtractor]. Purely additive: when no confident candidate is
/// found the caller keeps manual amount entry.
class MlKitPriceOcrService {
  /// Creates the service with a Latin script recognizer.
  MlKitPriceOcrService()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  static const _modelVersion = 'google_mlkit_text_recognition_v1';

  /// Recognizes [imagePath] and returns price candidates.
  Future<PriceOcrResult> readPrices(String imagePath) async {
    final stopwatch = Stopwatch()..start();
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _recognizer.processImage(inputImage);
    stopwatch.stop();

    return PriceTextExtractor.buildResult(
      recognizedText.text,
      stopwatch.elapsedMilliseconds,
    );
  }

  /// Model version string for inference audit rows.
  String get modelVersion => _modelVersion;

  /// Releases OCR resources.
  void dispose() {
    _recognizer.close();
  }
}
