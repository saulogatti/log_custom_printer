import 'package:log_custom_printer/src/cache/logger_cache.dart';
import 'package:log_custom_printer/src/cache/logger_cache_repository.dart';
import 'package:log_custom_printer/src/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/log_helpers/logger_enum.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

/// Implementação concreta de [LoggerCacheRepository] usando armazenamento em memória e opcionalmente em arquivo.
/// Guarda os logs em memoria e caso seja configurado, também salva em arquivo usando [LoggerCache].
final class LoggerCacheImpl implements LoggerCacheRepository {
  final int maxLogEntries;

  final String? saveLogFilePath;
  LoggerCache? _loggerCache;
  final Map<EnumLoggerType, LoggerJsonList?> _loggerJsonList = {};
  Future<void>? _futureInitialization;
  LoggerCacheImpl({this.maxLogEntries = 1000, this.saveLogFilePath}) {
    if (saveLogFilePath != null) {
      _loggerCache = LoggerCache(saveLogFilePath!);
      _futureInitialization = initialize();
    }
  }
  @override
  Future<void> addLog(LoggerObjectBase log) async {
    LoggerJsonList? loggerList = _loggerJsonList[log.enumLoggerType];
    if (loggerList == null) {
      loggerList = LoggerJsonList(type: log.runtimeType.toString(), maxLogEntries: maxLogEntries);
      _loggerJsonList[log.enumLoggerType] = loggerList;
    }
    loggerList.addLogger(log);
    if (_loggerCache != null) {
      await _futureInitialization; // Garante que a inicialização do cache foi concluída antes de tentar escrever
      await _loggerCache!.writeLogToFile(log.enumLoggerType.name, loggerList);
    }
  }

  @override
  Future<void> clearLogs() async {
    _loggerJsonList.clear();
    await _futureInitialization;
    await _loggerCache?.clearAll();
  }

  @override
  Future<void> clearLogsByType(EnumLoggerType type) async {
    _loggerJsonList.remove(type);
    await _futureInitialization;
    await _loggerCache?.clearLogByType(type.name);
  }

  @override
  Future<List<LoggerObjectBase>> getAllLogs() async {
    final List<LoggerObjectBase> allLogs = [];
    for (final loggerList in _loggerJsonList.values) {
      if (loggerList != null) {
        allLogs.addAll(loggerList.loggerEntries);
      }
    }
    return allLogs;
  }

  @override
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) async {
    final loggerList = _loggerJsonList[type];
    if (loggerList != null) {
      return (loggerList.loggerEntries);
    }
    return [];
  }

  Future<void> initialize() async {
    if (_loggerCache != null) {
      await _loggerCache!.futureInitialization;
      final allLogs = await _loggerCache!.readAllLogs();
      if (allLogs != null) {
        _loggerJsonList.clear();
        _loggerJsonList.addAll(allLogs);
      }
    }
  }
}
