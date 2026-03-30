import 'package:get_it/get_it.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/console_view/data/datasource/message_log_data_source.dart';
import 'package:log_custom_printer/src/console_view/data/datasource/options/options_console_data_source.dart';
import 'package:log_custom_printer/src/console_view/data/service/message_repository_impl.dart';
import 'package:log_custom_printer/src/console_view/data/service/options_repository_impl.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/i_options_repository.dart';
import 'package:log_custom_printer/src/console_view/domain/repository/message_repository.dart';

final appGetIt = GetIt.instance;

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
}
