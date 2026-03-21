import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/log_printer_service.dart';
import 'package:test/test.dart';

void main() {
  group("Testes registro print simples", () {
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
    test("Teste sem registro", () async {
      final logger = _FakeClassLog();
      logger.testLog();
      // Since no printer is registered, we expect no logs to be stored
      final cacheRepository =
          GetIt.instance<LogPrinterService>().cacheRepository;
      await expectLater(cacheRepository.getAllLogs(), completion(isEmpty));
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
