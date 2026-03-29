import 'dart:convert';

import '../logs_object/logger_object.dart';
import 'log_query.dart';

/// Serializa uma lista de logs para os formatos [ExportFormat.json] ou
/// [ExportFormat.txt] em memória (retorna uma [String]).
///
/// Nenhum arquivo é escrito por esta classe; a decisão de persistência ou
/// compartilhamento fica a cargo da camada consumidora.
///
/// {@category Query}
class LogExportService {
  const LogExportService();

  /// Exporta [logs] no [format] especificado e retorna o conteúdo como string.
  String export(List<LoggerObjectBase> logs, ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return _exportJson(logs);
      case ExportFormat.txt:
        return _exportTxt(logs);
    }
  }

  /// Gera um array JSON onde cada elemento inclui a chave `"logType"` com o
  /// nome da classe do log (ex: `"DebugLog"`) seguido de todos os campos
  /// retornados por [LoggerObjectBase.toJson].
  String _exportJson(List<LoggerObjectBase> logs) {
    final list = logs.map((log) {
      return <String, dynamic>{
        'logType': log.runtimeType.toString(),
        ...log.toJson(),
      };
    }).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  /// Gera uma linha de texto por log no formato:
  /// `[LogType] ISO8601Date ClassName Message`
  ///
  /// Exemplo:
  /// ```
  /// [DebugLog] 2024-01-15T10:30:00.000 MyService operação concluída
  /// ```
  String _exportTxt(List<LoggerObjectBase> logs) {
    return logs
        .map(
          (log) =>
              '[${log.runtimeType}] '
              '${log.logCreationDate.toIso8601String()} '
              '${log.className} '
              '${log.message}',
        )
        .join('\n');
  }
}
