import 'package:log_custom_printer/src/domain/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/domain/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/error_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/info_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/domain/logs_object/warning_log.dart';
import 'package:log_custom_printer/src/domain/query/log_filter_engine.dart';
import 'package:log_custom_printer/src/domain/query/log_query.dart';
import 'package:test/test.dart';

void main() {
  late LogFilterEngine engine;
  late List<LoggerObjectBase> logs;

  final date1 = DateTime(2023, 10, 1, 10);
  final date2 = DateTime(2023, 10, 2, 11);
  final date3 = DateTime(2023, 10, 3, 12);
  final date4 = DateTime(2023, 10, 4, 13);

  setUp(() {
    engine = const LogFilterEngine();
    logs = [
      DebugLog('Debug log', createdAt: date1),
      InfoLog('Info log', createdAt: date2),
      WarningLog('Warning log', createdAt: date3),
      ErrorLog('Error log', StackTrace.empty, createdAt: date4),
    ];
  });

  group('LogFilterEngine.apply', () {
    test('returns all logs when query is empty', () {
      const query = LogQuery();
      final result = engine.apply(logs, query);
      expect(result.length, equals(4));
      expect(result, equals(logs));
    });

    test('filters by single log type', () {
      const query = LogQuery(types: {EnumLoggerType.error});
      final result = engine.apply(logs, query);
      expect(result.length, equals(1));
      expect(result.first, isA<ErrorLog>());
    });

    test('filters by multiple log types', () {
      const query = LogQuery(types: {EnumLoggerType.debug, EnumLoggerType.info});
      final result = engine.apply(logs, query);
      expect(result.length, equals(2));
      expect(result.any((l) => l is DebugLog), isTrue);
      expect(result.any((l) => l is InfoLog), isTrue);
    });

    test('filters by start date (inclusive)', () {
      final query = LogQuery(start: date3);
      final result = engine.apply(logs, query);
      expect(result.length, equals(2));
      expect(result.any((l) => l is WarningLog), isTrue);
      expect(result.any((l) => l is ErrorLog), isTrue);
    });

    test('filters by end date (exclusive)', () {
      final query = LogQuery(end: date3);
      final result = engine.apply(logs, query);
      expect(result.length, equals(2));
      expect(result.any((l) => l is DebugLog), isTrue);
      expect(result.any((l) => l is InfoLog), isTrue);
    });

    test('filters by date range', () {
      final query = LogQuery(start: date2, end: date4);
      final result = engine.apply(logs, query);
      expect(result.length, equals(2));
      expect(result.any((l) => l is InfoLog), isTrue);
      expect(result.any((l) => l is WarningLog), isTrue);
    });

    test('filters by type and date range combined', () {
      final query = LogQuery(
        types: {EnumLoggerType.info, EnumLoggerType.warning, EnumLoggerType.error},
        start: date2,
        end: date4,
      );
      final result = engine.apply(logs, query);
      // Info and Warning are in range. Error is NOT (exclusive end).
      expect(result.length, equals(2));
      expect(result.any((l) => l is InfoLog), isTrue);
      expect(result.any((l) => l is WarningLog), isTrue);
    });

    test('returns empty list when no logs match', () {
      final query = LogQuery(types: {EnumLoggerType.debug}, start: date4);
      final result = engine.apply(logs, query);
      expect(result, isEmpty);
    });

    test('returns empty list when input list is empty', () {
      const query = LogQuery(types: {EnumLoggerType.debug});
      final result = engine.apply([], query);
      expect(result, isEmpty);
    });

    test('handles empty types set as no type filter', () {
      const query = LogQuery(types: {});
      final result = engine.apply(logs, query);
      expect(result.length, equals(4));
    });
  });
}
