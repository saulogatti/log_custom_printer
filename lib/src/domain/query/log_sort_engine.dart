import '../log_helpers/enum_logger_type.dart';
import '../log_helpers/logger_enum.dart';
import '../logs_object/logger_object.dart';
import 'log_query.dart';

/// Ordena uma lista de logs com base nos parâmetros de [LogQuery].
///
/// Ordem de severidade para [LogSortField.type] (crescente):
/// `debug(0) < info(1) < warning(2) < error(3)`.
///
/// Quando dois logs possuem o mesmo campo de ordenação primária, o desempate
/// é feito pela data de criação (crescente), garantindo estabilidade.
///
/// {@category Query}
class LogSortEngine {

  const LogSortEngine();
  static const Map<EnumLoggerType, int> _severityIndex = {
    EnumLoggerType.debug: 0,
    EnumLoggerType.info: 1,
    EnumLoggerType.warning: 2,
    EnumLoggerType.error: 3,
  };

  /// Retorna uma nova lista ordenada de acordo com [query].
  ///
  /// Quando [LogQuery.sortField] é `null`, a lista original é retornada
  /// sem modificação.
  List<LoggerObjectBase> apply(List<LoggerObjectBase> logs, LogQuery query) {
    if (query.sortField == null) return logs;

    final sorted = List<LoggerObjectBase>.from(logs);
    sorted.sort((a, b) {
      final int primary;

      if (query.sortField == LogSortField.date) {
        primary = a.logCreationDate.compareTo(b.logCreationDate);
      } else {
        final aSeverity = _severityIndex[a.enumLoggerType] ?? 0;
        final bSeverity = _severityIndex[b.enumLoggerType] ?? 0;
        final typeCmp = aSeverity.compareTo(bSeverity);
        // Stable tiebreaker by date (asc) when severity is equal.
        primary = typeCmp != 0
            ? typeCmp
            : a.logCreationDate.compareTo(b.logCreationDate);
      }

      return query.sortDirection == SortDirection.asc ? primary : -primary;
    });

    return sorted;
  }
}
