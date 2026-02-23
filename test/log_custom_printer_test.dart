import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/log_printers/log_with_color_print.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    registerLogPrinterColor(config: const ConfigLog(enableLog: true));
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('Log printer com DI', () {
    test('registra impressora colorida e processa log', () {
      DebugLog('logDebug', typeClass: _TestClass).sendLog();

      final printer = GetIt.instance<LogPrinterBase>();
      expect(printer, isA<LogWithColorPrint>());
    });
  });
}

class _TestClass {}
