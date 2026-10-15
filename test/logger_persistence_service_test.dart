import 'dart:async';

import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

void main() {
  late LoggerPersistenceService service;

  final date1 = DateTime(2024, 3, 1, 8);
  final date2 = DateTime(2024, 3, 2, 9);
  final date3 = DateTime(2024, 3, 3, 10);
  final date4 = DateTime(2024, 3, 4, 11);

  setUp(() {
    service = LoggerPersistenceService(
      loggerPersistenceService: LoggerCacheRepositoryImpl(maxLogEntries: 100),
    );
  });

  tearDown(() {
    service.closeLogStream();
  });

  Future<void> seed() async {
    await service.addLog(DebugLog('debug', createdAt: date1, typeClass: _Alpha));
    await service.addLog(InfoLog('info', createdAt: date2, typeClass: _Beta));
    await service.addLog(WarningLog('warning', createdAt: date3, typeClass: _Alpha));
    await service.addLog(ErrorLog('error', StackTrace.empty, createdAt: date4, typeClass: _Beta));
  }

  group('LoggerPersistenceService storage', () {
    test('getAllLogs returns every stored log', () async {
      await seed();

      final logs = await service.getAllLogs();

      expect(logs, hasLength(4));
      expect(
        logs.map((log) => log.message),
        unorderedEquals(['debug', 'info', 'warning', 'error']),
      );
    });

    test('getLogsByType returns only that type', () async {
      await seed();

      final warnings = await service.getLogsByType(EnumLoggerType.warning);

      expect(warnings.single, isA<WarningLog>());
    });

    test('getLogsByType returns an empty list for a type with no logs', () async {
      await service.addLog(InfoLog('info'));

      expect(await service.getLogsByType(EnumLoggerType.error), isEmpty);
    });

    test('clearLogs removes everything', () async {
      await seed();

      await service.clearLogs();

      expect(await service.getAllLogs(), isEmpty);
    });

    test('clearLogsByType removes only that type', () async {
      await seed();

      await service.clearLogsByType(EnumLoggerType.debug);

      final logs = await service.getAllLogs();
      expect(logs, hasLength(3));
      expect(logs.whereType<DebugLog>(), isEmpty);
    });
  });

  group('LoggerPersistenceService.logStream', () {
    test('emits logs added while listening', () async {
      final received = <LoggerObjectBase>[];
      final subscription = service.logStream.listen(received.add);

      await service.addLog(InfoLog('first'));
      await service.addLog(ErrorLog('second', StackTrace.empty));
      await pumpEventQueue();

      expect(received.map((log) => log.message), equals(['first', 'second']));
      await subscription.cancel();
    });

    test('does not replay logs added before the first listener', () async {
      await service.addLog(InfoLog('before'));

      final received = <LoggerObjectBase>[];
      final subscription = service.logStream.listen(received.add);
      await service.addLog(InfoLog('after'));
      await pumpEventQueue();

      expect(received.map((log) => log.message), equals(['after']));
      await subscription.cancel();
    });

    test('closeLogStream completes the stream', () async {
      final done = Completer<void>();
      service.logStream.listen(null, onDone: done.complete);

      service.closeLogStream();

      await expectLater(done.future, completes);
    });
  });

  group('LoggerPersistenceService.queryLogs', () {
    test('returns every log for an empty query', () async {
      await seed();

      expect(await service.queryLogs(const LogQuery()), hasLength(4));
    });

    test('filters by type and sorts by date ascending', () async {
      await seed();

      final result = await service.queryLogs(
        const LogQuery(
          types: {EnumLoggerType.error, EnumLoggerType.debug},
          sortField: LogSortField.date,
          sortDirection: SortDirection.asc,
        ),
      );

      expect(result.map((log) => log.message), equals(['debug', 'error']));
    });

    test('filters by date range and sorts by severity descending', () async {
      await seed();

      final result = await service.queryLogs(
        LogQuery(
          start: date2,
          end: date4,
          sortField: LogSortField.type,
          sortDirection: SortDirection.desc,
        ),
      );

      expect(result.map((log) => log.message), equals(['warning', 'info']));
    });
  });

  group('LoggerPersistenceService search helpers', () {
    test('searchLogByCreated uses an inclusive start and exclusive end', () async {
      await seed();

      final result = await service.searchLogByCreated(start: date2, end: date4);

      expect(result.map((log) => log.message), unorderedEquals(['info', 'warning']));
    });

    test('searchLogByCreated returns nothing for an empty range', () async {
      await seed();

      final result = await service.searchLogByCreated(start: date2, end: date2);

      expect(result, isEmpty);
    });

    test('searchLogByRuntimeType matches the emitting class name', () async {
      await seed();

      final result = await service.searchLogByRuntimeType('_Alpha');

      expect(result.map((log) => log.message), unorderedEquals(['debug', 'warning']));
    });

    test('searchLogByRuntimeType returns nothing for an unknown class', () async {
      await seed();

      expect(await service.searchLogByRuntimeType('Unknown'), isEmpty);
    });

    test('searchLogByTag matches whole words of an explicit tag', () async {
      await service.addLog(LoggerObjectBase('login ok', tag: 'auth network'));
      await service.addLog(LoggerObjectBase('cache miss', tag: 'storage'));

      final auth = await service.searchLogByTag('auth');
      final partial = await service.searchLogByTag('aut');

      expect(auth.single.message, equals('login ok'));
      expect(partial, isEmpty);
    });

    test('searchLogByTag escapes regex characters in the tag', () async {
      await service.addLog(LoggerObjectBase('weird', tag: 'a.b'));
      await service.addLog(LoggerObjectBase('other', tag: 'axb'));

      final result = await service.searchLogByTag('a.b');

      expect(result.single.message, equals('weird'));
    });

    test('searchLogByTag falls back to the message in the default tag', () async {
      await service.addLog(InfoLog('payment approved'));

      final result = await service.searchLogByTag('payment');

      expect(result.single.message, equals('payment approved'));
    });
  });
}

class _Alpha;

class _Beta;
