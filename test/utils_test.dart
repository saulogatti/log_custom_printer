import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/extensions/string_extension.dart';
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

    test('keeps multi-digit components unpadded', () {
      final dateTime = DateTime(2024, 12, 31, 23, 59, 58, 999);

      expect(dateTime.logFullDateTime, equals('31/12/2024 23:59:58.999'));
    });

    test('pads numbers with leading zeros', () {
      final dateTime = DateTime(2024);

      expect(dateTime.twoDigits(3), equals('03'));
      expect(dateTime.twoDigits(42), equals('42'));
      expect(dateTime.threeDigits(7), equals('007'));
      expect(dateTime.threeDigits(70), equals('070'));
      expect(dateTime.threeDigits(700), equals('700'));
    });

    test('copyWithTime overrides only the given components', () {
      final dateTime = DateTime(2024, 6, 15, 10, 20, 30);

      expect(dateTime.copyWithTime(hour: 1), equals(DateTime(2024, 6, 15, 1, 20, 30)));
      expect(dateTime.copyWithTime(minute: 0, second: 0), equals(DateTime(2024, 6, 15, 10)));
      expect(dateTime.copyWithTime(), equals(dateTime));
    });
  });

  group('LoggerAnsiColor', () {
    test('wraps messages with ANSI codes', () {
      const ansiColor = LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.green);

      final formatted = ansiColor('message');
      final expected =
          '${LoggerAnsiColor.ansiEsc}${EnumAnsiColors.green.getFgColor()}mmessage${LoggerAnsiColor.ansiDefault}';

      expect(formatted, equals(expected));
    });

    test('toString returns the foreground escape sequence', () {
      const ansiColor = LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.cyan);

      expect(ansiColor.toString(), equals('\x1B[36m'));
    });

    test('JSON round-trip keeps the color', () {
      const ansiColor = LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.magenta);

      final json = ansiColor.toJson();
      final restored = LoggerAnsiColor.fromJson(json);

      expect(json['enumAnsiColors'], equals('magenta'));
      expect(restored.enumAnsiColors, equals(EnumAnsiColors.magenta));
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
      expect(map, equals({'#0': 'MyClass.method (package:my_app/src/file.dart:10:3)'}));

      final formatted = stackTrace.formatStackTrace(
        const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.red),
        3,
      );
      expect(formatted, contains('MyClass.method (package:my_app/src/file.dart:10:3)'));
      expect(formatted, isNot(contains('flutter/src/widgets/framework.dart')));
      expect(formatted, contains(LoggerAnsiColor.ansiEsc));
    });

    test('limits the number of frames', () {
      final stackTrace = StackTrace.fromString(
        List.generate(10, (i) => '#$i      f$i (package:app/f$i.dart:1:1)').join('\n'),
      );

      final map = stackTrace.stackInMap(3);

      expect(map.keys, equals(['#0', '#1', '#2']));
      expect(map['#2'], equals('f2 (package:app/f2.dart:1:1)'));
    });

    test('formats without color when no color is given', () {
      final stackTrace = StackTrace.fromString('#0      main (package:app/main.dart:1:1)');

      final formatted = stackTrace.formatStackTrace(null, 5);

      expect(formatted, equals('#0 main (package:app/main.dart:1:1)'));
    });

    test('formatStackTrace falls back to the raw text when every frame is filtered', () {
      final stackTrace = StackTrace.fromString('#0      _rootRun (dart:async/zone.dart:1:1)');

      expect(stackTrace.formatStackTrace(null, 5), equals(stackTrace.toString()));
      expect(stackTrace.stackInMap(), isEmpty);
    });
  });

  group('EnumAnsiColors', () {
    test('getBgColor returns correct ANSI codes', () {
      expect(EnumAnsiColors.black.getBgColor(), equals(40));
      expect(EnumAnsiColors.red.getBgColor(), equals(41));
      expect(EnumAnsiColors.green.getBgColor(), equals(42));
      expect(EnumAnsiColors.yellow.getBgColor(), equals(43));
      expect(EnumAnsiColors.blue.getBgColor(), equals(44));
      expect(EnumAnsiColors.magenta.getBgColor(), equals(45));
      expect(EnumAnsiColors.cyan.getBgColor(), equals(46));
      expect(EnumAnsiColors.white.getBgColor(), equals(47));
    });

    test('getFgColor returns correct ANSI codes', () {
      expect(EnumAnsiColors.black.getFgColor(), equals(30));
      expect(EnumAnsiColors.red.getFgColor(), equals(31));
      expect(EnumAnsiColors.green.getFgColor(), equals(32));
      expect(EnumAnsiColors.yellow.getFgColor(), equals(33));
      expect(EnumAnsiColors.blue.getFgColor(), equals(34));
      expect(EnumAnsiColors.magenta.getFgColor(), equals(35));
      expect(EnumAnsiColors.cyan.getFgColor(), equals(36));
      expect(EnumAnsiColors.white.getFgColor(), equals(37));
    });
  });

  group('StringExtension', () {
    test('formattedName trims and lowercases', () {
      expect('  Saulo Gatti  '.formattedName, equals('saulo gatti'));
      expect('HELLO'.formattedName, equals('hello'));
      expect('   '.formattedName, equals(''));
      expect(''.formattedName, equals(''));
    });

    test('sanitizedFileName replaces invalid characters', () {
      expect('file<name>.log'.sanitizedFileName, equals('file_name_.log'));
      expect(r'a/b\c:d*e?f"g|h>i<j.k'.sanitizedFileName, equals('a_b_c_d_e_f_g_h_i_j.k'));

      expect('clean_name.txt'.sanitizedFileName, equals('clean_name.txt'));
      expect(''.sanitizedFileName, equals(''));
      expect('<>:"'.sanitizedFileName, equals('____'));
    });
  });
}
