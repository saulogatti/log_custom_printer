import 'package:flutter/foundation.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/logs_object/error_log.dart';
import 'package:log_custom_printer/src/logs_object/info_log.dart';
import 'package:log_custom_printer/src/logs_object/warning_log.dart';

/// Configuration for log behavior and filtering.
///
/// Controls whether logs are enabled and which log types should be processed.
///
/// Fields:
/// - [enableLog]: When `true`, logs will be processed. Defaults to [kDebugMode].
/// - [onlyClasses]: Set of log types to be processed. By default, all log types
///   ([DebugLog], [WarningLog], [InfoLog], [ErrorLog]) are included.
class ConfigLog {
  /// Whether logging is enabled.
  final bool enableLog;

  /// Set of log types that should be processed.
  final Set<Type> onlyClasses;

  const ConfigLog({
    this.enableLog = kDebugMode,
    this.onlyClasses = const <Type>{DebugLog, WarningLog, InfoLog, ErrorLog},
  });
}
