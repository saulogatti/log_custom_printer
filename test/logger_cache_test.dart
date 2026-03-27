import 'dart:io';

import 'package:log_custom_printer/src/cache/logger_cache.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('LoggerCache', () {
    late LoggerCache loggerCache;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('logger_cache_test');
      loggerCache = LoggerCache(tempDir.path);
      await loggerCache.futureInitialization.future;
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('_getPathFile should work for valid filename', () async {
      // _getPathFile is private, so we'll test it through a public method that uses it
      // or just trust it if it doesn't crash.
      // Actually we can't easily test it directly if it's private.
      // But we can test writeLogToFile which calls it.
      await loggerCache.writeLogToFile('test_log', {'key': 'value'});
      final expectedPath = path.join(
        tempDir.path,
        'loggerApp',
        'logs',
        'test_log.json',
      );
      final file = File(expectedPath);
      expect(await file.exists(), isTrue);
    });

    test(
      '_getPathFile should throw assertion error for filename with separator',
      () {
        expect(
          () =>
              loggerCache.writeLogToFile('path${path.separator}separator', {}),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      '_getPathFile should throw assertion error for filename with .json',
      () {
        expect(
          () => loggerCache.writeLogToFile('test.json', {}),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('_getPathFile should throw assertion error for empty filename', () {
      expect(
        () => loggerCache.writeLogToFile('', {}),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
