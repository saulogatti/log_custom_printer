// Unit tests for JSON list related helpers
// This file provides basic tests to validate JSON encoding/decoding

import 'dart:convert';
import 'dart:io';

import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    // Setup code if needed before each test test\data_logs\debug.json
  });
  group('logger_json_list', () {
    test('decodes JSON WarningLog', () {
      File file = File('test/data_logs/warning.json');
      expect(file.existsSync(), isTrue);
      final dataStr = file.readAsStringSync();
      final jsonTestWarning = jsonDecode(dataStr);
      final decoded = jsonTestWarning;

      expect(decoded, isA<Map<String, dynamic>>());
      final loggerJsonList = LoggerJsonList.fromJson(
        decoded as Map<String, dynamic>,
      );
      expect(loggerJsonList.loggerEntries.length, greaterThan(0));
      expect(loggerJsonList.loggerEntries.first, isA<WarningLog>());
    });
    test('decodes JSON DebugLog', () {
      File file = File('test/data_logs/debug.json');
      expect(file.existsSync(), isTrue);
      final dataStr = file.readAsStringSync();
      final jsonTestDebug = jsonDecode(dataStr);
      final decoded = jsonTestDebug;

      expect(decoded, isA<Map<String, dynamic>>());
      final loggerJsonList = LoggerJsonList.fromJson(
        decoded as Map<String, dynamic>,
      );
      expect(loggerJsonList.loggerEntries.length, greaterThan(0));
      expect(loggerJsonList.loggerEntries.first, isA<DebugLog>());
    });
    test('decodes JSON InfoLog', () {
      File file = File('test/data_logs/info.json');
      expect(file.existsSync(), isTrue);
      final dataStr = file.readAsStringSync();
      final jsonTestInfo = jsonDecode(dataStr);

      final decoded = jsonTestInfo;

      expect(decoded, isA<Map<String, dynamic>>());
      final loggerJsonList = LoggerJsonList.fromJson(
        decoded as Map<String, dynamic>,
      );
      expect(loggerJsonList.loggerEntries.length, greaterThan(0));
      expect(loggerJsonList.loggerEntries.first, isA<InfoLog>());
    });
    test('decodes JSON ErrorLog', () {
      File file = File('test/data_logs/error.json');
      expect(file.existsSync(), isTrue);
      final dataStr = file.readAsStringSync();
      final jsonTestError = jsonDecode(dataStr);
      final decoded = jsonTestError;
      // final decoded = jsonDecode(jsonStr);

      expect(decoded, isA<Map<String, dynamic>>());
      final loggerJsonList = LoggerJsonList.fromJson(
        decoded as Map<String, dynamic>,
      );
      expect(loggerJsonList.loggerEntries.length, greaterThan(0));
      expect(loggerJsonList.loggerEntries.first, isA<ErrorLog>());
    });

    test(
      'keeps the newest entries first and trims when capacity is exceeded',
      () {
        final loggerJsonList = LoggerJsonList(type: 'DebugLog');

        for (int i = 0; i < 105; i++) {
          loggerJsonList.addLogger(DebugLog('log-$i'));
        }

        expect(loggerJsonList.loggerEntries.length, equals(100));
        expect(
          (loggerJsonList.loggerEntries.first as DebugLog).message,
          equals('log-104'),
        );
        expect(
          (loggerJsonList.loggerEntries.last as DebugLog).message,
          equals('log-5'),
        );
      },
    );
  });
}
