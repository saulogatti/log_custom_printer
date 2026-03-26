import 'dart:io';
import 'package:log_custom_printer/src/cache/logger_cache.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late LoggerCache cache;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('logger_cache_test');
    cache = LoggerCache(tempDir.path);
    await cache.futureInitialization;
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('readAllLogs should return all persisted logs', () async {
    // 1. Create and write a log list
    final list = LoggerJsonList(type: 'DebugLog');
    list.addLogger(DebugLog('Test message'));
    await cache.writeLogToFile('debug', list);

    // 2. Read all logs
    final allLogs = await cache.readAllLogs();

    // 3. Verify
    expect(allLogs, isNotNull);
    expect(allLogs!.length, equals(1));
    expect(allLogs.values.first!.loggerEntries.length, equals(1));
    expect((allLogs.values.first!.loggerEntries.first as DebugLog).message, equals('Test message'));
  });
}
