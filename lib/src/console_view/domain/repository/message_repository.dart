import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

abstract interface class MessageRepository {
  void clearMessages();
  Future<List<MessageLog>> getMessages();
}
