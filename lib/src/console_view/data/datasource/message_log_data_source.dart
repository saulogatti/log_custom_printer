import 'package:log_custom_printer/src/console_view/data/entry/message_entry.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/data/cache/logger_persistence_service.dart';

class MessageLogDataSource {

  MessageLogDataSource({required this.loggerCacheRepositoryImpl});
  LoggerPersistenceService loggerCacheRepositoryImpl;

  Future<void> clearMessages() async {
    await loggerCacheRepositoryImpl.clearLogs();
  }

  Future<List<MessageLog>> getMessages() async {
    final logs = await loggerCacheRepositoryImpl.getAllLogs();
    return logs
        .map((e) => MessageEntry(loggerObjectBase: e).fromLoggerObjectBase())
        .toList();
  }
}
