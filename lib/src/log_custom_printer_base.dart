import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/log_printers/log_simple_print.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/logs_object/info_log.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

/// Classe principal do sistema de logging.
///
/// Implementa o padrão Singleton para centralizar a configuração do sistema
/// de logging. Permite escolher entre diferentes impressoras de log
/// ([LogSimplePrint] ou [LogWithColorPrint]) e gerenciar a configuração global.
///
/// {@category Core}
///
/// Exemplo básico:
/// ```dart
/// // Configuração simples (padrão)
/// final printer = LogCustomPrinterBase();
///
/// // Configuração com cores
/// final colorPrinter = LogCustomPrinterBase.colorPrint();
///
/// // Configuração customizada
/// final customPrinter = LogCustomPrinterBase(
///   logPrinterCustom: LogWithColorPrint(
///     config: ConfigLog(
///       enableLog: true,
///       onlyClasses: {DebugLog, ErrorLog},
///     ),
///   ),
/// );
/// ```
class LogCustomPrinterBase {
  /// Instância única do singleton.
  static LogCustomPrinterBase? _instance;

  /// Impressora de logs atualmente configurada.
  late LogPrinterBase _logPrinterBase;

  /// Cria uma instância padrão do [LogCustomPrinterBase].
  ///
  /// Utiliza a configuração padrão com [LogSimplePrint].
  factory LogCustomPrinterBase() {
    return LogCustomPrinterBase.customPrint();
  }

  /// Construtor de fábrica para criar uma instância com impressora que
  /// preserva cor/estilo ANSI.
  ///
  /// Configura automaticamente para exibir apenas logs de debug e info
  /// com formatação colorida usando códigos ANSI.
  ///
  /// Exemplo:
  /// ```dart
  /// final printer = LogCustomPrinterBase.colorPrint();
  /// ```
  factory LogCustomPrinterBase.colorPrint({
    ConfigLog config = const ConfigLog(onlyClasses: <Type>{DebugLog, InfoLog}),
  }) {
    return LogCustomPrinterBase.customPrint(logPrinterCustom: LogWithColorPrint(config: config));
  }

  /// Construtor de fábrica para criar uma instância singleton.
  /// Permite fornecer uma impressora de logs customizada via [logPrinterCustom].
  /// Quando não fornecida, usa [LogSimplePrint] como padrão.
  factory LogCustomPrinterBase.customPrint({LogPrinterBase? logPrinterCustom}) {
    _instance ??= LogCustomPrinterBase._internal();
    if (logPrinterCustom != null) {
      _instance!._logPrinterBase = logPrinterCustom;
    }
    return _instance!;
  }

  /// Cria uma instância com impressora simples sem formatação de cores.
  ///
  /// Utiliza [LogSimplePrint] para a saída dos logs. É possível fornecer
  /// uma [config] customizada para filtrar os logs.
  ///
  /// Exemplo:
  /// ```dart
  /// final printer = LogCustomPrinterBase.simplePrint(
  ///   config: ConfigLog(enableLog: false),
  /// );
  /// ```
  factory LogCustomPrinterBase.simplePrint({ConfigLog config = const ConfigLog()}) {
    return LogCustomPrinterBase.customPrint(logPrinterCustom: LogSimplePrint(config: config));
  }

  /// Construtor interno para inicialização do singleton.
  ///
  /// Configura a impressora padrão como [LogSimplePrint].
  LogCustomPrinterBase._internal() {
    _logPrinterBase = LogSimplePrint();
  }

  /// Retorna a impressora de logs configurada.
  ///
  /// Permite acessar a instância de [LogPrinterBase] em uso para
  /// verificar configurações ou realizar operações avançadas.
  LogPrinterBase getLogPrinterBase() {
    return _logPrinterBase;
  }

  /// Registra uma mensagem de debug.
  ///
  /// [message] é o texto da mensagem de debug.
  /// [typeClass] identifica a classe de origem (opcional).
  ///
  /// Exemplo:
  /// ```dart
  /// final printer = LogCustomPrinterBase();
  /// printer.logDebug('Operação iniciada');
  /// ```
  void logDebug(String message, {Type? typeClass}) {
    final log = DebugLog(message, typeClass: typeClass);
    _logPrinterBase.printLog(log);
  }
}

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
