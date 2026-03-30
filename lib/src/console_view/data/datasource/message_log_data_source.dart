import 'package:flutter/material.dart' show DateTimeRange;
import 'package:log_custom_printer/src/console_view/data/entry/message_entry.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/data/cache/logger_persistence_service.dart';
import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/log_helpers/logger_enum.dart';

class MessageLogDataSource {
  LoggerPersistenceService loggerCacheRepositoryImpl;
  MessageLogDataSource({required this.loggerCacheRepositoryImpl});

  Future<void> clearMessages() async {
    await loggerCacheRepositoryImpl.clearLogs();
  }

  Future<List<MessageLog>> getFilterMessages({
    LogType? logType,
    String? searchText,
    DateTimeRange? dateTimeRange,
    bool isDateTimeFilterEnabled = false,
  }) async {
    // `LogType.all` significa "sem filtro por tipo".
    final typeLog = switch (logType) {
      LogType.info => EnumLoggerType.info,
      LogType.warning => EnumLoggerType.warning,
      LogType.error => EnumLoggerType.error,
      LogType.debug => EnumLoggerType.debug,
      LogType.all || null => null,
    };

    final shouldApplyDateTimeFilter =
        isDateTimeFilterEnabled && _isValidDateTimeRange(dateTimeRange);
    final normalizedSearchText = searchText?.trim();
    final hasSearchText =
        normalizedSearchText != null && normalizedSearchText.isNotEmpty;

    if (typeLog == null && !hasSearchText && !shouldApplyDateTimeFilter) {
      return getMessages();
    }

    final logs = await loggerCacheRepositoryImpl.getAllLogs();
    final filteredLogs = logs
        .where((log) {
          if (typeLog != null && log.enumLoggerType != typeLog) {
            return false;
          }

          if (hasSearchText && !log.message.contains(normalizedSearchText)) {
            return false;
          }

          if (shouldApplyDateTimeFilter) {
            final start = dateTimeRange!.start;
            final end = dateTimeRange.end;
            final logDate = log.logCreationDate;
            if (logDate.isBefore(start) || logDate.isAfter(end)) {
              return false;
            }
          }

          return true;
        })
        .map((e) => MessageEntry(loggerObjectBase: e).fromLoggerObjectBase());

    return filteredLogs.toList();
  }

  Future<List<MessageLog>> getMessages() async {
    final logs = await loggerCacheRepositoryImpl.getAllLogs();
    return logs
        .map((e) => MessageEntry(loggerObjectBase: e).fromLoggerObjectBase())
        .toList();
  }

  bool _isValidDateTimeRange(DateTimeRange? range) {
    if (range == null) {
      return false;
    }
    return range.end.difference(range.start).inMilliseconds > 0;
  }
}
