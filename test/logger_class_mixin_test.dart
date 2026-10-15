import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:test/test.dart';

void main() {
  late _RecordingPrinter printer;

  setUp(() {
    printer = _RecordingPrinter();
    registerLogPrinter(printer, config: const ConfigLog(enableLog: true, onlyClasses: {}));
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('LoggerClassMixin', () {
    test('each helper emits the matching log type', () {
      final service = _Service();

      service.logDebug('d');
      service.logInfo('i');
      service.logWarning('w');
      service.logError('e', StackTrace.current);

      expect(printer.printed[0], isA<DebugLog>());
      expect(printer.printed[1], isA<InfoLog>());
      expect(printer.printed[2], isA<WarningLog>());
      expect(printer.printed[3], isA<ErrorLog>());
      expect(printer.printed.map((log) => log.message), equals(['d', 'i', 'w', 'e']));
    });

    test('logError keeps the given stack trace', () {
      final stack = StackTrace.fromString('#0 main (app.dart:1:1)');

      _Service().logError('e', stack);

      expect((printer.printed.single as ErrorLog).stackTrace, same(stack));
    });

    test('uses the host runtime type as className', () {
      _Service().logInfo('i');

      expect(printer.printed.single.className, equals('_Service'));
    });

    test('a custom logClassType overrides the class name', () {
      _CustomSource().logInfo('i');

      expect(printer.printed.single.className, equals('_Service'));
    });

    test('logs from the mixin are stored in the cache', () async {
      final persistence = GetIt.instance<LogPrinterService>().cacheRepository;

      _Service().logWarning('stored');
      await pumpEventQueue();

      final warnings = await persistence.getLogsByType(EnumLoggerType.warning);
      expect(warnings.single.className, equals('_Service'));
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

class _Service with LoggerClassMixin;

class _CustomSource with LoggerClassMixin {
  @override
  Type get logClassType => _Service;
}
