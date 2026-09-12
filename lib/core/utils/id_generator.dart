import 'package:uuid/uuid.dart';

class IdGenerator {
  IdGenerator._();

  static const _uuid = Uuid();

  /// Generate a v4 UUID
  static String generate() => _uuid.v4();

  /// Generate a time-sortable v7 UUID (UUID v7 — monotonic)
  static String generateV7() => _uuid.v7();
}
