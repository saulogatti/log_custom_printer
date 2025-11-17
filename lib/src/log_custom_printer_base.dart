import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/log_printers/log_simple_print.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/logs_object/info_log.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

class LogCustomPrinterBase {
  static LogCustomPrinterBase? _instance;
  late LogPrinterBase _logPrinterBase;

  /// Construtor de fábrica para criar uma instância singleton.
  /// Permite fornecer uma impressora de logs customizada via [logPrinterCustom].
  /// Quando não fornecida, usa [LogSimplePrint] como padrão.
  factory LogCustomPrinterBase({LogPrinterBase? logPrinterCustom}) {
    _instance ??= LogCustomPrinterBase._internal();
    if (logPrinterCustom != null) {
      _instance!._logPrinterBase = logPrinterCustom;
    }
    return _instance!;
  }

  /// Construtor de fábrica para criar uma instância com impressora que
  /// preserva cor/estilo ANSI.
  factory LogCustomPrinterBase.colorPrint() {
    return LogCustomPrinterBase(
      logPrinterCustom: LogWithColorPrint(config: ConfigLog(onlyClasses: <Type>{DebugLog, InfoLog})),
    );
  }
  LogCustomPrinterBase._internal() {
    _logPrinterBase = LogSimplePrint();
  }

  /// Retorna a impressora de logs configurada.
  LogPrinterBase getLogPrinterBase() {
    return _logPrinterBase;
  }

  void logDebug(String message, {Type? typeClass}) {
    final log = DebugLog(message, typeClass: typeClass);
    _logPrinterBase.printLog(log);
  }
}

/// Mixin que define o contrato para impressoras de logs.
/// Implementações devem fornecer o método [printLog] que recebe um
/// [LoggerObjectBase] e o imprime/serializa conforme a lógica desejada.
abstract class LogPrinterBase {
  final ConfigLog configLog;
  const LogPrinterBase({ConfigLog? config}) : configLog = config ?? const ConfigLog();

  void printLog(LoggerObjectBase log);
}
