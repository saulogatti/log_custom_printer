// Unit tests for JSON list related helpers
// This file provides basic tests to validate JSON encoding/decoding

import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';
import 'package:test/test.dart';

import 'data_logs/jsons_test.dart';

void main() {
  setUp(() {
    // Setup code if needed before each test
  });
  group('logger_json_list', () {
    test('decodes JSON WarningLog', () {
      final decoded = jsonTestWarning;

      expect(decoded, isA<Map<String, dynamic>>());
      final loggerJsonList = LoggerJsonList.fromJson(decoded as Map<String, dynamic>);
      expect(loggerJsonList.loggerJson.length, greaterThan(0));
      expect(loggerJsonList.loggerJson.first, isA<WarningLog>());
    });
    test('decodes JSON DebugLog', () {
      final decoded = jsonTestDebug;

      expect(decoded, isA<Map<String, dynamic>>());
      final loggerJsonList = LoggerJsonList.fromJson(decoded as Map<String, dynamic>);
      expect(loggerJsonList.loggerJson.length, greaterThan(0));
      expect(loggerJsonList.loggerJson.first, isA<DebugLog>());
    });
    test('decodes JSON InfoLog', () {
      final decoded = jsonTestInfo;

      expect(decoded, isA<Map<String, dynamic>>());
      final loggerJsonList = LoggerJsonList.fromJson(decoded as Map<String, dynamic>);
      expect(loggerJsonList.loggerJson.length, greaterThan(0));
      expect(loggerJsonList.loggerJson.first, isA<InfoLog>());
    });
    test('decodes JSON ErrorLog', () {
      final decoded = jsonTestError;
      // final decoded = jsonDecode(jsonStr);

      expect(decoded, isA<Map<String, dynamic>>());
      final loggerJsonList = LoggerJsonList.fromJson(decoded as Map<String, dynamic>);
      expect(loggerJsonList.loggerJson.length, greaterThan(0));
      expect(loggerJsonList.loggerJson.first, isA<ErrorLog>());
    });

    test('keeps the newest entries first and trims when capacity is exceeded', () {
      final loggerJsonList = LoggerJsonList(type: 'DebugLog');

      for (int i = 0; i < 105; i++) {
        loggerJsonList.addLogger(DebugLog('log-$i'));
      }

      expect(loggerJsonList.loggerJson.length, equals(100));
      expect((loggerJsonList.loggerJson.first as DebugLog).message, equals('log-104'));
      expect((loggerJsonList.loggerJson.last as DebugLog).message, equals('log-5'));
    });
  });
}
