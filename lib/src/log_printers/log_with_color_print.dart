import 'dart:developer' as dev show log;
import 'package:log_custom_printer/src/log_custom_printer_base.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

/// Impressora de logs que preserva cor/estilo ANSI.
///
/// Usa `dart:developer.log` para enviar um bloco formatado que contém um
/// separador, o corpo da mensagem e outro separador. O nome do logger
/// (`name`) enviado ao `dev.log` é a `className` do log em caixa alta e
/// com estilos aplicados pela cor retornada por [LoggerObjectBase.getColor].
///
/// {@category Printers}
///
/// Exemplo de uso:
/// ```dart
/// registerLogPrinter(LogWithColorPrint(config: ConfigLog(enableLog: true)));
/// ```
class LogWithColorPrint extends LogPrinterBase {
  /// Construtor const para uso imutável/compilado.
  const LogWithColorPrint({super.config});

  /// Imprime o log usando códigos ANSI e `dart:developer.log`.
  ///
  /// Forma a saída como um bloco:
  ///
  ///  - uma linha separadora colorida
  ///  - a mensagem (formatada por [LoggerObjectBase.getMessage], que já
  ///    inclui timestamp)
  ///  - a mesma linha separadora
  ///
  /// O `name` do log enviado para `dev.log` é a `className` estilizada e
  /// em maiúsculas, para facilitar filtragem por origem nos visualizadores
  /// de logs que suportam esse campo.
  @override
  void printLog(LoggerObjectBase log) {
    final separator = log.getColor().call("=-=-=-=-=-=-=-=-=-=-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-");

    final start = log.getStartLog();
    final List<String> messageLog = [" ", separator];
    messageLog.add(log.getMessage());
    messageLog.add(separator);

    final String logFormated = messageLog.join("\n");

    dev.log(logFormated, name: start);
  }
}
