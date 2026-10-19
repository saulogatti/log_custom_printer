import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/domain/log_helpers/log_exception.dart';
import 'package:log_custom_printer/src/domain/logs_object/logger_json_list_type.dart';
import 'package:test/test.dart';

void main() {
  group('EnumLoggerTypeExtension.fromString', () {
    test('accepts class names', () {
      expect(EnumLoggerTypeExtension.fromString('DebugLog'), equals(EnumLoggerType.debug));
      expect(EnumLoggerTypeExtension.fromString('InfoLog'), equals(EnumLoggerType.info));
      expect(EnumLoggerTypeExtension.fromString('WarningLog'), equals(EnumLoggerType.warning));
      expect(EnumLoggerTypeExtension.fromString('ErrorLog'), equals(EnumLoggerType.error));
    });

    test('accepts enum names', () {
      for (final type in EnumLoggerType.values) {
        expect(EnumLoggerTypeExtension.fromString(type.name), equals(type));
      }
    });

    test('throws for unknown names', () {
      expect(() => EnumLoggerTypeExtension.fromString('Verbose'), throwsArgumentError);
    });
  });

  group('LoggerJsonListType.fromJson', () {
    test('throws LogException when type is missing', () {
      expect(
        () => LoggerJsonListType.fromJson({'loggerJson': <Object>[]}),
        throwsA(isA<LogException>()),
      );
    });

    test('throws LogException when type is not a string', () {
      expect(
        () => LoggerJsonListType.fromJson({'type': 1, 'loggerJson': <Object>[]}),
        throwsA(isA<LogException>()),
      );
    });

    test('returns an empty list when loggerJson is missing', () {
      final list = LoggerJsonListType.fromJson({'type': 'info'});

      expect(list.type, equals(EnumLoggerType.info));
      expect(list.loggerEntries, isEmpty);
      expect(list.enumLoggerType, isNull);
    });

    test('skips entries that are not JSON objects', () {
      final list = LoggerJsonListType.fromJson({
        'type': 'debug',
        'loggerJson': [
          'not an object',
          42,
          {'message': 'valid', 'className': 'X', 'logCreationDate': '2024-01-01T00:00:00.000'},
        ],
      });

      expect(list.loggerEntries.single.message, equals('valid'));
    });

    test('builds the log class that matches the type', () {
      final list = LoggerJsonListType.fromJson({
        'type': 'error',
        'loggerJson': [
          {
            'message': 'boom',
            'className': 'X',
            'logCreationDate': '2024-01-01T00:00:00.000',
            'stackTrace': '#0 main (app.dart:1:1)',
          },
        ],
      });

      expect(list.loggerEntries.single, isA<ErrorLog>());
      expect(list.enumLoggerType, equals(EnumLoggerType.error));
    });
  });

  group('LoggerJsonListType serialization', () {
    test('toJson writes the enum name and serialized entries', () {
      final list = LoggerJsonListType(type: EnumLoggerType.warning)
        ..addLogger(WarningLog('w', createdAt: DateTime(2024)));

      final json = list.toJson();

      expect(json['type'], equals('warning'));
      final entries = json['loggerJson'] as List<dynamic>;
      expect((entries.single as Map<String, dynamic>)['message'], equals('w'));
    });

    test('toJson and fromJson round-trip keeps the same entries', () {
      final list = LoggerJsonListType(type: EnumLoggerType.info)
        ..addLogger(InfoLog('first', createdAt: DateTime(2024)))
        ..addLogger(InfoLog('second', createdAt: DateTime(2024, 1, 2)));

      final restored = LoggerJsonListType.fromJson(list.toJson());

      expect(restored.type, equals(EnumLoggerType.info));
      expect(
        restored.loggerEntries.map((log) => log.message),
        unorderedEquals(['first', 'second']),
      );
    });

    test('toJson and fromJson round-trip keeps newest first', () {
      final list = LoggerJsonListType(type: EnumLoggerType.info)
        ..addLogger(InfoLog('first', createdAt: DateTime(2024)))
        ..addLogger(InfoLog('second', createdAt: DateTime(2024, 1, 2)));

      final restored = LoggerJsonListType.fromJson(list.toJson());

      expect(restored.loggerEntries.map((log) => log.message), equals(['second', 'first']));
    });

    test('fromJson keeps the newest entries when over the limit', () {
      final list = LoggerJsonListType(type: EnumLoggerType.info, valueMaxNumberOfEntries: 2)
        ..addLogger(InfoLog('first', createdAt: DateTime(2024)))
        ..addLogger(InfoLog('second', createdAt: DateTime(2024, 1, 2)))
        ..addLogger(InfoLog('third', createdAt: DateTime(2024, 1, 3)));

      expect(list.loggerEntries.map((log) => log.message), equals(['third', 'second']));
    });
  });

  group('LoggerJsonListType entries', () {
    test('loggerEntries returns a defensive copy', () {
      final list = LoggerJsonListType(type: EnumLoggerType.debug)..addLogger(DebugLog('d'));

      list.loggerEntries.clear();

      expect(list.loggerEntries, hasLength(1));
    });

    test('addLoggerList inserts each entry at the front', () {
      final list = LoggerJsonListType(type: EnumLoggerType.debug)
        ..addLoggerList([DebugLog('a'), DebugLog('b'), DebugLog('c')]);

      expect(list.loggerEntries.map((log) => log.message), equals(['c', 'b', 'a']));
    });

    test('mergeLoggerList interleaves by creation date, newest first', () {
      final list = LoggerJsonListType(type: EnumLoggerType.debug)
        ..addLoggerList([
          DebugLog('a1', createdAt: DateTime(2024)),
          DebugLog('a3', createdAt: DateTime(2024, 1, 3)),
        ])
        ..mergeLoggerList([
          DebugLog('b4', createdAt: DateTime(2024, 1, 4)),
          DebugLog('b2', createdAt: DateTime(2024, 1, 2)),
        ]);

      expect(list.loggerEntries.map((log) => log.message), equals(['b4', 'a3', 'b2', 'a1']));
    });

    test('enumLoggerType reflects the first entry', () {
      final list = LoggerJsonListType(type: EnumLoggerType.debug);
      expect(list.enumLoggerType, isNull);

      list.addLogger(DebugLog('d'));
      expect(list.enumLoggerType, equals(EnumLoggerType.debug));
    });
  });
}
