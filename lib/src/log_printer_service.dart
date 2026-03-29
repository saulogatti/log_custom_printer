import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/data/cache/logger_persistence_service.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';

/// Serviço central que coordena o processo de impressão e armazenamento de logs.
///
/// Este serviço atua como uma fachada que centraliza a lógica de verificação
/// de configurações antes de delegar a impressão real para um [LogPrinterBase]
/// e o armazenamento para um [LoggerPersistenceService].
///
/// Centralizar esse processo evita redundância nos objetos de log e facilita
/// a manutenção das regras de filtragem.
///
/// {@category Core}
final class LogPrinterService {
  /// A impressora configurada para formatar e exibir os logs.
  final LogPrinterBase logPrinter;
  final ConfigLog configLog;

  /// O repositório responsável pelo cache e persistência dos logs.
  final LoggerPersistenceService _loggerPersistenceService;

  /// Cria uma nova instância do serviço de impressão.
  ///
  /// [logPrinter]: a estratégia de impressão a ser utilizada.
  /// [cacheRepository]: repositório de cache (padrão: [LoggerCacheRepositoryImpl]).
  LogPrinterService(
    this.logPrinter, {
    ILoggerCacheRepository? cacheRepository,
    required this.configLog,
  }) : _loggerPersistenceService = LoggerPersistenceService(
         cacheRepository: cacheRepository,
       );

  /// Retorna o repositório de cache associado a este serviço.
  LoggerPersistenceService get cacheRepository => _loggerPersistenceService;

  /// Executa o processo de log para um [LoggerObjectBase].
  ///
  /// Verifica se o log deve ser impresso com base na configuração global
  /// em [configLog]. Se habilitado ou se o log possuir
  /// `alwaysPrint = true`, ele será:
  /// 1. Adicionado ao cache via [_loggerPersistenceService].
  /// 2. Impresso via [logPrinter].
  void executePrint(LoggerObjectBase log) {
    if (configLog.enableLog &&
        (configLog.onlyClasses.isEmpty ||
            configLog.onlyClasses.contains(log.runtimeType))) {
      // O log pode ser impresso, então adicionamos ao cache e imprimimos
      _loggerPersistenceService.addLog(log);
      logPrinter.printLog(log);
    } else if (log.alwaysPrint) {
      // O log não pode ser impresso normalmente, mas tem alwaysPrint, então imprimimos mesmo assim
      _loggerPersistenceService.addLog(log);
      logPrinter.printLog(log);
    }
  }
}
