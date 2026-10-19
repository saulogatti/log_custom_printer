import 'package:json_annotation/json_annotation.dart' show CheckedFromJsonException;
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

void main() {
  final fixedDate = DateTime(2024, 2, 3, 4, 5, 6, 7);

  group('Log colors', () {
    test('each type uses its documented ANSI color', () {
      expect(DebugLog('m').getColor().enumAnsiColors, equals(EnumAnsiColors.yellow));
      expect(InfoLog('m').getColor().enumAnsiColors, equals(EnumAnsiColors.white));
      expect(WarningLog('m').getColor().enumAnsiColors, equals(EnumAnsiColors.green));
      expect(ErrorLog('m', StackTrace.empty).getColor().enumAnsiColors, equals(EnumAnsiColors.red));
    });

    test('only ErrorLog is alwaysPrint', () {
      expect(DebugLog('m').alwaysPrint, isFalse);
      expect(InfoLog('m').alwaysPrint, isFalse);
      expect(WarningLog('m').alwaysPrint, isFalse);
      expect(ErrorLog('m', StackTrace.empty).alwaysPrint, isTrue);
    });
  });

  group('LoggerEnum.enumLoggerType', () {
    test('maps each log class to its enum value', () {
      expect(DebugLog('m').enumLoggerType, equals(EnumLoggerType.debug));
      expect(InfoLog('m').enumLoggerType, equals(EnumLoggerType.info));
      expect(WarningLog('m').enumLoggerType, equals(EnumLoggerType.warning));
      expect(ErrorLog('m', StackTrace.empty).enumLoggerType, equals(EnumLoggerType.error));
    });

    test('falls back to debug for the base class', () {
      expect(LoggerObjectBase('m').enumLoggerType, equals(EnumLoggerType.debug));
    });
  });

  group('LoggerObjectBase', () {
    test('uses createdAt when provided', () {
      expect(DebugLog('m', createdAt: fixedDate).logCreationDate, equals(fixedDate));
    });

    test('uses the emitting class name when typeClass is given', () {
      expect(InfoLog('m', typeClass: _Emitter).className, equals('_Emitter'));
      expect(InfoLog('m').className, equals('InfoLog'));
    });

    test('rejects blank messages for every type', () {
      expect(() => DebugLog(''), throwsA(isA<AssertionError>()));
      expect(() => InfoLog(' \n '), throwsA(isA<AssertionError>()));
      expect(() => ErrorLog('  ', StackTrace.empty), throwsA(isA<AssertionError>()));
    });

    test('keeps an explicit tag', () {
      expect(LoggerObjectBase('m', tag: 'network').tag, equals('network'));
    });

    test('base class falls back to white', () {
      expect(LoggerObjectBase('m').getColor().enumAnsiColors, equals(EnumAnsiColors.white));
    });

    test('base class JSON round-trip keeps every field', () {
      final log = LoggerObjectBase(
        'saved',
        tag: 'storage',
        typeClass: _Emitter,
        createdAt: fixedDate,
      );

      final restored = LoggerObjectBase.fromJson(log.toJson());

      expect(restored.message, equals('saved'));
      expect(restored.tag, equals('storage'));
      expect(restored.className, equals('_Emitter'));
      expect(restored.logCreationDate, equals(fixedDate));
    });

    test('builds a default tag that contains the message', () {
      final log = LoggerObjectBase('payment failed', typeClass: _Emitter);

      expect(log.tag, contains('payment failed'));
      expect(log.tag, contains('_Emitter'));
    });

    test('getMessage prefixes the formatted timestamp', () {
      final log = DebugLog('hello', createdAt: fixedDate);

      expect(log.getMessage(withColor: false), equals('03/02/2024 04:05:06.007 hello'));
    });

    test('getMessage wraps the line with the type color', () {
      final log = DebugLog('hello', createdAt: fixedDate);

      expect(
        log.getMessage(),
        equals('${_ansiEscape}33m03/02/2024 04:05:06.007 hello${LoggerAnsiColor.ansiDefault}'),
      );
    });

    test('getStartLog shows the log type and source class', () {
      final log = ErrorLog('m', StackTrace.empty, typeClass: _Emitter);

      expect(log.getStartLog(withColor: false), equals('ERRORLOG - _EMITTER'));
      expect(log.getStartLog(), startsWith('${_ansiEscape}31m'));
    });
  });

  group('JSON round-trip', () {
    test('DebugLog keeps message, class and date', () {
      final log = DebugLog('debug message', createdAt: fixedDate, typeClass: _Emitter);

      final restored = DebugLog.fromJson(log.toJson());

      expect(restored.message, equals('debug message'));
      expect(restored.className, equals('_Emitter'));
      expect(restored.logCreationDate, equals(fixedDate));
    });

    test('InfoLog keeps message, class and date', () {
      final log = InfoLog('info message', createdAt: fixedDate, typeClass: _Emitter);

      final restored = InfoLog.fromJson(log.toJson());

      expect(restored.message, equals('info message'));
      expect(restored.className, equals('_Emitter'));
      expect(restored.logCreationDate, equals(fixedDate));
    });

    test('ErrorLog keeps the stack trace text', () {
      final stack = StackTrace.fromString('#0      main (package:app/main.dart:1:1)\n');
      final log = ErrorLog('error message', stack, createdAt: fixedDate);

      final json = log.toJson();
      final restored = ErrorLog.fromJson(json);

      expect(json['stackTrace'], equals(stack.toString()));
      expect(restored.stackTrace.toString(), equals(stack.toString()));
      expect(restored.logCreationDate, equals(fixedDate));
    });

    test('fromJson rejects a missing message', () {
      expect(
        () => DebugLog.fromJson({'className': 'X', 'logCreationDate': '2024-01-01T00:00:00'}),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });

    test('fromJson rejects an invalid date', () {
      expect(
        () => InfoLog.fromJson({'message': 'm', 'className': 'X', 'logCreationDate': 'nope'}),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });

    test('log types serialize only message, class and date', () {
      final json = WarningLog('m', createdAt: fixedDate).toJson();

      expect(json.keys, unorderedEquals(['message', 'className', 'logCreationDate']));
      expect(json['logCreationDate'], equals(fixedDate.toIso8601String()));
    });
  });

  group('StackTraceConverter', () {
    test('converts in both directions', () {
      const converter = StackTraceConverter();
      const text = '#0      main (package:app/main.dart:1:1)';

      expect(converter.toJson(converter.fromJson(text)), equals(text));
    });
  });

  group('ErrorLog.getMessage', () {
    final stack = StackTrace.fromString(
      '#0      Service.run (package:app/service.dart:10:5)\n'
      '#1      _rootRun (dart:async/zone.dart:1428:13)\n'
      '#2      main (package:app/main.dart:3:3)\n',
    );

    test('appends the filtered stack frames without color', () {
      final message = ErrorLog('failure', stack, createdAt: fixedDate).getMessage(withColor: false);

      expect(message, startsWith('03/02/2024 04:05:06.007 failure'));
      expect(message, contains('#0 = Service.run (package:app/service.dart:10:5)'));
      expect(message, contains('#1 = main (package:app/main.dart:3:3)'));
      expect(message, isNot(contains('dart:async')));
      expect(message, isNot(contains(_ansiEscape)));
    });

    test('colors every line in red', () {
      final message = ErrorLog('failure', stack).getMessage();

      for (final line in message.split('\n\t')) {
        expect(line, startsWith('${_ansiEscape}31m'));
        expect(line, endsWith(LoggerAnsiColor.ansiDefault));
      }
    });

    test('works with an empty stack trace', () {
      final message = ErrorLog('failure', StackTrace.empty).getMessage(withColor: false);

      expect(message, endsWith('failure'));
    });

    test('appends a non-null object in red', () {
      final message = ErrorLog(
        'failure',
        StackTrace.empty,
        createdAt: fixedDate,
        object: 'payload',
      ).getMessage(withColor: false);

      expect(message, startsWith('03/02/2024 04:05:06.007 failure'));
      expect(message, endsWith('${_ansiEscape}31mObject: payload${LoggerAnsiColor.ansiDefault}'));
    });
  });
}

const _ansiEscape = '\x1B[';

class _Emitter;
