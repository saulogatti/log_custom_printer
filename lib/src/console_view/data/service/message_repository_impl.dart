import 'package:flutter/material.dart' show DateTimeRange;
import 'package:log_custom_printer/src/console_view/data/datasource/message_log_data_source.dart';
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';

/// Implementação de [MessageRepository] que delega ao [MessageLogDataSource].
///
/// Atua como camada de repositório entre o [ConsoleBloc] e a fonte de dados,
/// seguindo o padrão Repository da Clean Architecture.
class MessageRepositoryImpl implements MessageRepository {
  final MessageLogDataSource _dataSource;

  /// Cria o repositório com o [dataSource] fornecido.
  MessageRepositoryImpl({required MessageLogDataSource dataSource})
    : _dataSource = dataSource;

  @override
  void clearMessages() {
    _dataSource.clearMessages();
  }

  @override
  Future<List<MessageLog>> getFilterMessages({
    LogType? logType,
    String? searchText,
    DateTimeRange? dateTimeRange,
    bool isDateTimeFilterEnabled = false,
  }) {
    return _dataSource.getFilterMessages(
      logType: logType,
      searchText: searchText,
      dateTimeRange: dateTimeRange,
      isDateTimeFilterEnabled: isDateTimeFilterEnabled,
    );
  }

  @override
  Future<List<MessageLog>> getMessages() {
    return _dataSource.getMessages();
  }
}
