import 'dart:io';
import 'dart:typed_data';

/// Result of processing and storing an image.
class StoredImageResult {
  /// Creates [StoredImageResult].
  const StoredImageResult({
    required this.compressedPath,
    required this.thumbnailPath,
    required this.hash,
    required this.width,
    required this.height,
    required this.fileSizeBytes,
    this.originalPath,
  });

  /// Path to original file (null if user chose not to store original).
  final String? originalPath;

  /// Path to compressed file (longest side <= 2048px).
  final String compressedPath;

  /// Path to 200x200 thumbnail.
  final String thumbnailPath;

  /// SHA-256 hash of the image content.
  final String hash;

  /// Width in pixels of compressed image.
  final int width;

  /// Height in pixels of compressed image.
  final int height;

  /// File size in bytes of compressed image.
  final int fileSizeBytes;
}

/// Abstract image storage and compression service.
abstract class ImageStorageService {
  /// Processes raw image bytes or file, compresses to max [maxDimension] px,
  /// generates a 200x200 thumbnail, calculates SHA-256 hash, and saves to disk.
  Future<StoredImageResult> processAndStoreImage({
    required Uint8List imageBytes,
    required String filePrefix,
    bool keepOriginal = false,
    int maxDimension = 2048,
    int thumbnailSize = 200,
    int jpegQuality = 80,
  });

  /// Deletes all files associated with a stored image result.
  Future<void> deleteImageFiles({
    required String compressedPath,
    required String thumbnailPath,
    String? originalPath,
  });

  /// Gets the directory where images are saved.
  Future<Directory> getImagesDirectory();
}
