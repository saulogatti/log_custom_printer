import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';

/// Log export format.
///
/// {@category Core}
enum ExportFormat {
  /// JSON array output.
  json,

  /// Plain text output (one log per line).
  txt,
}

/// Contract for log persistence and query operations.
///
/// {@category Core}
abstract interface class ILoggerCacheRepository {
  /// Adds a log entry.
  Future<void> addLog(LoggerObjectBase log);

  /// Removes all logs.
  Future<void> clearLogs();

  /// Removes logs by severity type.
  Future<void> clearLogsByType(EnumLoggerType type);

  /// Returns all stored logs.
  Future<List<LoggerObjectBase>> getAllLogs();

  /// Returns logs filtered by severity type.
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type);

  /// Maximum number of entries per log type.
  int getMaxLogEntries();

  /// Imports log entries from raw [content] and [format].
  Future<void> importLogs(String content, ExportFormat format);
}
