import 'dart:developer' as dev show log;
import 'package:log_custom_printer/src/log_custom_printer_base.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';

/// ANSI color-aware printer implementation.
///
/// {@category Printers}
class LogWithColorPrint extends LogPrinterBase {
  /// Const constructor.
  const LogWithColorPrint();

  /// Prints formatted log block using `dart:developer.log`.
  @override
  void printLog(LoggerObjectBase log) {
    final separator = log.getColor().call('=-=-=-=-=-=-=-=-=-=-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-');

    final start = log.getStartLog();
    final List<String> messageLog = [' ', separator];
    messageLog.add(log.getMessage());
    messageLog.add(separator);

    final String logFormated = messageLog.join('\n');

    dev.log(logFormated, name: start);
  }
}
