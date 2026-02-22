import 'package:flutter/foundation.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/logs_object/error_log.dart';
import 'package:log_custom_printer/src/logs_object/info_log.dart';
import 'package:log_custom_printer/src/logs_object/warning_log.dart';

/// Configuração para controle de logs na biblioteca.
///
/// Esta classe define as regras de habilitação e filtragem dos logs.
/// Por padrão, os logs são habilitados apenas em modo debug ([kDebugMode])
/// e todos os tipos de log são permitidos.
///
/// {@category Configuration}
///
/// Exemplo de uso básico:
/// ```dart
/// final config = ConfigLog(); // Padrões: debug mode, todos os tipos
/// ```
///
/// Exemplo com configuração customizada:
/// ```dart
/// final config = ConfigLog(
///   enableLog: true,
///   onlyClasses: {DebugLog, ErrorLog}, // Apenas debug e error
/// );
/// ```
///
/// Filtrando logs em produção:
/// ```dart
/// // Desabilitar todos os logs (exceto ErrorLog que sempre é processado)
/// final configProd = ConfigLog(enableLog: false);
///
/// // Ou permitir apenas erros e warnings
/// final configProd = ConfigLog(
///   enableLog: true,
///   onlyClasses: {ErrorLog, WarningLog},
/// );
/// ```
class ConfigLog {
  /// Se os logs devem ser enviados para saída.
  ///
  /// Quando `false`, todos os logs são ignorados independentemente
  /// do tipo. Por padrão usa [kDebugMode], significando que logs
  /// são automaticamente desabilitados em builds de produção.
  final bool enableLog;

  /// Conjunto de tipos de log permitidos.
  ///
  /// Apenas objetos de log cujo `runtimeType` esteja neste conjunto
  /// serão processados. Permite filtrar seletivamente tipos de log
  /// (por exemplo, desabilitar apenas [DebugLog] em certas situações).
  ///
  /// Por padrão inclui todos os tipos: [DebugLog], [WarningLog],
  /// [InfoLog].
  /// Por padrão sempre vai permitir [ErrorLog] para garantir que erros críticos
  final Set<Type> onlyClasses;

  /// Se os logs devem ser persistidos em arquivo.
  ///
  /// Quando `true`, além de enviados para a saída configurada, os logs
  /// também podem ser salvos em arquivo conforme a implementação do
  /// [LogPrinterBase] utilizada. Por padrão é `false`, ou seja, os logs
  /// não são gravados em arquivo.
  final bool isSaveLogFile;

  /// Cria uma configuração de log.
  ///
  /// [enableLog]: controla se logs são processados (padrão: [kDebugMode])
  /// [onlyClasses]: tipos de log permitidos (padrão: todos os tipos)
  /// [isSaveLogFile]: se os logs também devem ser salvos em arquivo (padrão: false)
  const ConfigLog({
    this.enableLog = kDebugMode,
    this.onlyClasses = const {DebugLog, WarningLog, InfoLog},
    this.isSaveLogFile = false,
  });
}
