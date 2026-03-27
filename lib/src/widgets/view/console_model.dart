import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/log_printer_service.dart';

class ConsoleModelNotifier extends ChangeNotifier {
  List<LoggerObjectBase> _logs = [];
  final LogPrinterService _logPrinterService;
  ConsoleModelNotifier({required LogPrinterService logPrinterService})
    : _logPrinterService = logPrinterService {
    loadLogs();
    _logPrinterService.cacheRepository.consoleModel = changeList;
  }
  List<LoggerObjectBase> get logs => _logs;

  void changeList(List<LoggerObjectBase> newLogs) {
    _logs = newLogs;
    notifyListeners();
  }

  @override
  void dispose() {
    _logPrinterService.cacheRepository.consoleModel = null;
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
