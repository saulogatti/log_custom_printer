import 'dart:developer' as dev show log;

import 'package:flutter/material.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

export 'package:log_custom_printer/src/log_custom_printer_base.dart';

/// Impressora simples de logs.
///
/// Implementação mínima de `LogPrinterBase` que imprime mensagens sem
/// códigos ANSI (sem cor) usando `debugPrint`. É útil para ambientes onde
/// a saída colorida não é desejada (por exemplo logs em consoles que não
/// suportam ANSI).
class LogSimplePrint with LogPrinterBase {
  /// Construtor const para permitir uso como constante quando configurado.
  const LogSimplePrint();

  /// Imprime o log em formato simples.
  ///
  /// Recebe um [LoggerObjectBase] e escreve uma linha via `debugPrint` no
  /// formato: `[ClassName] <timestamp> <message>` (o timestamp e a mensagem
  /// são obtidos por [LoggerObjectBase.getMessage] com `withColor = false`).
  @override
  void printLog(LoggerObjectBase log) {
    final className = log.className;
    final message = log.getMessage(false);

    debugPrint('[$className] $message');
  }
}

/// Impressora de logs que preserva cor/estilo ANSI.
///
/// Usa `dart:developer.log` para enviar um bloco formatado que contém um
/// separador, o corpo da mensagem e outro separador. O nome do logger
/// (`name`) enviado ao `dev.log` é a `className` do log em caixa alta e
/// com estilos aplicados pela cor retornada por [LoggerObjectBase.getColor].
class LogWithColorPrint with LogPrinterBase {
  /// Construtor const para uso imutável/compilado.
  const LogWithColorPrint();

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
    final separator = log.getColor().call(
      "=-=-=-=-=-=-=-=-=-=-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-",
    );

    final start = log.getColor().call(log.className.toString().toUpperCase());
    final List<String> messageLog = [" ", separator];
    messageLog.add(log.getMessage());
    messageLog.add(separator);

    final String logFormated = messageLog.join("\n");

    dev.log(logFormated, name: start);
  }
}
