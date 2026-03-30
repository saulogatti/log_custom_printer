import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/domain/query/log_filter_engine.dart';
import 'package:log_custom_printer/src/domain/query/log_query.dart';
import 'package:log_custom_printer/src/domain/query/log_sort_engine.dart';

class LoggerFilter {
  LogQuery query;
  LoggerFilter({required this.query});
  // sabe quem executa o filtro
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
