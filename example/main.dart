// ignore_for_file: avoid_print

import 'package:log_custom_printer/log_custom_printer.dart';

/// Example usage of log_custom_printer in a pure Dart environment.
///
/// This example demonstrates:
/// 1. Initial configuration (printer registration)
/// 2. Emitting logs at different levels (Debug, Info, Warning, Error)
/// 3. Using LoggerClassMixin in application classes
/// 4. Querying and managing logs through LoggerPersistenceService
/// 5. JSON serialization
void main() async {
  // 1. Initial configuration
  // Register a simple printer for console output.
  // The returned LoggerPersistenceService manages the log cache.
  print('1. Initial configuration:');
  persistenceService = registerLogPrinterSimple(
    config: const ConfigLog(
      enableLog: true, // Enable log processing
      onlyClasses: {DebugLog, InfoLog, WarningLog, ErrorLog},
    ),
    cacheFilePath: 'cache_logs',
    maxLogsInCache: 50, // Cache limit per type
  );
  // await persistenceService.getAllLogs();
  print('Initial configuration complete');

  // 2. Use the mixin (recommended for application classes)
  print('2. Using LoggerClassMixin:');
  final app = MinhaApp();
  app.processData();
  print('Mixin usage complete');

  // 3. Query the log cache
  print('3. Querying the log cache:');
  final allLogs = await persistenceService.getAllLogs();
  print('Total logs captured: ${allLogs.length}');
  print('Querying logs:');
  final queryLogs = await persistenceService.queryLogs(
    const LogQuery(types: {EnumLoggerType.debug}),
  );
  print('Logs found: ${queryLogs.length}');
  print('Example complete');
}

late LoggerPersistenceService persistenceService;

/// Example class using the logging mixin.
class MinhaApp with LoggerClassMixin {
  void processData() {
    logDebug('Starting data processing...');

    // Simulate application logic.
    logInfo('Data validated successfully.');

    logWarning('Processing took longer than expected.');
    List.generate(100, (index) => logDebug('Debug message $index'));

    // Emit logs manually.
    print('2. Emitting logs manually:');
    logDebug('This is a debug message');
    logInfo('Important system information');
    logWarning('Warning: resource limit reached');

    try {
      throw Exception('Critical operation failure');
    } catch (e, stack) {
      logError('Error detected: $e', stack);
    } finally {
      logDebug('Finished data processing');
    }
  }
}
