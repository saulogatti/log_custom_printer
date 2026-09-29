/// Logging library for Dart projects (CLI, server, scripts).
///
/// It can also be used in Flutter apps; register a printer in `main`
/// before emitting logs.
///
/// Provides a complete logging system with:
/// - Typed log hierarchy (Debug, Info, Warning, Error)
/// - ANSI color formatting
/// - Automatic JSON serialization
/// - Dependency injection via get_it
/// - Utility mixins for easy integration
///
/// ## Quick start
///
/// ```dart
/// import 'package:log_custom_printer/log_custom_printer.dart';
///
/// void main() {
///   registerLogPrinter(
///     const LogWithColorPrint(),
///     config: const ConfigLog(enableLog: true),
///   );
///   // Flutter apps: runApp(const MyApp());
/// }
///
/// class MyClass with LoggerClassMixin {
///   void execute() {
///     logDebug('Starting process');
///     logInfo('Process running');
///
///     try {
///       // app code
///     } catch (error, stackTrace) {
///       logError('Error: $error', stackTrace);
///     }
///   }
/// }
/// ```
///
/// ## Log types
///
/// - [DebugLog]: Debug messages (yellow)
/// - [InfoLog]: General information (white)
/// - [WarningLog]: Warnings and alerts (green)
/// - [ErrorLog]: Errors and exceptions (red)
///
/// ## Configuration
///
/// Configure logging behavior with [ConfigLog]:
///
/// ```dart
/// final config = ConfigLog(
///   enableLog: true,
///   onlyClasses: {DebugLog, ErrorLog},
/// );
/// ```
///
/// ## Printers
///
/// Choose output strategy:
/// - [registerLogPrinterSimple]: Simple output without colors
/// - [registerLogPrinterColor]: ANSI color output
///
/// {@category Core}
library;

import 'package:log_custom_printer/log_custom_printer.dart';

export 'src/config_log.dart';
export 'src/data/cache/logger_cache_repository_impl.dart' show LoggerCacheRepositoryImpl;
export 'src/data/cache/logger_persistence_service.dart' show LoggerPersistenceService;
export 'src/data/file_utils/file_manager_type.dart';
export 'src/domain/i_logger_cache_repository.dart';
export 'src/domain/log_helpers/enum_logger_type.dart';
export 'src/domain/log_helpers/logger_class_mixin.dart';
export 'src/domain/log_helpers/logger_enum.dart';
export 'src/domain/log_printers/log_simple_print.dart';
export 'src/domain/log_printers/log_with_color_print.dart';
export 'src/domain/logs_object/debug_log.dart';
export 'src/domain/logs_object/error_log.dart';
export 'src/domain/logs_object/info_log.dart';
export 'src/domain/logs_object/logger_object.dart';
export 'src/domain/logs_object/warning_log.dart';
export 'src/domain/query/log_filter_engine.dart';
export 'src/domain/query/log_query.dart';
export 'src/domain/query/log_sort_engine.dart';
export 'src/extensions/date_time_log_helper.dart';
export 'src/log_custom_printer_base.dart';
export 'src/log_printer_locator.dart';
export 'src/log_printer_service.dart' show LogPrinterService;
export 'src/utils/logger_ansi_color.dart';
