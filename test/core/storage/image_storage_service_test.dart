import 'dart:io';
import 'dart:typed_data';

import 'package:bill_tracker/core/storage/local_image_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory tempDir;
  late LocalImageStorageService storageService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('bt_test_images_');
    storageService = LocalImageStorageService(
      baseDirProvider: () async => tempDir,
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Uint8List createTestImageBytes({int width = 800, int height = 600}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(255, 100, 50));
    return Uint8List.fromList(img.encodeJpg(image));
  }

  group('LocalImageStorageService', () {
    test('processes and stores image with thumbnail and hash', () async {
      final bytes = createTestImageBytes(width: 400, height: 300);
      final result = await storageService.processAndStoreImage(
        imageBytes: bytes,
        filePrefix: 'test',
        keepOriginal: false,
      );

      expect(result.originalPath, isNull);
      expect(File(result.compressedPath).existsSync(), isTrue);
      expect(File(result.thumbnailPath).existsSync(), isTrue);
      expect(result.hash.isNotEmpty, isTrue);
      expect(result.width, 400);
      expect(result.height, 300);

      // Verify thumbnail is 200x200 square
      final thumbBytes = await File(result.thumbnailPath).readAsBytes();
      final decodedThumb = img.decodeImage(thumbBytes);
      expect(decodedThumb, isNotNull);
      expect(decodedThumb!.width, 200);
      expect(decodedThumb.height, 200);
    });

    test('retains original file when keepOriginal is true', () async {
      final bytes = createTestImageBytes(width: 400, height: 300);
      final result = await storageService.processAndStoreImage(
        imageBytes: bytes,
        filePrefix: 'test_keep',
        keepOriginal: true,
      );

      expect(result.originalPath, isNotNull);
      expect(File(result.originalPath!).existsSync(), isTrue);
    });

    test('downscales image if longest side exceeds maxDimension', () async {
      final largeBytes = createTestImageBytes(width: 3000, height: 1500);
      final result = await storageService.processAndStoreImage(
        imageBytes: largeBytes,
        filePrefix: 'large',
        maxDimension: 2048,
      );

      expect(result.width, 2048);
      expect(result.height, 1024);
    });

    test('deleteImageFiles deletes all associated files', () async {
      final bytes = createTestImageBytes();
      final result = await storageService.processAndStoreImage(
        imageBytes: bytes,
        filePrefix: 'to_delete',
        keepOriginal: true,
      );

      expect(File(result.compressedPath).existsSync(), isTrue);
      expect(File(result.thumbnailPath).existsSync(), isTrue);
      expect(File(result.originalPath!).existsSync(), isTrue);

      await storageService.deleteImageFiles(
        compressedPath: result.compressedPath,
        thumbnailPath: result.thumbnailPath,
        originalPath: result.originalPath,
      );

      expect(File(result.compressedPath).existsSync(), isFalse);
      expect(File(result.thumbnailPath).existsSync(), isFalse);
      expect(File(result.originalPath!).existsSync(), isFalse);
    });
  });
}
