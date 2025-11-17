import 'package:flutter/foundation.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/logs_object/error_log.dart';
import 'package:log_custom_printer/src/logs_object/info_log.dart';
import 'package:log_custom_printer/src/logs_object/warning_log.dart';

class ConfigLog {
  final bool enableLog;
  final Set<Type> onlyClasses;
  const ConfigLog({this.enableLog = kDebugMode, Set<Type>? onlyClasses})
    : onlyClasses = onlyClasses ?? const <Type>{DebugLog, WarningLog, InfoLog, ErrorLog};
}
