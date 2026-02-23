import 'package:log_custom_printer/src/cache/logger_cache_impl.dart';
import 'package:log_custom_printer/src/cache/logger_cache_repository.dart';
import 'package:log_custom_printer/src/log_custom_printer_base.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

final class LogPrinterService {
  final LogPrinterBase logPrinter;
  final LoggerCacheRepository _cacheRepository;
  LogPrinterService(this.logPrinter, [LoggerCacheRepository? cacheRepository])
    : _cacheRepository = cacheRepository ?? LoggerCacheImpl();
  LoggerCacheRepository get cacheRepository => _cacheRepository;
  // Centralizei todo o processo de impressão do log aqui para evitar que cada LoggerObjectBase precise resolver o LogPrinterBase e delegar a impressão. Assim, o LoggerObjectBase só precisa chamar logPrinterService.executePrint(this) e toda a lógica de verificação de configuração e formatação fica centralizada aqui.
  void executePrint(LoggerObjectBase log) {
    if (logPrinter.configLog.enableLog &&
        (logPrinter.configLog.onlyClasses.isEmpty ||
            logPrinter.configLog.onlyClasses.contains(log.runtimeType))) {
      // O log pode ser impresso, então adicionamos ao cache e imprimimos
      _cacheRepository.addLog(log);
      logPrinter.printLog(log);
    } else if (log.alwaysPrint) {
      // O log não pode ser impresso normalmente, mas tem alwaysPrint, então imprimimos mesmo assim
      _cacheRepository.addLog(log);
      logPrinter.printLog(log);
    }
  }
}
