import 'package:log_custom_printer/src/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';
/// Interface para repositório de cache de logs.
/// Define as operações básicas para armazenamento, recuperação e limpeza de logs.
/// Caso queira personalizar o armazenamento dos logs (ex: usar um banco de dados local, SharedPreferences, etc.), implemente esta interface e forneça a implementação personalizada para o LogDisplayHandler.
abstract interface class LoggerCacheRepository {
  void addLog(LoggerObjectBase log);
  List<LoggerObjectBase> getAllLogs();
  void clearLogs();
  List<LoggerObjectBase> getLogsByType(EnumLoggerType type);
  void clearLogsByType(EnumLoggerType type);
}