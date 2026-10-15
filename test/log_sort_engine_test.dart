import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

void main() {
  const engine = LogSortEngine();

  final debugLate = DebugLog('debug-late', createdAt: DateTime(2024, 1, 1, 12));
  final infoEarly = InfoLog('info-early', createdAt: DateTime(2024, 1, 1, 8));
  final warning = WarningLog('warning', createdAt: DateTime(2024, 1, 1, 10));
  final error = ErrorLog('error', StackTrace.empty, createdAt: DateTime(2024, 1, 1, 9));
  final debugEarly = DebugLog('debug-early', createdAt: DateTime(2024, 1, 1, 7));

  late List<LoggerObjectBase> logs;

  setUp(() {
    logs = [debugLate, infoEarly, warning, error, debugEarly];
  });

  List<String> messages(List<LoggerObjectBase> list) => list.map((log) => log.message).toList();

  group('LogSortEngine.apply', () {
    test('returns the same list when no sort field is set', () {
      final result = engine.apply(logs, const LogQuery(sortDirection: SortDirection.asc));

      expect(identical(result, logs), isTrue);
    });

    test('sorts by date ascending', () {
      final result = engine.apply(
        logs,
        const LogQuery(sortField: LogSortField.date, sortDirection: SortDirection.asc),
      );

      expect(
        messages(result),
        equals(['debug-early', 'info-early', 'error', 'warning', 'debug-late']),
      );
    });

    test('sorts by date descending', () {
      final result = engine.apply(
        logs,
        const LogQuery(sortField: LogSortField.date, sortDirection: SortDirection.desc),
      );

      expect(
        messages(result),
        equals(['debug-late', 'warning', 'error', 'info-early', 'debug-early']),
      );
    });

    test('defaults to descending when no direction is set', () {
      final result = engine.apply(logs, const LogQuery(sortField: LogSortField.date));

      expect(messages(result).first, equals('debug-late'));
      expect(messages(result).last, equals('debug-early'));
    });

    test('sorts by severity ascending and breaks ties by date', () {
      final result = engine.apply(
        logs,
        const LogQuery(sortField: LogSortField.type, sortDirection: SortDirection.asc),
      );

      expect(
        messages(result),
        equals(['debug-early', 'debug-late', 'info-early', 'warning', 'error']),
      );
    });

    test('sorts by severity descending and reverses the date tie-break', () {
      final result = engine.apply(
        logs,
        const LogQuery(sortField: LogSortField.type, sortDirection: SortDirection.desc),
      );

      expect(
        messages(result),
        equals(['error', 'warning', 'info-early', 'debug-late', 'debug-early']),
      );
    });

    test('does not mutate the input list', () {
      final original = List<LoggerObjectBase>.from(logs);

      engine.apply(
        logs,
        const LogQuery(sortField: LogSortField.date, sortDirection: SortDirection.asc),
      );

      expect(logs, equals(original));
    });

    test('handles an empty list', () {
      final result = engine.apply(
        [],
        const LogQuery(sortField: LogSortField.type, sortDirection: SortDirection.asc),
      );

      expect(result, isEmpty);
    });
  });
}
