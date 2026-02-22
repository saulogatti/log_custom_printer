import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/utils/stack_trace_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeLogHelper', () {
    test('formats date and time consistently', () {
      final dateTime = DateTime(2024, 1, 5, 6, 7, 8, 9);

      expect(dateTime.onlyTime(), equals('06:07:08.009'));
      expect(dateTime.onlyDate(), equals('05/01/2024'));
      expect(dateTime.logFullDateTime, equals('05/01/2024 06:07:08.009'));
    });
  });

  group('LoggerAnsiColor', () {
    test('wraps messages with ANSI codes', () {
      final ansiColor = LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.green);

      final formatted = ansiColor('message');
      final expected =
          '${LoggerAnsiColor.ansiEsc}${EnumAnsiColors.green.getFgColor()}mmessage${LoggerAnsiColor.ansiDefault}';

      expect(formatted, equals(expected));
    });
  });

  group('StackTraceSdk', () {
    test('filters framework frames and formats output', () {
      const stackTraceString = '''
#0   MyClass.method (package:my_app/src/file.dart:10:3)
#1   Widget.build (package:flutter/src/widgets/framework.dart:123:45)
#2   _rootRun (dart:async/zone.dart:1428:13)
''';
      final stackTrace = StackTrace.fromString(stackTraceString);

      final map = stackTrace.stackInMap(3);
      expect(
        map,
        equals({'#0': 'MyClass.method (package:my_app/src/file.dart:10:3)'}),
      );

      final formatted = stackTrace.formatStackTrace(
        const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.red),
        3,
      );
      expect(
        formatted,
        contains('MyClass.method (package:my_app/src/file.dart:10:3)'),
      );
      expect(formatted, isNot(contains('flutter/src/widgets/framework.dart')));
      expect(formatted, contains(LoggerAnsiColor.ansiEsc));
    });
  });
}
