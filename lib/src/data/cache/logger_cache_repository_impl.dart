import 'package:log_custom_printer/src/data/cache/logger_cache.dart';
import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/log_helpers/logger_enum.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';

/// Default [ILoggerCacheRepository] implementation with in-memory and optional file storage.
///
/// {@category Utilities}
final class LoggerCacheRepositoryImpl implements ILoggerCacheRepository {
  /// Maximum number of entries per log type.
  final int maxLogEntries;

  /// Optional base directory for file persistence.
  final String? directoryToSave;

  /// File cache manager.
  LoggerCache? _loggerCache;

  /// In-memory map of logs by type.
  Map<EnumLoggerType, LoggerJsonList?> _loggerJsonList = {};

  /// Tracks persistent cache initialization.
  Future<void>? _futureInitialization;

  /// Creates a cache repository instance.
  LoggerCacheRepositoryImpl({this.maxLogEntries = 1000, this.directoryToSave}) {
    if (directoryToSave != null) {
      _loggerCache = LoggerCache(directoryToSave!, fileManagerType: FileManager());
      _futureInitialization = _initialize();
    }
  }

  /// Adds [log] to memory cache and optionally persists to disk.
  @override
  Future<void> addLog(LoggerObjectBase log) async {
    await _futureInitialization;
    var loggerList = _loggerJsonList[log.enumLoggerType];
    if (loggerList == null) {
      loggerList = LoggerJsonList(type: log.runtimeType.toString(), maxLogEntries: maxLogEntries);
      _loggerJsonList[log.enumLoggerType] = loggerList;
    }
    loggerList.addLogger(log);
    if (_loggerCache != null) {
      await _futureInitialization;
      await _loggerCache!.writeLogToFile(log.enumLoggerType.name, loggerList);
    }
  }

  /// Clears all logs from memory and disk (when enabled).
  @override
  Future<void> clearLogs() async {
    await _futureInitialization;
    _loggerJsonList.clear();

    await _loggerCache?.clearAll();
  }

  /// Clears logs only for [type].
  @override
  Future<void> clearLogsByType(EnumLoggerType type) async {
    await _futureInitialization;
    _loggerJsonList.remove(type);

    await _loggerCache?.clearLogByType(type.name);
  }

  @override
  Future<List<LoggerObjectBase>> getAllLogs() async {
    await _futureInitialization;
    final allLogs = <LoggerObjectBase>[];
    for (final loggerList in _loggerJsonList.values) {
      if (loggerList != null) {
        allLogs.addAll(loggerList.loggerEntries);
      }
    }
    return allLogs;
  }

  /// Returns logs only for [type].
  @override
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) async {
    await _futureInitialization;
    final loggerList = _loggerJsonList[type];
    if (loggerList != null) {
      return loggerList.loggerEntries;
    }
    return [];
  }

  /// Imports logs from raw content.
  @override
  Future<void> importLogs(String content, ExportFormat format) {
    throw UnimplementedError();
  }

  /// Loads persisted logs from disk into memory.
  Future<void> _initialize() async {
    if (_loggerCache != null && !_loggerCache!.futureInitialization.isCompleted) {
      await _loggerCache!.futureInitialization.future;
      final allLogs = await _loggerCache!.readAllLogs();
      if (allLogs != null) {
        _loggerJsonList = allLogs;
      }
    }
  }
}
