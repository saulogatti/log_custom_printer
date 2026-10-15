import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigLog', () {
    test('defaults to disabled with Debug, Warning and Info allowed', () {
      const config = ConfigLog();

      expect(config.enableLog, isFalse);
      expect(config.onlyClasses, equals({DebugLog, WarningLog, InfoLog}));
      expect(config.onlyClasses.contains(ErrorLog), isFalse);
    });
  });

  group('LogPrinterService.executePrint', () {
    late _RecordingPrinter printer;

    setUp(() {
      printer = _RecordingPrinter();
    });

    LogPrinterService buildService(ConfigLog config) {
      return LogPrinterService(
        printer,
        configLog: config,
        cacheRepository: LoggerCacheRepositoryImpl(maxLogEntries: 100),
      );
    }

    test('prints and caches allowed logs when enabled', () async {
      final service = buildService(const ConfigLog(enableLog: true));

      service.executePrint(DebugLog('debug'));
      service.executePrint(InfoLog('info'));
      service.executePrint(WarningLog('warning'));
      await pumpEventQueue();

      expect(printer.printed.map((log) => log.message), equals(['debug', 'info', 'warning']));
      final cached = await service.cacheRepository.getAllLogs();
      expect(cached, hasLength(3));
    });

    test('ignores non-error logs when disabled', () async {
      final service = buildService(const ConfigLog());

      service.executePrint(DebugLog('debug'));
      service.executePrint(InfoLog('info'));
      service.executePrint(WarningLog('warning'));
      await pumpEventQueue();

      expect(printer.printed, isEmpty);
      expect(await service.cacheRepository.getAllLogs(), isEmpty);
    });

    test('prints and caches ErrorLog even when disabled', () async {
      final service = buildService(const ConfigLog());

      service.executePrint(ErrorLog('boom', StackTrace.empty));
      await pumpEventQueue();

      expect(printer.printed.single, isA<ErrorLog>());
      final cached = await service.cacheRepository.getLogsByType(EnumLoggerType.error);
      expect(cached.single.message, equals('boom'));
    });

    test('accepts every type when onlyClasses is empty', () async {
      final service = buildService(const ConfigLog(enableLog: true, onlyClasses: {}));

      service.executePrint(DebugLog('debug'));
      service.executePrint(InfoLog('info'));
      service.executePrint(WarningLog('warning'));
      service.executePrint(ErrorLog('error', StackTrace.empty));
      await pumpEventQueue();

      expect(printer.printed, hasLength(4));
    });

    test('drops types not listed in onlyClasses', () async {
      final service = buildService(const ConfigLog(enableLog: true, onlyClasses: {WarningLog}));

      service.executePrint(DebugLog('debug'));
      service.executePrint(InfoLog('info'));
      service.executePrint(WarningLog('warning'));
      await pumpEventQueue();

      expect(printer.printed.single, isA<WarningLog>());
      expect(await service.cacheRepository.getAllLogs(), hasLength(1));
    });

    test('processes ErrorLog exactly once when it is also in onlyClasses', () async {
      final service = buildService(const ConfigLog(enableLog: true, onlyClasses: {ErrorLog}));

      service.executePrint(ErrorLog('boom', StackTrace.empty));
      await pumpEventQueue();

      expect(printer.printed, hasLength(1));
      expect(await service.cacheRepository.getAllLogs(), hasLength(1));
    });

    test('uses an in-memory cache when no repository is given', () async {
      final service = LogPrinterService(printer, configLog: const ConfigLog(enableLog: true));

      service.executePrint(InfoLog('info'));
      await pumpEventQueue();

      expect(await service.cacheRepository.getAllLogs(), hasLength(1));
    });
  });

  group('sendLog through DI', () {
    late _RecordingPrinter printer;

    setUp(() {
      printer = _RecordingPrinter();
    });

    tearDown(() async {
      await GetIt.instance.reset();
    });

    test('routes logs to the registered printer and cache', () async {
      final persistence = registerLogPrinter(printer, config: const ConfigLog(enableLog: true));

      InfoLog('hello').sendLog();
      await pumpEventQueue();

      expect(printer.printed.single.message, equals('hello'));
      final cached = await persistence.getLogsByType(EnumLoggerType.info);
      expect(cached.single.message, equals('hello'));
    });
  });
}

class _RecordingPrinter extends LogPrinterBase {
  final List<LoggerObjectBase> printed = [];

  @override
  void printLog(LoggerObjectBase log) {
    printed.add(log);
  }
}
