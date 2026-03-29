import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';

abstract interface class ILoggerCacheRepository {
  /// Adiciona uma entrada de log ao repositório.
  Future<void> addLog(LoggerObjectBase log);

  /// Remove todas as entradas de log do repositório.
  Future<void> clearLogs();

  /// Remove entradas de log de um tipo específico.
  Future<void> clearLogsByType(EnumLoggerType type);

  /// Recupera todas as entradas de log armazenadas.
  Future<List<LoggerObjectBase>> getAllLogs();

  /// Recupera entradas de log filtradas por tipo.
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type);
}
