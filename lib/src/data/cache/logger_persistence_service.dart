import 'package:log_custom_printer/src/data/cache/logger_cache_repository_impl.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/domain/query/log_filter_engine.dart';
import 'package:log_custom_printer/src/domain/query/log_query.dart';
import 'package:log_custom_printer/src/domain/query/log_sort_engine.dart';

/// Service for log persistence and query operations.
///
/// {@category Utilities}
final class LoggerPersistenceService({
  ILoggerCacheRepository? cacheRepository,

  /// Log filtering engine.
  final LogFilterEngine _filterEngine = const LogFilterEngine(),

  /// Log sorting engine.
  final LogSortEngine _sortEngine = const LogSortEngine(),
}) {
  final ILoggerCacheRepository _cacheRepository = cacheRepository ?? LoggerCacheRepositoryImpl();

  /// Optional callback notified after cache mutations.
  void Function(List<LoggerObjectBase>)? logOutputHandler;

  /// Adds a log entry.
  Future<void> addLog(LoggerObjectBase log) async {
    await _cacheRepository.addLog(log);
    if (logOutputHandler != null) {
      final logs = await _cacheRepository.getAllLogs();
      logOutputHandler?.call(logs);
    }
  }

  /// Clears all log entries.
  Future<void> clearLogs() async {
    logOutputHandler?.call([]);
    await _cacheRepository.clearLogs();
  }

  /// Clears log entries by [type].
  Future<void> clearLogsByType(EnumLoggerType type) async {
    await _cacheRepository.clearLogsByType(type);
    if (logOutputHandler != null) {
      final logs = await _cacheRepository.getAllLogs();
      logOutputHandler?.call(logs);
    }
  }

  /// Returns all stored logs.
  Future<List<LoggerObjectBase>> getAllLogs() async {
    final logs = await _cacheRepository.getAllLogs();
    return logs;
  }

  /// Returns logs filtered by [type].
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) async {
    final logs = await _cacheRepository.getLogsByType(type);
    return logs;
  }

  /// Applies query pipeline: get all -> filter -> sort.
  Future<List<LoggerObjectBase>> queryLogs(LogQuery query) async {
    final allLogs = await getAllLogs();
    final filtered = _filterEngine.apply(allLogs, query);
    return _sortEngine.apply(filtered, query);
  }

  /// Searches logs by creation date range.
  Future<List<LoggerObjectBase>> searchLogByCreated({
    required DateTime start,
    required DateTime end,
  }) async {
    final allLogs = await _cacheRepository.getAllLogs();
    return allLogs
        .where((log) => !log.logCreationDate.isBefore(start) && log.logCreationDate.isBefore(end))
        .toList();
  }

  /// Searches logs by source runtime type.
  Future<List<LoggerObjectBase>> searchLogByRuntimeType(String runtimeType) async {
    final allLogs = await _cacheRepository.getAllLogs();
    return allLogs.where((log) => log.className == runtimeType).toList();
  }

  /// Searches logs by tag.
  Future<List<LoggerObjectBase>> searchLogByTag(String tag) async {
    final allLogs = await _cacheRepository.getAllLogs();
    final tagRegex = RegExp(r'\b' + RegExp.escape(tag) + r'\b');
    return allLogs.where((log) => tagRegex.hasMatch(log.tag)).toList();
  }
}
