import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('WARN: $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
    }
  }
}
