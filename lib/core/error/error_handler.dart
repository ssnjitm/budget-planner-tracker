import 'dart:io';

import 'exceptions.dart';
import 'failures.dart';

Failure handleError(Object error, [StackTrace? stackTrace]) {
  if (error is Failure) {
    return error;
  }
  if (error is ValidationException) {
    return ValidationFailure(error.message);
  }
  if (error is LocalDbException) {
    return CacheFailure(error.message);
  }
  if (error is AuthException) {
    return AuthFailure(error.message, statusCode: error.statusCode);
  }
  if (error is SupabaseException) {
    return ServerFailure(error.message, statusCode: error.statusCode);
  }
  if (error is SocketException) {
    return const NetworkFailure('No internet connection');
  }
  return UnexpectedFailure(error.toString());
}
