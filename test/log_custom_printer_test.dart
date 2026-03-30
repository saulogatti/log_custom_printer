import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/domain/log_printers/log_with_color_print.dart';
import 'package:log_custom_printer/src/log_printer_service.dart';

void main() {
  setUp(() {
    registerLogPrinterColor(config: const ConfigLog(enableLog: true));
  });

  group('Log printer com DI', () {
    test('registra impressora colorida e processa log', () {
      DebugLog('logDebug', typeClass: _TestClass).sendLog();

      final printer = GetIt.instance<LogPrinterService>().logPrinter;
      expect(printer, isA<LogWithColorPrint>());
    });
  });
}

class _TestClass {}
