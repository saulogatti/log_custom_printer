import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';

/// Formato de exportação de logs.
///
/// {@category Core}
enum ExportFormat {
  /// Exporta como JSON (array de objetos).
  json,

  /// Exporta como texto legível (uma linha por log).
  txt,
}

/// Contrato para persistência e consulta de logs.
///
/// Define as operações mínimas para armazenar, recuperar e limpar
/// objetos de log no cache da biblioteca.
///
/// Implementações podem usar apenas memória, arquivo local, banco de dados
/// ou qualquer outro backend, desde que respeitem as assinaturas e o
/// comportamento assíncrono descrito aqui.
///
/// {@category Core}
abstract interface class ILoggerCacheRepository {
  /// Adiciona uma entrada de log ao repositório.
  ///
  /// [log] é o objeto que será persistido.
  Future<void> addLog(LoggerObjectBase log);

  /// Remove todas as entradas de log do repositório.
  Future<void> clearLogs();

  /// Remove entradas de log de um tipo específico.
  ///
  /// [type] define a severidade alvo da remoção.
  Future<void> clearLogsByType(EnumLoggerType type);

  /// Exporta todas as entradas de log armazenadas.
  Future<void> exportLogs(List<LoggerObjectBase> logs, ExportFormat format);

  /// Recupera todas as entradas de log armazenadas.
  Future<List<LoggerObjectBase>> getAllLogs();

  /// Recupera entradas de log filtradas por tipo.
  ///
  /// [type] define a severidade usada no filtro.
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type);

  /// Importa todas as entradas de log armazenadas.
  Future<void> importLogs(String content, ExportFormat format);
}
