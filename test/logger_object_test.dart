import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

void main() {
  group('LoggerObjectBase.sendLog', () {
    test('respects onlyClasses filter for non-error logs', () {
      final fakePrinter = _FakeLogPrinter(
        config: const ConfigLog(enableLog: true, onlyClasses: {InfoLog}),
      );
      LogCustomPrinterBase.customPrint(logPrinterCustom: fakePrinter);

      DebugLog('debug skipped').sendLog();
      InfoLog('info allowed').sendLog();

      expect(fakePrinter.printed.length, equals(1));
      expect(fakePrinter.printed.single, isA<InfoLog>());
    });

    test('ErrorLog is printed even when logging is disabled', () {
      final fakePrinter = _FakeLogPrinter(
        config: const ConfigLog(enableLog: false, onlyClasses: <Type>{}),
      );
      LogCustomPrinterBase.customPrint(logPrinterCustom: fakePrinter);
      DebugLog('debug skipped').sendLog();
      ErrorLog('boom', StackTrace.fromString('#0 example')).sendLog();

      expect(fakePrinter.printed.length, equals(1));
      expect(fakePrinter.printed.single, isA<ErrorLog>());
    });
  });

  group('LoggerClassMixin', () {
    test('uses host runtimeType as className', () {
      final fakePrinter = _FakeLogPrinter();
      LogCustomPrinterBase.customPrint(logPrinterCustom: fakePrinter);
      final service = _FakeService();

      service.logWarning('check');

      expect(fakePrinter.printed.single.className, equals('_FakeService'));
      expect(fakePrinter.printed.single, isA<WarningLog>());
    });
  });
}

class _FakeLogPrinter extends LogPrinterBase {
  final List<LoggerObjectBase> printed = [];

  _FakeLogPrinter({super.config});

  @override
  void printLog(LoggerObjectBase log) {
    printed.add(log);
  }
}

class _FakeService with LoggerClassMixin {}
