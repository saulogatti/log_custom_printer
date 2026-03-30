import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/domain/query/log_filter_engine.dart';
import 'package:log_custom_printer/src/domain/query/log_query.dart';
import 'package:log_custom_printer/src/domain/query/log_sort_engine.dart';

/// Fachada que aplica filtros e ordenação a uma lista de logs usando
/// [LogFilterEngine] e [LogSortEngine] com base em uma [LogQuery].
///
/// Delega ao engine apropriado conforme os critérios presentes na query:
/// - Se [LogQuery.types] não estiver vazio, aplica filtragem por tipo.
/// - Caso contrário, aplica ordenação conforme [LogQuery.sortDirection].
class LoggerFilter {
  /// Query com os critérios de filtragem e/ou ordenação.
  LogQuery query;

  /// Cria o filtro com a [query] fornecida.
  LoggerFilter({required this.query});

  /// Aplica filtragem e/ou ordenação a [logs] conforme a [query].
  ///
  /// Retorna os [logs] sem modificação se nenhum critério estiver definido.
  List<LoggerObjectBase> apply(List<LoggerObjectBase> logs) {
    if (query.types != null && query.types!.isNotEmpty) {
      return const LogFilterEngine().apply(logs, query);
    } else if (query.sortDirection == SortDirection.asc) {
      return const LogSortEngine().apply(logs, query);
    } else if (query.sortDirection == SortDirection.desc) {
      return const LogSortEngine().apply(logs, query);
    } else {
      return logs;
    }
  }
}
