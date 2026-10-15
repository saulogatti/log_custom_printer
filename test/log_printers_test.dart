import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

List<String> _capturePrints(void Function() body) {
  final lines = <String>[];
  runZoned<void>(
    body,
    zoneSpecification: ZoneSpecification(print: (self, parent, zone, line) => lines.add(line)),
  );
  return lines;
}

void main() {
  final fixedDate = DateTime(2024, 5, 6, 7, 8, 9, 10);

  group('LogSimplePrint', () {
    test('prints one line with class name, timestamp and message', () {
      final log = InfoLog('server started', createdAt: fixedDate, typeClass: _Server);

      final lines = _capturePrints(() => const LogSimplePrint().printLog(log));

      expect(lines, equals(['[_Server] 06/05/2024 07:08:09.010 server started']));
    });

    test('never emits ANSI codes', () {
      final lines = _capturePrints(() {
        const LogSimplePrint()
          ..printLog(DebugLog('d'))
          ..printLog(WarningLog('w'))
          ..printLog(ErrorLog('e', StackTrace.fromString('#0 main (app.dart:1:1)')));
      });

      expect(lines, hasLength(3));
      for (final line in lines) {
        expect(line, isNot(contains(LoggerAnsiColor.ansiEsc)));
      }
    });

    test('includes the stack frames of an ErrorLog', () {
      final log = ErrorLog(
        'crash',
        StackTrace.fromString('#0      main (package:app/main.dart:1:1)\n'),
        typeClass: _Server,
      );

      final lines = _capturePrints(() => const LogSimplePrint().printLog(log));

      expect(lines.single, startsWith('[_Server] '));
      expect(lines.single, contains('#0 = main (package:app/main.dart:1:1)'));
    });
  });

  group('LogWithColorPrint', () {
    test('formats a log without using print', () {
      final lines = _capturePrints(() {
        const LogWithColorPrint().printLog(ErrorLog('e', StackTrace.current));
      });

      expect(lines, isEmpty);
    });
  });

  group('End to end with the simple printer', () {
    tearDown(() async {
      await GetIt.instance.reset();
    });

    test('a disabled config prints only errors', () {
      registerLogPrinterSimple();

      final lines = _capturePrints(() {
        DebugLog('hidden').sendLog();
        ErrorLog('visible', StackTrace.empty).sendLog();
      });

      expect(lines.single, contains('visible'));
    });
  });
}

class _Server;
