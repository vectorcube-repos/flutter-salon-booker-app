import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// App-wide logger that wraps the `logger` package and optionally forwards
/// errors to Firebase Crashlytics.
///
/// Expected `.env` flags:
/// - `ENABLE_LOGGING=true|false`
/// - `SEND_ERRORS_TO_CRASHLYTICS=true|false`
///
/// Use the `forceLog` parameter on any log method to bypass `ENABLE_LOGGING`.
class AppLogger {
  AppLogger({
    Logger? logger,
    FirebaseCrashlytics? crashlytics,
    bool? enableLogging,
    bool? sendErrorsToCrashlytics,
  }) : _logger = logger ?? Logger(),
       _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
       _enableLogging = enableLogging ?? _readBool('ENABLE_LOGGING'),
       _sendErrorsToCrashlytics =
           sendErrorsToCrashlytics ?? _readBool('SEND_ERRORS_TO_CRASHLYTICS');

  final Logger _logger;
  final FirebaseCrashlytics _crashlytics;
  final bool _enableLogging;
  final bool _sendErrorsToCrashlytics;

  static bool _readBool(String key) {
    final value = dotenv.env[key];
    if (value == null) return false;
    return value.toLowerCase() == 'true';
  }

  bool _shouldLog(bool forceLog) => forceLog || _enableLogging;

  void log(String message, {bool forceLog = false}) {
    if (_shouldLog(forceLog)) {
      _logger.d(message);
    }
  }

  void logInfo(String message, {bool forceLog = false}) {
    if (_shouldLog(forceLog)) {
      _logger.i(message);
    }
  }

  void logAlert(String message, {bool forceLog = false}) {
    if (_shouldLog(forceLog)) {
      _logger.w(message);
    }
  }

  void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    bool forceLog = false,
  }) {
    if (_shouldLog(forceLog)) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }

    if (_sendErrorsToCrashlytics) {
      final errObject = error ?? Exception(message);
      _crashlytics.recordError(
        errObject,
        stackTrace ?? StackTrace.current,
        reason: message,
      );

      _crashlytics.log("Higgs-Boson detected! Bailing out");
    }
  }
}
