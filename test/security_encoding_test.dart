import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:log_custom_printer/src/data/cache/logger_cache.dart';
import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/logs_object/debug_log.dart';

void main() {
  group('Security Encoding Tests', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('security_encoding_test');
    });

    tearDownAll(() async {
      await tempDir.delete(recursive: true);
    });

    test('LoggerCache.exportLogs should use UTF-8 encoding for non-ASCII characters', () async {
      final loggerCache = LoggerCache(tempDir.path);
      await loggerCache.futureInitialization.future;

      const message = 'Log with emoji 🚀 and accents áéíóú';
      final logs = [DebugLog(message)];

      final (data, _) = await loggerCache.exportLogs(logs, ExportFormat.json);

      expect(data, isNotNull);
      final decodedString = utf8.decode(data!);
      expect(decodedString, contains(message));
    });

    test('FileManager (FileType.log) should use UTF-8 encoding for non-ASCII characters', () async {
      final fileManager = FileManager(fileType: FileType.log);
      final filePath = '${tempDir.path}/test_encoding.log';
      const content = 'Log with emoji 🚀 and accents áéíóú';

      await fileManager.writeFile(filePath, content);

      // Verify file content manually first to be sure it's UTF-8
      final bytes = await File(filePath).readAsBytes();
      expect(utf8.decode(bytes), content);

      final readContent = await fileManager.readFile(filePath);
      expect(readContent, content);
    });
  });
}
