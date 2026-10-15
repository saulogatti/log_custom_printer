import 'dart:convert';
import 'dart:io';

import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/data/cache/logger_cache.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list_type.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late LoggerCache cache;

  String logsDir() => path.join(tempDir.path, 'loggerApp', 'logs');

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('logger_cache_operations_test');
    cache = LoggerCache(tempDir.path);
    await cache.futureInitialization.future;
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  LoggerJsonListType listOf(EnumLoggerType type, List<LoggerObjectBase> logs) {
    return LoggerJsonListType(type: type)..addLoggerList(logs);
  }

  group('LoggerCache initialization', () {
    test('creates the loggerApp/logs directory', () async {
      expect(await Directory(logsDir()).exists(), isTrue);
    });

    test('resolves paths inside the logs directory with a .json extension', () {
      expect(cache.getPathFileForTest('Debug'), equals(path.join(logsDir(), 'debug.json')));
      expect(cache.getPathFileForTest('app.log'), equals(path.join(logsDir(), 'app.json')));
    });
  });

  group('LoggerCache.writeLogToFile', () {
    test('writes indented JSON that round-trips', () async {
      await cache.writeLogToFile('info', listOf(EnumLoggerType.info, [InfoLog('hello')]));

      final content = await File(path.join(logsDir(), 'info.json')).readAsString();
      expect(content, contains('\n  "type": "info"'));
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final list = LoggerJsonListType.fromJson(decoded);
      expect(list.type, equals(EnumLoggerType.info));
      expect(list.loggerEntries.single.message, equals('hello'));
    });

    test('overwrites the previous content of the same file', () async {
      await cache.writeLogToFile('info', listOf(EnumLoggerType.info, [InfoLog('one')]));
      await cache.writeLogToFile('info', listOf(EnumLoggerType.info, [InfoLog('two')]));

      final all = await cache.readAllLogs();
      expect(all![EnumLoggerType.info]!.loggerEntries.single.message, equals('two'));
    });
  });

  group('LoggerCache.readAllLogs', () {
    test('returns an empty map when no files exist', () async {
      expect(await cache.readAllLogs(), isEmpty);
    });

    test('groups files by log type', () async {
      await cache.writeLogToFile('debug', listOf(EnumLoggerType.debug, [DebugLog('d')]));
      await cache.writeLogToFile(
        'error',
        listOf(EnumLoggerType.error, [ErrorLog('e', StackTrace.empty)]),
      );

      final all = await cache.readAllLogs();

      expect(all!.keys, unorderedEquals([EnumLoggerType.debug, EnumLoggerType.error]));
      expect(all[EnumLoggerType.error]!.loggerEntries.single, isA<ErrorLog>());
    });

    test('merges multiple files of the same type', () async {
      await cache.writeLogToFile('info_a', listOf(EnumLoggerType.info, [InfoLog('a')]));
      await cache.writeLogToFile('info_b', listOf(EnumLoggerType.info, [InfoLog('b')]));

      final all = await cache.readAllLogs();

      expect(all, hasLength(1));
      expect(
        all![EnumLoggerType.info]!.loggerEntries.map((log) => log.message),
        unorderedEquals(['a', 'b']),
      );
    });

    test('ignores files without the .json extension', () async {
      await File(path.join(logsDir(), 'notes.txt')).writeAsString('not a log');

      expect(await cache.readAllLogs(), isEmpty);
      expect(await File(path.join(logsDir(), 'notes.txt')).exists(), isTrue);
    });

    test('deletes corrupted files and keeps the valid ones', () async {
      await cache.writeLogToFile('debug', listOf(EnumLoggerType.debug, [DebugLog('ok')]));
      final corrupted = File(path.join(logsDir(), 'broken.json'));
      await corrupted.writeAsString('{ this is not json');

      final all = await cache.readAllLogs();

      expect(all!.keys, equals([EnumLoggerType.debug]));
      expect(await corrupted.exists(), isFalse);
    });

    test('deletes files with an unknown type', () async {
      final unknown = File(path.join(logsDir(), 'unknown.json'));
      await unknown.writeAsString(jsonEncode({'type': 'verbose', 'loggerJson': <Object>[]}));

      expect(await cache.readAllLogs(), isEmpty);
      expect(await unknown.exists(), isFalse);
    });

    test('returns null after the directory was removed', () async {
      await cache.clearAll();

      expect(await cache.readAllLogs(), isNull);
    });
  });

  group('LoggerCache clearing', () {
    test('clearLogByType deletes only the matching file', () async {
      await cache.writeLogToFile('debug', listOf(EnumLoggerType.debug, [DebugLog('d')]));
      await cache.writeLogToFile('info', listOf(EnumLoggerType.info, [InfoLog('i')]));

      await cache.clearLogByType('debug');

      expect(await File(path.join(logsDir(), 'debug.json')).exists(), isFalse);
      expect(await File(path.join(logsDir(), 'info.json')).exists(), isTrue);
    });

    test('clearLogByType is a no-op for a missing file', () async {
      await expectLater(cache.clearLogByType('warning'), completes);
    });

    test('clearAll removes the logs directory', () async {
      await cache.writeLogToFile('debug', listOf(EnumLoggerType.debug, [DebugLog('d')]));

      await cache.clearAll();

      expect(await Directory(logsDir()).exists(), isFalse);
    });

    test('clearAll can run twice without failing', () async {
      await cache.clearAll();

      await expectLater(cache.clearAll(), completes);
    });
  });

  group('LoggerCache.exportLogs', () {
    test('returns JSON bytes and writes share.json', () async {
      final logs = [InfoLog('one'), WarningLog('two')];

      final (bytes, filePath) = await cache.exportLogs(logs, ExportFormat.json);

      expect(filePath, equals(path.join(logsDir(), 'share.json')));
      expect(await File(filePath!).exists(), isTrue);
      final decoded = jsonDecode(utf8.decode(bytes!)) as List<dynamic>;
      expect(decoded, hasLength(2));
      expect((decoded.first as Map<String, dynamic>)['message'], equals('one'));
    });
  });
}
