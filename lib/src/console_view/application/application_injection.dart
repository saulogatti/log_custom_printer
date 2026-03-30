import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/src/config_log.dart';
import 'package:log_custom_printer/src/console_view/data/datasource/message_log_data_source.dart';
import 'package:log_custom_printer/src/console_view/data/datasource/options/options_console_data_source.dart';
import 'package:log_custom_printer/src/console_view/data/service/message_repository_impl.dart';
import 'package:log_custom_printer/src/console_view/data/service/options_repository_impl.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/i_options_repository.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';
import 'package:log_custom_printer/src/data/cache/logger_cache_repository_impl.dart';
import 'package:log_custom_printer/src/domain/i_logger_cache_repository.dart';
import 'package:log_custom_printer/src/log_printer_locator.dart';

/// Instância global do container de injeção de dependência.
///
/// Utilizada pelo console visual para resolver [MessageRepository],
/// [IOptionsRepository] e [ILoggerCacheRepository].
final appGetIt = GetIt.instance;

/// Registra as dependências necessárias para o funcionamento do console visual.
///
/// Deve ser chamada no startup da aplicação antes de usar qualquer componente
/// da [ConsoleView]. Registra:
/// - [MessageRepository] via [MessageRepositoryImpl]
/// - [IOptionsRepository] via [OptionsRepositoryImpl]
/// - [ILoggerCacheRepository] via [LoggerCacheRepositoryImpl]
void initAppInjection() {
  appGetIt.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(
      dataSource: MessageLogDataSource(
        loggerCacheRepositoryImpl: registerLogPrinterColor(
          config: const ConfigLog(enableLog: true),
          cacheFilePath: "test/data_logs",
        ),
      ),
    ),
  );
  appGetIt.registerLazySingleton<IOptionsRepository>(
    () => OptionsRepositoryImpl(OptionsConsoleDataSource()),
  );
  appGetIt.registerLazySingleton<ILoggerCacheRepository>(
    () => LoggerCacheRepositoryImpl(
      saveLogFilePath: "test/data_logs",
      fileType: FileType.json,
    ),
  );
}
