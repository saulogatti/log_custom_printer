import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/log_printers/log_with_color_print.dart';

/// Classe base abstrata para impressoras de logs.
///
/// Define o contrato para implementações de impressoras de log.
/// Cada impressora deve implementar o método [printLog] para definir
/// como os logs serão formatados e exibidos.
///
/// {@category Printers}
///
/// As implementações disponíveis são:
/// - [LogSimplePrint]: saída simples sem cores
/// - [LogWithColorPrint]: saída com códigos ANSI coloridos
///
/// Registre no startup via [registerLogPrinter]:
/// ```dart
/// void main() {
///   registerLogPrinter(
///     LogWithColorPrint(config: ConfigLog(enableLog: true)),
///   );
///   runApp(MyApp());
/// }
/// ```
///
/// Exemplo de implementação customizada:
/// ```dart
/// class MinhaImpressora extends LogPrinterBase {
///   const MinhaImpressora({super.config});
///
///   @override
///   void printLog(LoggerObjectBase log) {
///     // Implementação customizada
///     print('MEU LOG: ${log.message}');
///   }
/// }
/// ```
abstract class LogPrinterBase {
  /// Configuração de filtragem e habilitação de logs.
  final ConfigLog configLog;

  /// Construtor const para permitir uso como constante.
  ///
  /// [config] define as regras de filtragem. Se não fornecida,
  /// usa a configuração padrão.
  const LogPrinterBase({ConfigLog? config}) : configLog = config ?? const ConfigLog();

  /// Imprime/processa o log fornecido.
  ///
  /// Implementações devem definir como o log será formatado e enviado
  /// para a saída (console, arquivo, serviço remoto, etc.).
  void printLog(LoggerObjectBase log);
}
