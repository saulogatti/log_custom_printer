import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/domain/log_helpers/logger_class_mixin.dart';
import 'package:log_custom_printer/src/domain/query/log_query.dart';
import 'package:log_custom_printer/src/log_printer_locator.dart';
import 'package:test/test.dart';

void main() {
  group('Testes registro print simples', () {
    tearDown(() async {
      await GetIt.instance.reset();
    });

    test('Teste register printer', () async {
      // Your test code here
      final logPrinter = registerLogPrinterSimple(
        config: const ConfigLog(enableLog: true),
        maxLogsInCache: 50,
      );
      final logger = _FakeClassLog();
      logger.testLog();
      expect(logPrinter, isNotNull);
      await logPrinter.queryLogs(const LogQuery()).then((logs) {
        expect(logs.length, 1);
        expect(logs.first.message, 'Teste de log simples');
      });
    });
    test('sendLog sem registerLogPrinter* lança StateError', () {
      final logger = _FakeClassLog();
      expect(logger.testLog, throwsStateError);
    });
  });
}

class _FakeClassLog with LoggerClassMixin {
  @override
  Type get logClassType => runtimeType;

  void testLog() {
    logInfo('Teste de log simples');
  }
}
