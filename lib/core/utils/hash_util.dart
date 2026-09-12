import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class HashUtil {
  HashUtil._();

  /// SHA-256 hash of file bytes (for image dedup)
  static Future<String> hashFile(File file) async {
    final bytes = await file.readAsBytes();
    return hashBytes(bytes);
  }

  /// SHA-256 hash of bytes
  static String hashBytes(Uint8List bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// SHA-256 hash of a string
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
