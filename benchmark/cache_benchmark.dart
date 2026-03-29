import 'dart:io';

import 'package:log_custom_printer/src/data/cache/logger_cache.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list.dart';
import 'package:log_custom_printer/src/domain/logs_object/debug_log.dart';

void main() async {
  final tempDir = await Directory.systemTemp.createTemp(
    'logger_cache_benchmark',
  );
  final cache = LoggerCache(tempDir.path);
  await cache.futureInitialization.future;

  // Create some dummy logs
  for (var i = 0; i < 50; i++) {
    final list = LoggerJsonList(type: 'DebugLog');
    list.addLogger(DebugLog('Message $i'));
    await cache.writeLogToFile('debug_$i', list);
  }

  const iterations = 10;

  // Warm up
  for (var i = 0; i < 5; i++) {
    await cache.readAllLogs();
  }

  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    await cache.readAllLogs();
  }
  stopwatch.stop();

  print(
    'readAllLogs: ${stopwatch.elapsedMilliseconds / iterations} ms per iteration',
  );

  // Clean up
  await tempDir.delete(recursive: true);
}
