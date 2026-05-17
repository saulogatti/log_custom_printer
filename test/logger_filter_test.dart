import 'package:flutter_test/flutter_test.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/domain/query/logger_filter.dart';

void main() {
  group('LoggerFilter', () {
    final debug1 = DebugLog('d1')..logCreationDate = DateTime(2024, 1, 1, 10, 0);
    final info1 = InfoLog('i1')..logCreationDate = DateTime(2024, 1, 1, 9, 0);
    final error1 = ErrorLog('e1', StackTrace.current)..logCreationDate = DateTime(2024, 1, 1, 11, 0);

    final allLogs = <LoggerObjectBase>[debug1, info1, error1];

    test('delegates to LogFilterEngine when types is not empty', () {
      final query = LogQuery(
        types: {EnumLoggerType.error},
        sortDirection: SortDirection.asc, // Should be ignored if types is present
      );
      final filter = LoggerFilter(query: query);

      final result = filter.apply(allLogs);

      expect(result, hasLength(1));
      expect(result.first, isA<ErrorLog>());
    });

    test('delegates to LogSortEngine when types is empty and sortDirection is asc', () {
      final query = const LogQuery(
        types: {},
        sortField: LogSortField.date,
        sortDirection: SortDirection.asc,
      );
      final filter = LoggerFilter(query: query);

      final result = filter.apply(allLogs);

      expect(result, hasLength(3));
      expect(result[0], equals(info1));
      expect(result[1], equals(debug1));
      expect(result[2], equals(error1));
    });

    test('delegates to LogSortEngine when types is empty and sortDirection is desc', () {
      final query = const LogQuery(
        types: {},
        sortField: LogSortField.date,
        sortDirection: SortDirection.desc,
      );
      final filter = LoggerFilter(query: query);

      final result = filter.apply(allLogs);

      expect(result, hasLength(3));
      expect(result[0], equals(error1));
      expect(result[1], equals(debug1));
      expect(result[2], equals(info1));
    });

    test('returns original list when no criteria matches', () {
      final query = const LogQuery();
      final filter = LoggerFilter(query: query);

      final result = filter.apply(allLogs);

      expect(result, equals(allLogs));
    });

    test('delegates to LogSortEngine when types is null and sortDirection is asc', () {
      final query = const LogQuery(
        types: null,
        sortField: LogSortField.date,
        sortDirection: SortDirection.asc,
      );
      final filter = LoggerFilter(query: query);

      final result = filter.apply(allLogs);

      expect(result, hasLength(3));
      expect(result[0], equals(info1));
    });
  });
}
