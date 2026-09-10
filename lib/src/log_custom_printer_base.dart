import 'domain/log_printers/log_simple_print.dart';
import 'domain/log_printers/log_with_color_print.dart';
import 'domain/logs_object/logger_object.dart';

/// Base abstract class for log printers.
///
/// Defines the contract implemented by each printer strategy.
///
/// {@category Printers}
///
/// Available implementations:
/// - [LogSimplePrint]: simple non-colored output
/// - [LogWithColorPrint]: ANSI-colored output
abstract class LogPrinterBase {
  /// Const constructor for immutable printer instances.
  const LogPrinterBase();

  /// Prints/processes a log entry.
  ///
  /// Implementations define how log data is formatted and emitted.
  void printLog(LoggerObjectBase log);
}
