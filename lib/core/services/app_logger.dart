import 'package:flutter/foundation.dart';

class AppLogger {
  static const _sensitiveKeys = <String>[
    'authorization',
    'token',
    'password',
    'secret',
    'client_secret',
    'api_key',
  ];

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] ${_sanitize(message)}');
    }
  }

  static void warn(String message) {
    if (kDebugMode) {
      debugPrint('[WARN] ${_sanitize(message)}');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final safeMessage = _sanitize(message);
      final safeError = error == null
          ? ''
          : ' | ${_sanitize(error.toString())}';
      debugPrint('[ERROR] $safeMessage$safeError');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }

  static String _sanitize(String input) {
    var output = input;
    for (final key in _sensitiveKeys) {
      final pattern = RegExp('$key\\s*[:=]\\s*[^,\\s]+', caseSensitive: false);
      output = output.replaceAllMapped(pattern, (match) => '$key=[REDACTED]');
    }
    return output;
  }
}
