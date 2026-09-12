import 'package:equatable/equatable.dart';

/// Type of media attached to a transaction.
enum MediaType {
  /// Product snapshot.
  product,

  /// Receipt or bill photo.
  receipt,

  /// Payment transfer or invoice screenshot.
  screenshot,
}

/// Domain entity representing media (image) attached to a transaction.
class TransactionMedia extends Equatable {
  /// Creates a [TransactionMedia].
  const TransactionMedia({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.compressedPath,
    required this.thumbnailPath,
    required this.hash,
    this.originalPath,
    this.width,
    this.height,
    this.fileSizeBytes,
    this.capturedAt,
  });

  /// Unique identifier.
  final String id;

  /// Foreign key to Transaction.id.
  final String transactionId;

  /// Media classification: product, receipt, or screenshot.
  final MediaType type;

  /// Path to original photo (null if user chose not to store original).
  final String? originalPath;

  /// Path to compressed photo (max 2048px).
  final String compressedPath;

  /// Path to 200x200 square thumbnail.
  final String thumbnailPath;

  /// SHA-256 hash for deduplication.
  final String hash;

  /// Image width in pixels.
  final int? width;

  /// Image height in pixels.
  final int? height;

  /// Size of compressed image in bytes.
  final int? fileSizeBytes;

  /// Timestamp when photo was captured.
  final DateTime? capturedAt;

  @override
  List<Object?> get props => [
        id,
        transactionId,
        type,
        originalPath,
        compressedPath,
        thumbnailPath,
        hash,
        width,
        height,
        fileSizeBytes,
        capturedAt,
      ];
}
