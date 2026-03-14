import 'package:flutter/foundation.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/log_printer_service.dart';

class ConsoleModel {
  final ValueNotifier<List<LoggerObjectBase>> _logs = ValueNotifier([]);
  final LogPrinterService _logPrinterService;
  ConsoleModel({required LogPrinterService logPrinterService}) : _logPrinterService = logPrinterService {
    loadLogs();
    _logPrinterService.consoleModel = read;
  }
  ValueListenable<List<LoggerObjectBase>> get logs => _logs;

  Future<void> loadLogs() async {
    _logs.value = await _logPrinterService.cacheRepository.getAllLogs();
  }

  void read() {
    loadLogs();
  }

  void clearLogs() {}
}
