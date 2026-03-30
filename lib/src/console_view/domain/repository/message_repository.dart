import 'package:flutter/material.dart' show DateTimeRange;
import 'package:log_custom_printer/src/console_view/domain/models/message_log.dart';

/// Repositório de mensagens de log para o console visual.
///
/// Define o contrato de acesso e filtragem dos logs exibidos
/// no [ConsoleView]. A implementação padrão é [MessageRepositoryImpl].
abstract interface class MessageRepository {
  /// Remove todas as mensagens de log armazenadas.
  void clearMessages();

  /// Retorna a lista de logs aplicando os filtros fornecidos.
  ///
  /// - [logType]: filtra por tipo (nulo ou [LogType.all] retorna todos).
  /// - [searchText]: filtra por texto contido na mensagem/título.
  /// - [dateTimeRange]: intervalo de data/hora para filtragem temporal.
  /// - [isDateTimeFilterEnabled]: quando `false`, o filtro temporal é ignorado.
  Future<List<MessageLog>> getFilterMessages({
    LogType? logType,
    String? searchText,
    DateTimeRange? dateTimeRange,
    bool isDateTimeFilterEnabled,
  });

  /// Retorna todos os logs sem aplicar filtros.
  Future<List<MessageLog>> getMessages();
}
