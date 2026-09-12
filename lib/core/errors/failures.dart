/// Base failure class for domain layer errors
abstract class Failure implements Exception {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'Failure($code): $message';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

class SecurityFailure extends Failure {
  const SecurityFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

class CameraFailure extends Failure {
  const CameraFailure({required super.message, super.code});
}

class AIInferenceFailure extends Failure {
  const AIInferenceFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}
