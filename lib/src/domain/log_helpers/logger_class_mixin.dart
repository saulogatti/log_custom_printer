import 'package:log_custom_printer/src/domain/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/error_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/info_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/domain/logs_object/warning_log.dart';

/// Mixin that provides convenience logging methods for classes.
///
/// {@category Utilities}
mixin LoggerClassMixin {
  /// Runtime type used as source metadata for emitted logs.
  Type get logClassType => runtimeType;

  /// Emits a debug log.
  void logDebug(String message) {
    final log = DebugLog(message, typeClass: logClassType);
    _sendLog(log);
  }

  /// Emits an error log with stack trace.
  void logError(String message, StackTrace stackTrace) {
    final log = ErrorLog(message, stackTrace, typeClass: logClassType);
    _sendLog(log);
  }

  /// Emits an info log.
  void logInfo(String message) {
    final log = InfoLog(message, typeClass: logClassType);
    _sendLog(log);
  }

  /// Emits a warning log.
  void logWarning(String message) {
    final log = WarningLog(message, typeClass: logClassType);
    _sendLog(log);
  }

  /// Internal dispatch helper.
  void _sendLog(LoggerObjectBase log) {
    log.sendLog();
  }
}
