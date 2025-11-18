/// Biblioteca de logging customizada para Dart/Flutter.
///
/// Fornece um sistema completo de logging com:
/// - Hierarquia tipada de logs (Debug, Info, Warning, Error)
/// - Formatação colorida com códigos ANSI
/// - Serialização JSON automática
/// - Padrão Singleton para configuração centralizada
/// - Mixins utilitários para integração fácil
///
/// ## Uso Rápido
///
/// ```dart
/// import 'package:log_custom_printer/log_custom_printer.dart';
///
/// // Configuração inicial
/// final printer = LogCustomPrinterBase.colorPrint();
///
/// // Usando o mixin (recomendado)
/// class MinhaClasse with LoggerClassMixin {
///   void executar() {
///     logDebug('Iniciando processo');
///     logInfo('Processo em andamento');
///     
///     try {
///       // código da aplicação
///     } catch (error, stackTrace) {
///       logError('Erro: $error', stackTrace);
///     }
///   }
/// }
/// ```
///
/// ## Tipos de Log
///
/// - [DebugLog]: Mensagens de depuração (amarelo)
/// - [InfoLog]: Informações gerais (branco)
/// - [WarningLog]: Avisos e alertas (verde)
/// - [ErrorLog]: Erros e exceções (vermelho)
///
/// ## Configuração
///
/// Configure o comportamento dos logs através de [ConfigLog]:
///
/// ```dart
/// final config = ConfigLog(
///   enableLog: true,
///   onlyClasses: {DebugLog, ErrorLog},
/// );
/// ```
///
/// ## Impressoras
///
/// Escolha entre diferentes estratégias de impressão:
/// - [LogSimplePrint]: Saída simples sem cores
/// - [LogWithColorPrint]: Saída com formatação colorida ANSI
///
/// {@category Core}
library;

export 'src/config_log.dart';
export 'src/log_custom_printer_base.dart';
export 'src/log_helpers/log_display_handler.dart';
export 'src/log_helpers/logger_class_mixin.dart';
export 'src/log_printers/log_simple_print.dart';
export 'src/logs_object/debug_log.dart';
export 'src/logs_object/error_log.dart';
export 'src/logs_object/info_log.dart';
export 'src/logs_object/logger_object.dart';
export 'src/logs_object/warning_log.dart';
export 'src/utils/date_time_log_helper.dart';
