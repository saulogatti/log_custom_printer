import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/log_helpers/logger_json_list.dart';

/// Notifica ouvintes sobre mudanças nos dados de log para diferentes [EnumLoggerType]s.
///
/// Esta classe gerencia um mapa de listas de logs, permitindo que widgets escutem
/// atualizações quando os dados de log mudam. Usa [ChangeNotifier] para fornecer
/// gerenciamento de estado para componentes de UI relacionados a logs.
///
/// {@category Utilities}
///
/// Exemplo de uso:
/// ```dart
/// final notifier = LoggerNotifier();
///
/// // Observar mudanças
/// notifier.addListener(() {
///   final errorLogs = notifier.getLogsType(EnumLoggerType.error);
///   print('Logs atualizados: ${errorLogs.length} erros');
/// });
/// ```
class LoggerNotifier {
  final Map<EnumLoggerType, LoggerJsonList?> _loggerJsonList = {};

  /// Atualiza o mapa de logs e notifica os ouvintes.
  ///
  /// [listLog] é o novo mapa de logs a ser usado.
  void changeListLog(Map<EnumLoggerType, LoggerJsonList?> listLog) {
    _loggerJsonList.clear();
    _loggerJsonList.addAll(listLog);
  }
}
// TODO pensar em algo para notificar quando um log for adicionado, sem usar algo do Flutter, apenas dart, para que seja possível usar em qualquer tipo de projeto, não apenas Flutter. Talvez usando Streams ou algo do tipo.