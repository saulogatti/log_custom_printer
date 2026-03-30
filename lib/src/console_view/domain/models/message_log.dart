import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';

/// Representa o tipo/severidade de um log exibido no console visual.
///
/// Cada valor corresponde a uma categoria do sistema de logging, além de
/// [all] para ausência de filtro de tipo.
///
/// As propriedades `icon` e `color` para exibição visual são fornecidas
/// pela extensão `LogTypeExtension` em `log_card_widget.dart`.
enum LogType {
  /// Log informativo (nível info).
  info,

  /// Log de aviso/alerta (nível warning).
  warning,

  /// Log de erro (nível error).
  error,

  /// Log de depuração (nível debug).
  debug,

  /// Sem filtro — exibe todos os tipos.
  all;

  /// Converte o [LogType] para o [EnumLoggerType] correspondente,
  /// usado pelas operações do repositório de cache.
  EnumLoggerType toEnum() {
    switch (this) {
      case LogType.info:
        return EnumLoggerType.info;
      case LogType.warning:
        return EnumLoggerType.warning;
      case LogType.error:
        return EnumLoggerType.error;
      case LogType.debug:
        return EnumLoggerType.debug;
      case LogType.all:
        return EnumLoggerType.debug; // TODO: Implementar all
    }
  }
}

/// Modelo de mensagem de log para exibição no console visual.
///
/// Representa um log já formatado para a camada de apresentação, com
/// título (cabeçalho), mensagem, timestamp e tipo/severidade.
class MessageLog {
  /// Título/cabeçalho da mensagem (ex.: nome da classe de origem).
  final String title;

  /// Corpo da mensagem de log formatada.
  final String message;

  /// Data e hora em que o log foi criado.
  final DateTime timestamp;

  /// Tipo/severidade do log.
  final LogType type;

  /// Cria uma instância de [MessageLog].
  MessageLog({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
  });
}
