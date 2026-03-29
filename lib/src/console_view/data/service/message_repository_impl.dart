import 'package:log_custom_printer/src/console_view/data/datasource/message_log_data_source.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageLogDataSource _dataSource;
  MessageRepositoryImpl({required MessageLogDataSource dataSource})
    : _dataSource = dataSource;

  @override
  void clearMessages() {
    _dataSource.clearMessages();
  }

  @override
  Future<List<MessageLog>> getMessages() {
    return _dataSource.getMessages();
  }
}
