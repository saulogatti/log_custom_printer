import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/log_printer_service.dart';

final getIt = GetIt.instance;

class LogConsoleNotifier extends ChangeNotifier {
  List<LoggerObjectBase> _logs = [];
  final LogPrinterService _logPrinterService;
  factory LogConsoleNotifier({required LogPrinterService logPrinterService}) {
    if (!getIt.isRegistered<LogConsoleNotifier>()) {
      final instance = LogConsoleNotifier._(
        logPrinterService: logPrinterService,
      );
      getIt.registerSingleton<LogConsoleNotifier>(instance);
    }
    return getIt<LogConsoleNotifier>();
  }
  LogConsoleNotifier._({required LogPrinterService logPrinterService})
    : _logPrinterService = logPrinterService {
    loadLogs();
    _logPrinterService.cacheRepository.consoleModel = changeList;
  }
  UnmodifiableListView<LoggerObjectBase> get logs =>
      UnmodifiableListView(_logs);
  void changeList(List<LoggerObjectBase> newLogs) {
    _logs = newLogs;
    notifyListeners();
  }

  @override
  void dispose() {
    _logPrinterService.cacheRepository.consoleModel = null;
    print("Disposing ConsoleModelNotifier with hashCode: $hashCode");
    super.dispose();
  }

  Future<void> loadLogs() async {
    _logs = await _logPrinterService.cacheRepository.getAllLogs();
    notifyListeners();
  }

  void read() {
    loadLogs();
  }
}
