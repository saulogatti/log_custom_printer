import 'dart:io';

import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/data/cache/logger_cache_repository_impl.dart'
    show valueMaxNumberOfEntries;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  tearDown(() {
    // The constructor mutates this global; restore the default for other tests.
    valueMaxNumberOfEntries = 100;
  });

  group('LoggerCacheRepositoryImpl in memory', () {
    late LoggerCacheRepositoryImpl repository;

    setUp(() {
      repository = LoggerCacheRepositoryImpl(maxLogEntries: 100);
    });

    test('starts empty', () async {
      expect(await repository.getAllLogs(), isEmpty);
      expect(await repository.getLogsByType(EnumLoggerType.debug), isEmpty);
    });

    test('groups logs by type', () async {
      await repository.addLog(DebugLog('d1'));
      await repository.addLog(DebugLog('d2'));
      await repository.addLog(ErrorLog('e1', StackTrace.empty));

      final debugLogs = await repository.getLogsByType(EnumLoggerType.debug);
      final errorLogs = await repository.getLogsByType(EnumLoggerType.error);

      expect(debugLogs.map((log) => log.message), equals(['d2', 'd1']));
      expect(errorLogs.single, isA<ErrorLog>());
      expect(await repository.getAllLogs(), hasLength(3));
    });

    test('returns a copy that callers cannot use to mutate the cache', () async {
      await repository.addLog(InfoLog('info'));

      final logs = await repository.getLogsByType(EnumLoggerType.info);
      logs.clear();

      expect(await repository.getLogsByType(EnumLoggerType.info), hasLength(1));
    });

    test('clearLogsByType removes only that type', () async {
      await repository.addLog(DebugLog('debug'));
      await repository.addLog(InfoLog('info'));

      await repository.clearLogsByType(EnumLoggerType.debug);

      expect(await repository.getLogsByType(EnumLoggerType.debug), isEmpty);
      expect(await repository.getLogsByType(EnumLoggerType.info), hasLength(1));
    });

    test('clearLogs removes every type', () async {
      await repository.addLog(DebugLog('debug'));
      await repository.addLog(WarningLog('warning'));

      await repository.clearLogs();

      expect(await repository.getAllLogs(), isEmpty);
    });

    test('getMaxLogEntries returns the configured limit', () {
      expect(LoggerCacheRepositoryImpl(maxLogEntries: 7).getMaxLogEntries(), equals(7));
    });

    test('keeps only the newest maxLogEntries per type', () async {
      final limited = LoggerCacheRepositoryImpl(maxLogEntries: 3);

      for (var i = 0; i < 5; i++) {
        await limited.addLog(InfoLog('info-$i'));
      }
      await limited.addLog(DebugLog('debug'));

      final infos = await limited.getLogsByType(EnumLoggerType.info);
      expect(infos.map((log) => log.message), equals(['info-4', 'info-3', 'info-2']));
      expect(await limited.getLogsByType(EnumLoggerType.debug), hasLength(1));
    });

    test('importLogs is not implemented yet', () {
      expect(
        () => repository.importLogs('[]', ExportFormat.json),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('LoggerCacheRepositoryImpl with file persistence', () {
    late Directory tempDir;

    String logsDir() => path.join(tempDir.path, 'loggerApp', 'logs');

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('logger_cache_repository_test');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('writes one JSON file per log type', () async {
      final repository = LoggerCacheRepositoryImpl(
        maxLogEntries: 100,
        directoryToSave: tempDir.path,
      );

      await repository.addLog(DebugLog('debug'));
      await repository.addLog(ErrorLog('error', StackTrace.empty));

      expect(await File(path.join(logsDir(), 'debug.json')).exists(), isTrue);
      expect(await File(path.join(logsDir(), 'error.json')).exists(), isTrue);
      expect(await File(path.join(logsDir(), 'info.json')).exists(), isFalse);
    });

    test('reloads persisted logs in a new instance keeping newest first', () async {
      final first = LoggerCacheRepositoryImpl(maxLogEntries: 100, directoryToSave: tempDir.path);
      await first.addLog(WarningLog('w1', createdAt: DateTime(2024)));
      await first.addLog(WarningLog('w2', createdAt: DateTime(2024, 1, 2)));
      await first.addLog(ErrorLog('boom', StackTrace.fromString('#0 main (file.dart:1:1)')));

      final second = LoggerCacheRepositoryImpl(maxLogEntries: 100, directoryToSave: tempDir.path);

      final warnings = await second.getLogsByType(EnumLoggerType.warning);
      expect(warnings.map((log) => log.message), equals(['w2', 'w1']));
      expect(warnings.first.logCreationDate, equals(DateTime(2024, 1, 2)));
      final errors = await second.getLogsByType(EnumLoggerType.error);
      expect((errors.single as ErrorLog).stackTrace.toString(), contains('main'));
    });

    test('clearLogsByType deletes the file for that type', () async {
      final repository = LoggerCacheRepositoryImpl(
        maxLogEntries: 100,
        directoryToSave: tempDir.path,
      );
      await repository.addLog(DebugLog('debug'));
      await repository.addLog(InfoLog('info'));

      await repository.clearLogsByType(EnumLoggerType.debug);

      expect(await File(path.join(logsDir(), 'debug.json')).exists(), isFalse);
      expect(await File(path.join(logsDir(), 'info.json')).exists(), isTrue);
      final reloaded = LoggerCacheRepositoryImpl(maxLogEntries: 100, directoryToSave: tempDir.path);
      expect(await reloaded.getLogsByType(EnumLoggerType.debug), isEmpty);
      expect(await reloaded.getLogsByType(EnumLoggerType.info), hasLength(1));
    });

    test('clearLogs removes the logs directory and allows new writes', () async {
      final repository = LoggerCacheRepositoryImpl(
        maxLogEntries: 100,
        directoryToSave: tempDir.path,
      );
      await repository.addLog(DebugLog('debug'));

      await repository.clearLogs();
      expect(await Directory(logsDir()).exists(), isFalse);

      await repository.addLog(InfoLog('after clear'));
      expect(await File(path.join(logsDir(), 'info.json')).exists(), isTrue);
    });
  });
}
