import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/console_view/data/entry/message_entry.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

class MessageLogDataSource {
  LoggerPersistenceService loggerCacheRepositoryImpl;
  MessageLogDataSource({required this.loggerCacheRepositoryImpl});

  Future<void> clearMessages() async {
    await loggerCacheRepositoryImpl.clearLogs();
  }

  Future<List<MessageLog>> getFilterMessages({
    LogType? logType,
    String? searchText,
  }) async {
    final typeLog = logType != null
        ? EnumLoggerType.values.firstWhere((e) => e.name == logType.name)
        : null;
    if (typeLog == null && (searchText == null || searchText.isEmpty)) {
      return getMessages();
    }
    if (typeLog == null) {
      final logs = await loggerCacheRepositoryImpl.getAllLogs();
      final filteredLogs = logs
          .where((log) => log.message.contains(searchText!))
          .map((e) => MessageEntry(loggerObjectBase: e).fromLoggerObjectBase())
          .toList();
      return filteredLogs;
    }
    final logs = await loggerCacheRepositoryImpl.getLogsByType(typeLog);
    if (searchText != null && searchText.isNotEmpty) {
      final filteredLogs = logs
          .where((log) => log.message.contains(searchText))
          .map((e) => MessageEntry(loggerObjectBase: e).fromLoggerObjectBase())
          .toList();
      return filteredLogs;
    }
    final filteredLogs = logs
        .map((e) => MessageEntry(loggerObjectBase: e).fromLoggerObjectBase())
        .toList();
    return filteredLogs;
  }

  Future<List<MessageLog>> getMessages() async {
    final logs = await loggerCacheRepositoryImpl.getAllLogs();
    return logs
        .map((e) => MessageEntry(loggerObjectBase: e).fromLoggerObjectBase())
        .toList();
  }
}
