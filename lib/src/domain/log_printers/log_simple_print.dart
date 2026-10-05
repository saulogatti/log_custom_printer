import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/log_custom_printer_base.dart';

export 'package:log_custom_printer/src/log_custom_printer_base.dart';

/// Simple log printer.
///
/// Prints logs without ANSI color codes.
///
/// {@category Printers}
class const LogSimplePrint() extends LogPrinterBase {
  /// Prints the log as `[ClassName] <timestamp> <message>`.
  @override
  void printLog(LoggerObjectBase log) {
    final className = log.className;
    final message = log.getMessage(withColor: false);

    // ignore: avoid_print
    print('[$className] $message');
  }
}
