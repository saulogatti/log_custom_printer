import 'package:log_custom_printer/src/domain/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/error_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/info_log.dart';
import 'package:log_custom_printer/src/domain/logs_object/warning_log.dart';

/// Configuração para controle de logs na biblioteca.
///
/// Esta classe define as regras de habilitação e filtragem dos logs.
/// Por padrão, os logs estão desabilitados ([enableLog] `false`) e [onlyClasses]
/// inclui [DebugLog], [WarningLog] e [InfoLog] (veja também o comportamento de
/// [ErrorLog] em [onlyClasses] abaixo).
///
/// {@category Configuration}
///
/// Exemplo de uso básico:
/// ```dart
/// final config = ConfigLog(); // Padrões: logs desabilitados; onlyClasses padrão
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
  /// Cria uma configuração de log.
  ///
  /// [enableLog]: controla se logs são processados (padrão: `false`).
  /// [onlyClasses]: tipos de log permitidos (padrão: [DebugLog], [WarningLog], [InfoLog]).
  const ConfigLog({
    this.enableLog = false,
    this.onlyClasses = const {DebugLog, WarningLog, InfoLog},
  });

  /// Se os logs devem ser enviados para saída.
  ///
  /// Quando `false`, todos os logs são ignorados independentemente
  /// do tipo (exceto aqueles com `alwaysPrint` como `ErrorLog`).
  /// Por padrão é `false`.
  final bool enableLog;

  /// Conjunto de tipos de log permitidos.
  ///
  /// Apenas objetos de log cujo `runtimeType` esteja neste conjunto
  /// serão processados. Permite filtrar seletivamente tipos de log
  /// (por exemplo, desabilitar apenas [DebugLog] em certas situações).
  ///
  /// Por padrão inclui [DebugLog], [WarningLog] e [InfoLog] (não inclui
  /// [ErrorLog] neste conjunto). [ErrorLog] é na mesma processado quando
  /// [enableLog] ou `alwaysPrint` aplicável em [LogPrinterService] o permitirem,
  /// garantindo que erros críticos não fiquem só dependentes deste filtro.
  final Set<Type> onlyClasses;
}
