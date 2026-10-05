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
  required final ILoggerCacheRepository loggerPersistenceService,

  /// Log filtering engine.
  final LogFilterEngine _filterEngine = const LogFilterEngine(),

  /// Log sorting engine.
  final LogSortEngine _sortEngine = const LogSortEngine(),
}) {
  /// Optional callback notified after cache mutations.
  // FIXME: #80 Migrar para um stream ou evento de logs.
  // void Function(List<LoggerObjectBase>)? logOutputHandler;

  /// Adds a log entry.
  Future<void> addLog(LoggerObjectBase log) async {
    await loggerPersistenceService.addLog(log);
    // if (logOutputHandler != null) {
    //   final logs = await loggerPersistenceService.getAllLogs();
    //   // logOutputHandler?.call(logs);
    // }
  }

  /// Clears all log entries.
  Future<void> clearLogs() async {
    await loggerPersistenceService.clearLogs();
  }

  /// Clears log entries by [type].
  Future<void> clearLogsByType(EnumLoggerType type) async {
    await loggerPersistenceService.clearLogsByType(type);
  }

  /// Returns all stored logs.
  Future<List<LoggerObjectBase>> getAllLogs() async {
    final logs = await loggerPersistenceService.getAllLogs();
    return logs;
  }

  /// Returns logs filtered by [type].
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) async {
    final logs = await loggerPersistenceService.getLogsByType(type);
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
    final allLogs = await loggerPersistenceService.getAllLogs();
    return allLogs
        .where((log) => !log.logCreationDate.isBefore(start) && log.logCreationDate.isBefore(end))
        .toList();
  }

  /// Searches logs by source runtime type.
  Future<List<LoggerObjectBase>> searchLogByRuntimeType(String runtimeType) async {
    final allLogs = await loggerPersistenceService.getAllLogs();
    return allLogs.where((log) => log.className == runtimeType).toList();
  }

  /// Searches logs by tag.
  /// [tag] is the tag to search for.
  /// Returns a list of logs that match the tag.
  Future<List<LoggerObjectBase>> searchLogByTag(String tag) async {
    final allLogs = await loggerPersistenceService.getAllLogs();
    final tagRegex = RegExp(r'\b' + RegExp.escape(tag) + r'\b');
    return allLogs.where((log) => tagRegex.hasMatch(log.tag)).toList();
  }
}
