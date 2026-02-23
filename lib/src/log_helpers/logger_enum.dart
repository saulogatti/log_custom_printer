import 'package:log_custom_printer/log_custom_printer.dart';

/// Extensão para mapear objetos de log para o enum [EnumLoggerType].
///
/// {@category Utilities}
extension LoggerEnum on LoggerObjectBase {
  EnumLoggerType get enumLoggerType {
    if (this is ErrorLog) return EnumLoggerType.error;
    if (this is WarningLog) return EnumLoggerType.warning;
    if (this is InfoLog) return EnumLoggerType.info;
    return EnumLoggerType.debug;
  }
}
