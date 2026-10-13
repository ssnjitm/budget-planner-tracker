import 'dart:developer' as developer;

abstract final class LoggerService {
  static void info(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(800, 'INFO', message, error, stackTrace);

  static void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(900, 'WARN', message, error, stackTrace);

  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(1000, 'ERROR', message, error, stackTrace);

  static void debug(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(500, 'DEBUG', message, error, stackTrace);

  static void _log(
    int level,
    String label,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    developer.log(
      message,
      name: 'PocketBudget.$label',
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
