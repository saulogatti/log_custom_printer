import 'package:log_custom_printer/src/log_custom_printer_base.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

export 'package:log_custom_printer/src/log_custom_printer_base.dart';

/// Impressora simples de logs.
///
/// Implementação mínima de `LogPrinterBase` que imprime mensagens sem
/// códigos ANSI (sem cor) usando `debugPrint`. É útil para ambientes onde
/// a saída colorida não é desejada (por exemplo logs em consoles que não
/// suportam ANSI).
///
/// {@category Printers}
///
/// Exemplo de uso:
/// ```dart
/// registerLogPrinter(LogSimplePrint());
/// ```
class LogSimplePrint extends LogPrinterBase {
  /// Construtor const para permitir uso como constante quando configurado.
  const LogSimplePrint({super.config});

  /// Imprime o log em formato simples.
  ///
  /// Recebe um [LoggerObjectBase] e escreve uma linha via `debugPrint` no
  /// formato: `[ClassName] <timestamp> <message>` (o timestamp e a mensagem
  /// são obtidos por [LoggerObjectBase.getMessage] com `withColor = false`).
  @override
  void printLog(LoggerObjectBase log) {
    final className = log.className;
    final message = log.getMessage(false);

    print('[$className] $message');
  }
}
