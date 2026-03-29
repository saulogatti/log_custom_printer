import 'dart:convert';

import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/domain/log_helpers/logger_enum.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── LogFilterEngine ─────────────────────────────────────────────────────

  group('LogFilterEngine', () {
    final filter = const LogFilterEngine();

    final debug1 = DebugLog('d1')..logCreationDate = _dt(8);
    final info1 = InfoLog('i1')..logCreationDate = _dt(9);
    final warning1 = WarningLog('w1')..logCreationDate = _dt(10);
    final error1 = ErrorLog('e1', StackTrace.empty)..logCreationDate = _dt(11);

    final allLogs = <LoggerObjectBase>[debug1, info1, warning1, error1];

    test('empty query returns all logs', () {
      final result = filter.apply(allLogs, const LogQuery());
      expect(result, equals(allLogs));
    });

    test('filter by single type', () {
      final result = filter.apply(
        allLogs,
        const LogQuery(types: {EnumLoggerType.error}),
      );
      expect(result, hasLength(1));
      expect(result.single, isA<ErrorLog>());
    });

    test('filter by multiple types', () {
      final result = filter.apply(
        allLogs,
        const LogQuery(types: {EnumLoggerType.debug, EnumLoggerType.warning}),
      );
      expect(result, hasLength(2));
      expect(result.whereType<DebugLog>(), hasLength(1));
      expect(result.whereType<WarningLog>(), hasLength(1));
    });

    test('filter by date start (inclusive)', () {
      // Logs at 10:00 and 11:00 pass; 08:00 and 09:00 do not.
      final result = filter.apply(allLogs, LogQuery(start: _dt(10)));
      expect(result, hasLength(2));
      expect(result, containsAll([warning1, error1]));
    });

    test('filter by date end (exclusive)', () {
      // Logs before 10:00 pass; 10:00 itself does NOT.
      final result = filter.apply(allLogs, LogQuery(end: _dt(10)));
      expect(result, hasLength(2));
      expect(result, containsAll([debug1, info1]));
    });

    test('filter by date range [start, end)', () {
      // Range [09:00, 11:00) → logs at 09:00 and 10:00.
      final result = filter.apply(
        allLogs,
        LogQuery(start: _dt(9), end: _dt(11)),
      );
      expect(result, hasLength(2));
      expect(result, containsAll([info1, warning1]));
    });

    test('filter by type AND date range', () {
      // Only ErrorLog within [10:00, 12:00) — error is at 11:00.
      final result = filter.apply(
        allLogs,
        LogQuery(types: {EnumLoggerType.error}, start: _dt(10), end: _dt(12)),
      );
      expect(result, hasLength(1));
      expect(result.single, isA<ErrorLog>());
    });

    test('returns empty list when no logs match', () {
      final result = filter.apply(allLogs, LogQuery(start: _dt(20)));
      expect(result, isEmpty);
    });

    test('empty types set is treated as no type filter', () {
      final result = filter.apply(allLogs, const LogQuery(types: {}));
      expect(result, equals(allLogs));
    });
  });

  // ── LogSortEngine ────────────────────────────────────────────────────────

  group('LogSortEngine', () {
    final sorter = const LogSortEngine();

    final debug1 = DebugLog('d1')..logCreationDate = _dt(10);
    final info1 = InfoLog('i1')..logCreationDate = _dt(8);
    final warning1 = WarningLog('w1')..logCreationDate = _dt(12);
    final error1 = ErrorLog('e1', StackTrace.empty)..logCreationDate = _dt(6);

    final unsorted = <LoggerObjectBase>[warning1, debug1, error1, info1];

    test('no sortField returns original list unchanged', () {
      final result = sorter.apply(unsorted, const LogQuery());
      expect(result, equals(unsorted));
    });

    test('sort by date asc', () {
      final result = sorter.apply(
        unsorted,
        const LogQuery(sortField: LogSortField.date),
      );
      // Expected: error1(6), info1(8), debug1(10), warning1(12)
      expect(result[0], isA<ErrorLog>());
      expect(result[1], isA<InfoLog>());
      expect(result[2], isA<DebugLog>());
      expect(result[3], isA<WarningLog>());
    });

    test('sort by date desc', () {
      final result = sorter.apply(
        unsorted,
        const LogQuery(
          sortField: LogSortField.date,
          sortDirection: SortDirection.desc,
        ),
      );
      // Expected: warning1(12), debug1(10), info1(8), error1(6)
      expect(result[0], isA<WarningLog>());
      expect(result[1], isA<DebugLog>());
      expect(result[2], isA<InfoLog>());
      expect(result[3], isA<ErrorLog>());
    });

    test('sort by type asc (severity: debug < info < warning < error)', () {
      final result = sorter.apply(
        unsorted,
        const LogQuery(sortField: LogSortField.type),
      );
      expect(result[0], isA<DebugLog>());
      expect(result[1], isA<InfoLog>());
      expect(result[2], isA<WarningLog>());
      expect(result[3], isA<ErrorLog>());
    });

    test('sort by type desc (severity: error > warning > info > debug)', () {
      final result = sorter.apply(
        unsorted,
        const LogQuery(
          sortField: LogSortField.type,
          sortDirection: SortDirection.desc,
        ),
      );
      expect(result[0], isA<ErrorLog>());
      expect(result[1], isA<WarningLog>());
      expect(result[2], isA<InfoLog>());
      expect(result[3], isA<DebugLog>());
    });

    test('sort by type uses date asc as stable tiebreaker', () {
      final d1 = DebugLog('first')..logCreationDate = _dt(5);
      final d2 = DebugLog('second')..logCreationDate = _dt(7);
      final d3 = DebugLog('third')..logCreationDate = _dt(3);

      final result = sorter.apply([
        d2,
        d3,
        d1,
      ], const LogQuery(sortField: LogSortField.type));
      // All debug → stable tiebreak by date asc: d3(3), d1(5), d2(7)
      expect((result[0] as DebugLog).message, equals('third'));
      expect((result[1] as DebugLog).message, equals('first'));
      expect((result[2] as DebugLog).message, equals('second'));
    });

    test('sort does not mutate the original list', () {
      final original = List<LoggerObjectBase>.from(unsorted);
      sorter.apply(unsorted, const LogQuery(sortField: LogSortField.date));
      expect(unsorted, equals(original));
    });
  });

  // ── LogExportService ─────────────────────────────────────────────────────

  group('LogExportService', () {
    final exporter = const LogExportService();
    final fixedDate = DateTime(2024, 1, 15, 10, 30);

    final debug1 = DebugLog('hello debug')..logCreationDate = fixedDate;
    final error1 = ErrorLog('boom', StackTrace.empty)
      ..logCreationDate = fixedDate;

    group('JSON export', () {
      test('produces valid JSON array', () {
        final output = exporter.export([debug1], ExportFormat.json);
        final decoded = jsonDecode(output) as List;
        expect(decoded, hasLength(1));
      });

      test('each entry contains logType field', () {
        final output = exporter.export([debug1, error1], ExportFormat.json);
        final decoded = jsonDecode(output) as List;
        final types = decoded
            .map((e) => (e as Map<String, dynamic>)['logType'])
            .toList();
        expect(types, containsAll(['DebugLog', 'ErrorLog']));
      });

      test('JSON is consistent with toJson fields', () {
        final output = exporter.export([debug1], ExportFormat.json);
        final decoded = jsonDecode(output) as List;
        final entry = decoded.first as Map<String, dynamic>;
        final expected = debug1.toJson();
        for (final key in expected.keys) {
          expect(entry, containsPair(key, expected[key]));
        }
      });

      test('empty list exports empty JSON array', () {
        final output = exporter.export([], ExportFormat.json);
        expect(jsonDecode(output), isEmpty);
      });
    });

    group('TXT export', () {
      test('produces one line per log', () {
        final output = exporter.export([debug1, error1], ExportFormat.txt);
        final lines = output.split('\n');
        expect(lines, hasLength(2));
      });

      test('each line contains the log type', () {
        final output = exporter.export([debug1], ExportFormat.txt);
        expect(output, contains('DebugLog'));
      });

      test('each line contains the ISO8601 date', () {
        final output = exporter.export([debug1], ExportFormat.txt);
        expect(output, contains(fixedDate.toIso8601String()));
      });

      test('each line contains the message', () {
        final output = exporter.export([debug1], ExportFormat.txt);
        expect(output, contains('hello debug'));
      });

      test('empty list exports empty string', () {
        final output = exporter.export([], ExportFormat.txt);
        expect(output, isEmpty);
      });
    });
  });

  // ── LoggerPersistenceService.queryLogs ───────────────────────────────────

  group('LoggerPersistenceService.queryLogs', () {
    late LoggerPersistenceService service;

    final debug1 = DebugLog('d1')..logCreationDate = _dt(8);
    final info1 = InfoLog('i1')..logCreationDate = _dt(10);
    final error1 = ErrorLog('e1', StackTrace.empty)..logCreationDate = _dt(12);

    setUp(() {
      service = _makeService([debug1, info1, error1]);
    });

    test('empty query returns all logs', () async {
      final result = await service.queryLogs(const LogQuery());
      expect(result, hasLength(3));
    });

    test('filter by type via query', () async {
      final result = await service.queryLogs(
        const LogQuery(types: {EnumLoggerType.info}),
      );
      expect(result, hasLength(1));
      expect(result.single, isA<InfoLog>());
    });

    test('filter by date range via query', () async {
      final result = await service.queryLogs(
        LogQuery(start: _dt(10), end: _dt(13)),
      );
      expect(result, hasLength(2));
      expect(result, containsAll([info1, error1]));
    });

    test('sort by date asc via query', () async {
      final result = await service.queryLogs(
        const LogQuery(sortField: LogSortField.date),
      );
      expect(result.first, isA<DebugLog>());
      expect(result.last, isA<ErrorLog>());
    });

    test('combined filter + sort (desc)', () async {
      final result = await service.queryLogs(
        LogQuery(
          types: {EnumLoggerType.debug, EnumLoggerType.error},
          sortField: LogSortField.date,
          sortDirection: SortDirection.desc,
        ),
      );
      expect(result, hasLength(2));
      expect(result.first, isA<ErrorLog>());
      expect(result.last, isA<DebugLog>());
    });
  });

  // ── LoggerPersistenceService.exportLogs ──────────────────────────────────

  group('LoggerPersistenceService.exportLogs', () {
    late LoggerPersistenceService service;

    final debug1 = DebugLog('msg-debug')..logCreationDate = _dt(8);
    final error1 = ErrorLog('msg-error', StackTrace.empty)
      ..logCreationDate = _dt(12);

    setUp(() {
      service = _makeService([debug1, error1]);
    });

    test('exports all logs as JSON', () async {
      final output = await service.exportLogs(
        const LogQuery(),
        ExportFormat.json,
      );
      final decoded = jsonDecode(output) as List;
      expect(decoded, hasLength(2));
    });

    test('exports filtered logs as JSON', () async {
      final output = await service.exportLogs(
        const LogQuery(types: {EnumLoggerType.error}),
        ExportFormat.json,
      );
      final decoded = jsonDecode(output) as List;
      expect(decoded, hasLength(1));
      expect(
        (decoded.first as Map<String, dynamic>)['logType'],
        equals('ErrorLog'),
      );
    });

    test('exports all logs as TXT', () async {
      final output = await service.exportLogs(
        const LogQuery(),
        ExportFormat.txt,
      );
      final lines = output.split('\n');
      expect(lines, hasLength(2));
    });

    test('exports filtered logs as TXT', () async {
      final output = await service.exportLogs(
        const LogQuery(types: {EnumLoggerType.debug}),
        ExportFormat.txt,
      );
      expect(output, contains('DebugLog'));
      expect(output, contains('msg-debug'));
      expect(output, isNot(contains('ErrorLog')));
    });
  });

  // ── Regression: existing LoggerPersistenceService methods ────────────────

  group('LoggerPersistenceService regression', () {
    late LoggerPersistenceService service;

    setUp(() {
      service = LoggerPersistenceService(
        cacheRepository: _FakeCacheRepository(),
      );
    });

    test('addLog and getAllLogs work as before', () async {
      await service.addLog(DebugLog('test'));
      final logs = await service.getAllLogs();
      expect(logs, hasLength(1));
    });

    test('clearLogs removes all entries', () async {
      await service.addLog(InfoLog('a'));
      await service.addLog(InfoLog('b'));
      await service.clearLogs();
      expect(await service.getAllLogs(), isEmpty);
    });

    test('getLogsByType returns matching type only', () async {
      await service.addLog(DebugLog('d'));
      await service.addLog(InfoLog('i'));
      final debugLogs = await service.getLogsByType(EnumLoggerType.debug);
      expect(debugLogs, hasLength(1));
      expect(debugLogs.single, isA<DebugLog>());
    });

    test('searchLogByCreated filters by date range [start, end)', () async {
      final base = DateTime(2024, 1, 1);
      final old = DebugLog('old')..logCreationDate = base;
      final mid = DebugLog('mid')
        ..logCreationDate = base.add(const Duration(hours: 1));
      final fresh = DebugLog('new')
        ..logCreationDate = base.add(const Duration(hours: 2));
      await service.addLog(old);
      await service.addLog(mid);
      await service.addLog(fresh);

      final result = await service.searchLogByCreated(
        start: base.add(const Duration(hours: 1)),
        end: base.add(const Duration(hours: 2)),
      );
      expect(result, hasLength(1));
      expect((result.single as DebugLog).message, equals('mid'));
    });

    test('clearLogsByType removes only matching type', () async {
      await service.addLog(DebugLog('d'));
      await service.addLog(InfoLog('i'));
      await service.clearLogsByType(EnumLoggerType.debug);
      final remaining = await service.getAllLogs();
      expect(remaining, hasLength(1));
      expect(remaining.single, isA<InfoLog>());
    });

    test('logOutputHandler is called on addLog', () async {
      final notifications = <List<LoggerObjectBase>>[];
      service.logOutputHandler = notifications.add;

      await service.addLog(DebugLog('x'));

      expect(notifications, hasLength(1));
      expect(notifications.single, hasLength(1));
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

DateTime _dt(int hour, [int minute = 0]) => DateTime(2024, 1, 15, hour, minute);

/// Creates a [LoggerPersistenceService] backed by a fake repo pre-seeded
/// with [initialLogs].
///
/// The list is inserted in reverse so that, after [_FakeCacheRepository.addLog]
/// inserts each element at index 0, the resulting order in the repository
/// mirrors the original [initialLogs] order (first element first).
LoggerPersistenceService _makeService(List<LoggerObjectBase> initialLogs) {
  final repo = _FakeCacheRepository();
  for (final log in initialLogs.reversed) {
    repo.addLog(log);
  }
  return LoggerPersistenceService(cacheRepository: repo);
}

// ---------------------------------------------------------------------------
// Fake in-memory repository (no file I/O, no GetIt).
// ---------------------------------------------------------------------------

class _FakeCacheRepository implements ILoggerCacheRepository {
  final List<LoggerObjectBase> _logs = [];

  @override
  Future<void> addLog(LoggerObjectBase log) async => _logs.insert(0, log);

  @override
  Future<void> clearLogs() async => _logs.clear();

  @override
  Future<void> clearLogsByType(EnumLoggerType type) async =>
      _logs.removeWhere((l) => l.enumLoggerType == type);

  @override
  Future<List<LoggerObjectBase>> getAllLogs() async =>
      List<LoggerObjectBase>.from(_logs);

  @override
  Future<List<LoggerObjectBase>> getLogsByType(EnumLoggerType type) async =>
      _logs.where((l) => l.enumLoggerType == type).toList();
}
