import 'dart:io';

import 'package:log_custom_printer/src/data/cache/logger_cache.dart';
import 'package:log_custom_printer/src/data/file_utils/file_manager_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list.dart';
import 'package:test/test.dart';

import 'data_logs/jsons_mocks.dart';

void main() {
  late LoggerCache loggerCache;
  String tempDir = Directory.current.path;

  setUpAll(() async {
    tempDir += "/test/data_logs";
    loggerCache = LoggerCache(tempDir, fileManagerType: FileManager());
    await loggerCache.futureInitialization.future;
  });

  tearDownAll(() async {
    await loggerCache.clearAll();
  });
  group("Salvando arquivos de logs", () {
    test(" DebugLog ", () async {
      final list = LoggerJsonList.fromJson(jsonTestDebug);

      await loggerCache.writeLogToFile('testDebug', list);
      final expectedPath = loggerCache.getPathFileForTest('testDebug');
      final file = File(expectedPath);
      expect(await file.exists(), isTrue);
      final content = await loggerCache.readAllLogs();
      expect(content?.length, greaterThan(0));
    });
    test(" InfoLog ", () async {
      final list = LoggerJsonList.fromJson(jsonTestInfo);

      await loggerCache.writeLogToFile('testInfo', list);
      final expectedPath = loggerCache.getPathFileForTest('testInfo');
      final file = File(expectedPath);
      expect(await file.exists(), isTrue);
      final content = await loggerCache.readAllLogs();
      expect(content?.length, greaterThan(0));
    });
    test(" WarningLog ", () async {
      final list = LoggerJsonList.fromJson(jsonTestWarning);

      await loggerCache.writeLogToFile('testWarning', list);
      final expectedPath = loggerCache.getPathFileForTest('testWarning');
      final file = File(expectedPath);
      expect(await file.exists(), isTrue);
      final content = await loggerCache.readAllLogs();
      expect(content?.length, greaterThan(0));
    });
    test(" ErrorLog ", () async {
      final list = LoggerJsonList.fromJson(jsonTestError);

      await loggerCache.writeLogToFile('testError', list);
      final expectedPath = loggerCache.getPathFileForTest('testError');
      final file = File(expectedPath);
      expect(await file.exists(), isTrue);
      final content = await loggerCache.readAllLogs();
      expect(content?.length, greaterThan(0));
    });
  });
}
