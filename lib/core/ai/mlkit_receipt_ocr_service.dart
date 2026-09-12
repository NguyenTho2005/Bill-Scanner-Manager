import 'package:bill_tracker/core/ai/receipt_ocr_service.dart';
import 'package:bill_tracker/core/ai/vietnamese_receipt_parser.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device implementation of [ReceiptOcrService] using Google ML Kit Text Recognition.
class MlKitReceiptOcrService implements ReceiptOcrService {
  /// Creates [MlKitReceiptOcrService] with Latin script recognizer.
  MlKitReceiptOcrService()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<ReceiptExtractionResult> extractReceipt(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _recognizer.processImage(inputImage);

    // Parse the extracted text into structured receipt data
    return VietnameseReceiptParser.parse(recognizedText.text);
  }

  @override
  void dispose() {
    _recognizer.close();
  }
}
