import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_custom_printer/src/data/cache/logger_cache.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list.dart';
import 'package:path/path.dart' as path;

void main() {
  group('LoggerCache Security Tests', () {
    late LoggerCache loggerCache;
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('logger_cache_security_test');
      loggerCache = LoggerCache(tempDir.path);
      await loggerCache.futureInitialization.future;
    });

    tearDownAll(() async {
      await tempDir.delete(recursive: true);
    });

    test('should prevent path traversal and use basename', () async {
      const maliciousName = '../../etc/passwd';
      await loggerCache.writeLogToFile(
        maliciousName,
        LoggerJsonList(type: 'SecurityTest'),
      );

      final expectedPath = path.join(
        tempDir.path,
        'loggerApp',
        'logs',
        'passwd.json',
      );

      final file = File(expectedPath);
      expect(await file.exists(), isTrue, reason: 'Should have saved as passwd.json in the logs directory');

      // Verify no file was created outside
      final outsideFile = File(path.join(tempDir.path, 'etc', 'passwd.json'));
      expect(await outsideFile.exists(), isFalse);
    });

    test('should throw ArgumentError for invalid names', () {
      expect(
        () => loggerCache.writeLogToFile('.', LoggerJsonList(type: 'TestLog')),
        throwsArgumentError,
      );
      expect(
        () => loggerCache.writeLogToFile('..', LoggerJsonList(type: 'TestLog')),
        throwsArgumentError,
      );
      expect(
        () => loggerCache.writeLogToFile('   ', LoggerJsonList(type: 'TestLog')),
        throwsArgumentError,
      );
    });

    test('should sanitize control characters and null bytes', () async {
      const nameWithNull = 'bad\x00file';
      await loggerCache.writeLogToFile(
        nameWithNull,
        LoggerJsonList(type: 'SecurityTest'),
      );

      final expectedPath = path.join(
        tempDir.path,
        'loggerApp',
        'logs',
        'bad_file.json',
      );

      final file = File(expectedPath);
      expect(await file.exists(), isTrue);
    });
  });
}
