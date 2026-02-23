import '../log_helpers/enum_logger_type.dart';
import '../log_printer_service.dart';
import '../logs_object/logger_object.dart';

/// Interface para repositório de cache de logs.
///
/// Define as operações básicas para armazenamento, recuperação e limpeza de logs.
/// Caso queira personalizar o armazenamento dos logs (ex: usar um banco de dados local,
/// SharedPreferences, etc.), implemente esta interface e forneça a implementação
/// personalizada para o [LogPrinterService] via [registerLogPrinter].
///
/// {@category Utilities}
abstract interface class LoggerCacheRepository {
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
