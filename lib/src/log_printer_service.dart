import 'package:log_custom_printer/src/cache/logger_cache_impl.dart';
import 'package:log_custom_printer/src/cache/logger_cache_repository.dart';
import 'package:log_custom_printer/src/log_custom_printer_base.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';

/// Serviço central que coordena o processo de impressão e armazenamento de logs.
///
/// Este serviço atua como uma fachada que centraliza a lógica de verificação
/// de configurações antes de delegar a impressão real para um [LogPrinterBase]
/// e o armazenamento para um [LoggerCacheRepository].
///
/// Centralizar esse processo evita redundância nos objetos de log e facilita
/// a manutenção das regras de filtragem.
///
/// {@category Core}
final class LogPrinterService {
  /// A impressora configurada para formatar e exibir os logs.
  final LogPrinterBase logPrinter;

  /// O repositório responsável pelo cache e persistência dos logs.
  final LoggerCacheRepository _cacheRepository;

  /// Cria uma nova instância do serviço de impressão.
  ///
  /// [logPrinter]: a estratégia de impressão a ser utilizada.
  /// [cacheRepository]: repositório de cache (padrão: [LoggerCacheImpl]).
  LogPrinterService(this.logPrinter, {LoggerCacheRepository? cacheRepository})
    : _cacheRepository = cacheRepository ?? LoggerCacheImpl();

  /// Retorna o repositório de cache associado a este serviço.
  LoggerCacheRepository get cacheRepository => _cacheRepository;

  /// Executa o processo de log para um [LoggerObjectBase].
  ///
  /// Verifica se o log deve ser impresso com base na configuração global
  /// em [logPrinter.configLog]. Se habilitado ou se o log possuir
  /// `alwaysPrint = true`, ele será:
  /// 1. Adicionado ao cache via [_cacheRepository].
  /// 2. Impresso via [logPrinter].
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
