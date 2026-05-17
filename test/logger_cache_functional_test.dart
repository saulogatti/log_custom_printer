import 'dart:io';

import 'package:log_custom_printer/src/data/cache/logger_cache.dart';
import 'package:log_custom_printer/src/domain/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late LoggerCache cache;

  setUpAll(() async {
    tempDir = Directory('${Directory.current.path}/logger_cache_test2');
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
    cache = LoggerCache(tempDir.path);
    await cache.futureInitialization.future;
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });
  group("Teste tipo arquivos", () {
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
    test('writeLogToFile should create a file with the correct extension', () async {
      final list = LoggerJsonList(type: 'DebugLog');
      list.addLogger(DebugLog('Test message'));
      await cache.writeLogToFile('debug', list);

      final expectedFile = File(cache.getPathFileForTest('debug'));
      expect(await expectedFile.exists(), isTrue);
    });
  });
}
