import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:bill_tracker/core/errors/failures.dart';
import 'package:bill_tracker/core/storage/image_storage_service.dart';
import 'package:bill_tracker/core/utils/hash_util.dart';
import 'package:bill_tracker/core/utils/id_generator.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local filesystem implementation of [ImageStorageService].
class LocalImageStorageService implements ImageStorageService {
  /// Creates [LocalImageStorageService].
  LocalImageStorageService({
    Future<Directory> Function()? baseDirProvider,
  }) : _baseDirProvider = baseDirProvider ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _baseDirProvider;

  @override
  Future<Directory> getImagesDirectory() async {
    final baseDir = await _baseDirProvider();
    final imagesDir = Directory(p.join(baseDir.path, 'bill_tracker_images'));
    if (!imagesDir.existsSync()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  @override
  Future<StoredImageResult> processAndStoreImage({
    required Uint8List imageBytes,
    required String filePrefix,
    bool keepOriginal = false,
    int maxDimension = 2048,
    int thumbnailSize = 200,
    int jpegQuality = 80,
  }) async {
    final imagesDir = await getImagesDirectory();
    final fileId = '${filePrefix}_${IdGenerator.generate()}';

    // 1. Calculate SHA-256 hash of original bytes for deduplication
    final hash = HashUtil.hashBytes(imageBytes);

    // 2. Decode original image
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw const StorageFailure(message: 'Không thể giải mã tệp hình ảnh');
    }

    // 3. Save original if requested
    String? originalPath;
    if (keepOriginal) {
      final originalFile = File(p.join(imagesDir.path, '${fileId}_orig.jpg'));
      await originalFile.writeAsBytes(imageBytes);
      originalPath = originalFile.path;
    }

    // 4. Resize if longer side exceeds maxDimension
    var compressedImage = decoded;
    final longestSide = math.max(decoded.width, decoded.height);
    if (longestSide > maxDimension) {
      if (decoded.width >= decoded.height) {
        compressedImage = img.copyResize(
          decoded,
          width: maxDimension,
          interpolation: img.Interpolation.linear,
        );
      } else {
        compressedImage = img.copyResize(
          decoded,
          height: maxDimension,
          interpolation: img.Interpolation.linear,
        );
      }
    }

    final compressedBytes = img.encodeJpg(
      compressedImage,
      quality: jpegQuality,
    );
    final compressedFile = File(p.join(imagesDir.path, '$fileId.jpg'));
    await compressedFile.writeAsBytes(compressedBytes);

    // 5. Generate square 200x200 thumbnail
    final thumbnailImage = img.copyResizeCropSquare(
      decoded,
      size: thumbnailSize,
      interpolation: img.Interpolation.linear,
    );
    final thumbnailBytes = img.encodeJpg(thumbnailImage, quality: 75);
    final thumbnailFile = File(p.join(imagesDir.path, '${fileId}_thumb.jpg'));
    await thumbnailFile.writeAsBytes(thumbnailBytes);

    return StoredImageResult(
      originalPath: originalPath,
      compressedPath: compressedFile.path,
      thumbnailPath: thumbnailFile.path,
      hash: hash,
      width: compressedImage.width,
      height: compressedImage.height,
      fileSizeBytes: compressedBytes.length,
    );
  }

  @override
  Future<void> deleteImageFiles({
    required String compressedPath,
    required String thumbnailPath,
    String? originalPath,
  }) async {
    final filesToDelete = [
      compressedPath,
      thumbnailPath,
      if (originalPath != null) originalPath,
    ];

    for (final path in filesToDelete) {
      final file = File(path);
      if (file.existsSync()) {
        try {
          await file.delete();
        } on Exception {
          // File delete failure ignored in cleanup
        }
      }
    }
  }
}
