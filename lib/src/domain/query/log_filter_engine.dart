import '../log_helpers/logger_enum.dart';
import '../logs_object/logger_object.dart';
import 'log_query.dart';

/// Applies type/date filters to log collections.
///
/// {@category Query}
class LogFilterEngine {
  const LogFilterEngine();

  /// Returns logs matching [query] criteria.
  List<LoggerObjectBase> apply(List<LoggerObjectBase> logs, LogQuery query) {
    final filterTypes = query.types != null && query.types!.isNotEmpty ? query.types : null;
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
