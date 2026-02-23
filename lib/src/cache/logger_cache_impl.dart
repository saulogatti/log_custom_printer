import 'package:log_custom_printer/src/cache/logger_cache_repository.dart';
import 'package:log_custom_printer/src/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/log_helpers/log_display_handler.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

final class LoggerCacheImpl implements LoggerCacheRepository {
  final Map<EnumLoggerType, LoggerJsonList?> _loggerJsonList = {};
  @override
  void addLog(LoggerObjectBase log) {
    LoggerJsonList? loggerList = _loggerJsonList[log.enumLoggerType];
    if (loggerList == null) {
      loggerList = LoggerJsonList(type: log.runtimeType.toString());
      _loggerJsonList[log.enumLoggerType] = loggerList;
    }
    loggerList.addLogger(log);
  }

  @override
  void clearLogs() {
    _loggerJsonList.clear();
  }

  @override
  void clearLogsByType(EnumLoggerType type) {
    _loggerJsonList.remove(type);
  }

  @override
  List<LoggerObjectBase> getAllLogs() {
    final List<LoggerObjectBase> allLogs = [];
    for (final loggerList in _loggerJsonList.values) {
      if (loggerList != null) {
        allLogs.addAll(loggerList.loggerEntries);
      }
    }
    return allLogs;
  }

  @override
  List<LoggerObjectBase> getLogsByType(EnumLoggerType type) {
    final loggerList = _loggerJsonList[type];
    if (loggerList != null) {
      // A lista internamente devolve uma nova instância para evitar modificações externas, então podemos retornar diretamente.
      return (loggerList.loggerEntries);
    }
    return [];
  }
}
