import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/log_helpers/logger_enum.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/domain/query/log_query.dart';

/// Sorts logs using [LogQuery] parameters.
///
/// {@category Query}
class LogSortEngine {
  static const Map<EnumLoggerType, int> _severityIndex = {
    EnumLoggerType.debug: 0,
    EnumLoggerType.info: 1,
    EnumLoggerType.warning: 2,
    EnumLoggerType.error: 3,
  };

  const LogSortEngine();

  /// Returns a sorted copy based on [query].
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
        primary = typeCmp != 0 ? typeCmp : a.logCreationDate.compareTo(b.logCreationDate);
      }

      return query.sortDirection == SortDirection.asc ? primary : -primary;
    });

    return sorted;
  }
}
