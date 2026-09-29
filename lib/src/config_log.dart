import 'package:log_custom_printer/log_custom_printer.dart' show LogPrinterService;
import 'package:log_custom_printer/src/domain/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/info_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/warning_log.dart';
import 'package:log_custom_printer/src/log_printer_service.dart' show LogPrinterService;

/// Configuration object for controlling logging behavior.
///
/// Defines enable/disable and type-filtering rules.
/// By default, logging is disabled ([enableLog] `false`) and [onlyClasses]
/// includes [DebugLog], [WarningLog], and [InfoLog].
///
/// {@category Configuration}
class const ConfigLog({
  /// Whether logs should be emitted to output.
  ///
  /// When `false`, logs are ignored except types with `alwaysPrint` (for example `ErrorLog`).
  /// Defaults to `false`.
  final bool enableLog = false,

  /// Set of allowed log runtime types.
  ///
  /// When this set is not empty, only listed types are processed.
  /// `ErrorLog` can still be processed via `alwaysPrint` in [LogPrinterService].
  /// Defaults to [DebugLog], [WarningLog], and [InfoLog].
  final Set<Type> onlyClasses = const {DebugLog, WarningLog, InfoLog},
});
