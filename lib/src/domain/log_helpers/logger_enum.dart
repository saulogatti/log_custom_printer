import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/error_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/info_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/domain/logs_object/warning_log.dart';

/// Maps log objects to [EnumLoggerType].
///
/// {@category Utilities}
extension LoggerEnum on LoggerObjectBase {
  /// Returns enum type for current log instance.
  EnumLoggerType get enumLoggerType {
    if (this is ErrorLog) return EnumLoggerType.error;
    if (this is WarningLog) return EnumLoggerType.warning;
    if (this is InfoLog) return EnumLoggerType.info;
    return EnumLoggerType.debug;
  }
}
