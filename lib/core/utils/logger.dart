import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, {String tag = 'SolveLens'}) {
    if (kDebugMode) {
      print('[] $message');
    }
  }

  static void error(String message, {String tag = 'SolveLens', Object? error}) {
    if (kDebugMode) {
      print('[] ERROR: $message');
      if (error != null) print('Details: $error');
    }
  }
}