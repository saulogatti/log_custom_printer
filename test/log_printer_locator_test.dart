import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('fetchLogPrinterService', () {
    test('registers an enabled simple printer when nothing is registered', () {
      expect(GetIt.instance.isRegistered<LogPrinterService>(), isFalse);

      final service = fetchLogPrinterService();

      expect(GetIt.instance.isRegistered<LogPrinterService>(), isTrue);
      expect(service.logPrinter, isA<LogSimplePrint>());
      expect(service.configLog.enableLog, isTrue);
    });

    test('returns the already registered service', () {
      registerLogPrinter(const LogWithColorPrint(), config: const ConfigLog());

      final service = fetchLogPrinterService();

      expect(service.logPrinter, isA<LogWithColorPrint>());
      expect(identical(service, GetIt.instance<LogPrinterService>()), isTrue);
    });
  });

  group('registerLogPrinter', () {
    test('returns the persistence service of the registered instance', () {
      final persistence = registerLogPrinter(
        const LogSimplePrint(),
        config: const ConfigLog(enableLog: true),
      );

      expect(identical(persistence, GetIt.instance<LogPrinterService>().cacheRepository), isTrue);
    });

    test('replaces a previous registration', () {
      registerLogPrinter(const LogSimplePrint(), config: const ConfigLog());
      registerLogPrinter(const LogWithColorPrint(), config: const ConfigLog(enableLog: true));

      final service = GetIt.instance<LogPrinterService>();
      expect(service.logPrinter, isA<LogWithColorPrint>());
      expect(service.configLog.enableLog, isTrue);
    });

    test('uses the provided cache repository', () async {
      final repository = LoggerCacheRepositoryImpl(maxLogEntries: 10);
      final persistence = registerLogPrinter(
        const LogSimplePrint(),
        config: const ConfigLog(enableLog: true),
        cacheRepository: repository,
      );

      await persistence.addLog(InfoLog('stored'));

      final stored = await repository.getAllLogs();
      expect(stored.single.message, equals('stored'));
    });
  });

  group('registerLogPrinterColor', () {
    test('registers a color printer with the default config', () {
      registerLogPrinterColor();

      final service = GetIt.instance<LogPrinterService>();
      expect(service.logPrinter, isA<LogWithColorPrint>());
      expect(service.configLog.enableLog, isFalse);
    });

    test('honors a custom config', () {
      registerLogPrinterColor(config: const ConfigLog(enableLog: true, onlyClasses: {InfoLog}));

      final config = GetIt.instance<LogPrinterService>().configLog;
      expect(config.enableLog, isTrue);
      expect(config.onlyClasses, equals({InfoLog}));
    });
  });

  group('registerLogPrinterSimple', () {
    test('registers a simple printer with the default config', () {
      registerLogPrinterSimple();

      final service = GetIt.instance<LogPrinterService>();
      expect(service.logPrinter, isA<LogSimplePrint>());
      expect(service.configLog.enableLog, isFalse);
    });
  });
}
