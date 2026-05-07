import 'package:flutter_test/flutter_test.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

void main() {
  group('WarningLog', () {
    test('constructor sets properties correctly', () {
      final now = DateTime.now();
      final log = WarningLog('Test message', typeClass: String);

      expect(log.message, equals('Test message'));
      expect(log.className, equals('String'));
      expect(log.logCreationDate.isAfter(now) || log.logCreationDate.isAtSameMomentAs(now), isTrue);
    });

    test('constructor throws AssertionError on empty message', () {
      expect(() => WarningLog(''), throwsAssertionError);
      expect(() => WarningLog('   '), throwsAssertionError);
    });

    test('className defaults to WarningLog if typeClass is null', () {
      final log = WarningLog('Test message');
      expect(log.className, equals('WarningLog'));
    });

    test('getColor returns green ANSI color', () {
      final log = WarningLog('Test message');
      final color = log.getColor();
      expect(color.enumAnsiColors, equals(EnumAnsiColors.green));
    });

    test('toJson and fromJson are consistent', () {
      final log = WarningLog('Test message', typeClass: String);
      final json = log.toJson();

      expect(json['message'], equals('Test message'));
      expect(json['className'], equals('String'));
      expect(json['logCreationDate'], isA<String>());

      final restoredLog = WarningLog.fromJson(json);
      expect(restoredLog.message, equals(log.message));
      expect(restoredLog.className, equals(log.className));
      expect(restoredLog.logCreationDate, equals(log.logCreationDate));
    });

    test('getMessage formats correctly with and without color', () {
      final log = WarningLog('Test message');
      // Use the created date from the log to ensure exact match in formatted string
      final dateStr = log.logCreationDate.toIso8601String().split('T').join(' ').substring(0, 19);

      final messageNoColor = log.getMessage(false);
      expect(messageNoColor, contains(dateStr));
      expect(messageNoColor, contains('Test message'));

      final messageWithColor = log.getMessage(true);
      expect(messageWithColor, startsWith('\x1B[32m')); // Green FG
      expect(messageWithColor, endsWith('\x1B[0m')); // Reset
    });

    test('getStartLog formats correctly with and without color', () {
      final log = WarningLog('Test message', typeClass: String);

      final startNoColor = log.getStartLog(false);
      expect(startNoColor, equals('WARNINGLOG - STRING'));

      final startWithColor = log.getStartLog(true);
      expect(startWithColor, startsWith('\x1B[32m'));
      expect(startWithColor, contains('WARNINGLOG - STRING'));
      expect(startWithColor, endsWith('\x1B[0m'));
    });

    test('toString returns formatted message with color', () {
      final log = WarningLog('Test message');
      expect(log.toString(), equals(log.getMessage(true)));
    });
  });
}
