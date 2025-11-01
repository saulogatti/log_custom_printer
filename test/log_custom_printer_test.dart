import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/log_printers/log_simple_print.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    late LogCustomPrinterBase awesome;

    setUp(() {
      awesome = LogCustomPrinterBase.colorPrint();
    });

    test('First Test', () {
      awesome.logDebug('logDebug');
      expect(awesome, isA<LogCustomPrinterBase>());
    });
  });
}
