import '../log_helpers/logger_enum.dart';
import '../logs_object/logger_object.dart';
import 'log_query.dart';

/// Aplica filtros de tipo e intervalo de data a uma lista de logs.
///
/// {@category Query}
class LogFilterEngine {
  const LogFilterEngine();

  /// Retorna uma nova lista contendo apenas os logs que satisfazem os
  /// critérios definidos em [query].
  ///
  /// - Filtro de tipo: mantém apenas logs cujo [EnumLoggerType] esteja
  ///   em [LogQuery.types]. Quando `types` é `null` ou vazio, nenhum log
  ///   é descartado por tipo.
  /// - Filtro de data: intervalo `[start, end)` aplicado a
  ///   [LoggerObjectBase.logCreationDate].
  ///
  /// Todos os predicados são avaliados em uma única passagem para evitar
  /// alocações intermediárias desnecessárias.
  List<LoggerObjectBase> apply(List<LoggerObjectBase> logs, LogQuery query) {
    final filterTypes = query.types != null && query.types!.isNotEmpty
        ? query.types
        : null;
    final start = query.start;
    final end = query.end;

    if (filterTypes == null && start == null && end == null) return logs;

    return logs.where((log) {
      if (filterTypes != null && !filterTypes.contains(log.enumLoggerType)) {
        return false;
      }
      if (start != null && log.logCreationDate.isBefore(start)) return false;
      if (end != null && !log.logCreationDate.isBefore(end)) return false;
      return true;
    }).toList();
  }
}
