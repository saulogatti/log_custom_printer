import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/log_custom_printer.dart';

void main() {
  group("Testes registro print simples", () {
    tearDown(() async {
      await GetIt.instance.reset();
    });

    test("Teste register printer", () async {
      // Your test code here
      final teste = registerLogPrinterSimple(
        config: const ConfigLog(enableLog: true),
        maxLogsInCache: 50,
      );
      final logger = _FakeClassLog();
      logger.testLog();
      expect(teste, isNotNull);
      await teste.getAllLogs().then((logs) {
        expect(logs.length, 1);
        expect(logs.first.message, "Teste de log simples");
      });
    });
    test("sendLog sem registerLogPrinter* lança StateError", () {
      final logger = _FakeClassLog();
      expect(
        logger.testLog,
        throwsStateError,
      );
    });
  });
}

class _FakeClassLog with LoggerClassMixin {
  @override
  Type get logClassType => runtimeType;

  void testLog() {
    logInfo("Teste de log simples");
  }
}
