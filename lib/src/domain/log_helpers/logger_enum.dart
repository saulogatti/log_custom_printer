import '../logs_object/error_log.dart';
import '../logs_object/info_log.dart';
import '../logs_object/logger_object.dart';
import '../logs_object/warning_log.dart';
import 'enum_logger_type.dart';

/// Extensão para mapear objetos de log para o enum [EnumLoggerType].
///
/// {@category Utilities}
extension LoggerEnum on LoggerObjectBase {
  /// Retorna o [EnumLoggerType] correspondente ao tipo concreto desta instância.
  ///
  /// Mapeia:
  /// - [ErrorLog] → [EnumLoggerType.error]
  /// - [WarningLog] → [EnumLoggerType.warning]
  /// - [InfoLog] → [EnumLoggerType.info]
  /// - Outros ([DebugLog]) → [EnumLoggerType.debug]
  EnumLoggerType get enumLoggerType {
    if (this is ErrorLog) return EnumLoggerType.error;
    if (this is WarningLog) return EnumLoggerType.warning;
    if (this is InfoLog) return EnumLoggerType.info;
    return EnumLoggerType.debug;
  }
}
