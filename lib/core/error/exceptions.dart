class LocalDbException implements Exception {
  const LocalDbException(this.message);

  final String message;

  @override
  String toString() => 'LocalDbException: $message';
}

class SupabaseException implements Exception {
  const SupabaseException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'SupabaseException: $message';
}

class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AuthException: $message';
}
