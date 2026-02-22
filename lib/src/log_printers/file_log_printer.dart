import 'dart:convert';
import 'dart:io';

import 'package:log_custom_printer/src/cache/logger_cache.dart';
import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';

/// Printer focused exclusively on writing logs to a file asynchronously.
class FileLogPrinter {
  /// Configuration for logging.
  final ConfigLog configLog;

  /// Creates a [FileLogPrinter] instance.
  const FileLogPrinter({this.configLog = const ConfigLog()});

  /// Writes the [loggerList] to a file named by [fileName].
  ///
  /// This operation is asynchronous to avoid blocking the UI thread.
  Future<void> writeLogToFile(String fileName, LoggerJsonList loggerList) async {
    try {
      if (!configLog.isSaveLogFile) {
        return;
      }
      final path = LoggerCache().getNameFile(fileName);
      final File file = File(path);
      final spaces = ' ' * 2;

      // Ensure file exists
      if (!file.existsSync()) {
        await file.create(recursive: true);
      }

      final jj = JsonEncoder.withIndent(spaces).convert(loggerList);
      await file.writeAsString(jj);
    } catch (e, stack) {
      // In case of error, we can't do much inside the printer itself without causing loops.
      // But we can print to console if debugging.
      // For now, silently fail or use print as fallback.
      // Ideally, error handling should be robust.
      // Replicating _printMessage logic from original handler locally if needed.
      _printMessage(e.toString(), stack: stack);
    }
  }

  void _printMessage(Object message, {StackTrace? stack}) {
    if (configLog.enableLog || stack != null) {
      String log = message.toString();
      if (stack != null) {
        log = log + stack.toString();
      }
      // ignore: avoid_print
      print(log);
    }
  }
}
