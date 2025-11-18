import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

part 'debug_log.g.dart';

/// Log de depuração (debug) com formatação amarela.
///
/// Usado para mensagens de desenvolvimento e depuração. Quando habilitado,
/// este tipo de log é exibido com cor amarela nos terminais que suportam
/// códigos ANSI.
///
/// {@category Log Types}
///
/// Exemplo de uso:
/// ```dart
/// final log = DebugLog('Iniciando processo de autenticação');
/// log.sendLog();
/// ```
///
/// Com mixin:
/// ```dart
/// class MinhaClasse with LoggerClassMixin {
///   void meuMetodo() {
///     logDebug('Método executado com sucesso');
///   }
/// }
/// ```
///
/// Serialização JSON:
/// ```dart
/// final log = DebugLog('Mensagem de debug');
/// final json = log.toJson();
/// final logRecuperado = DebugLog.fromJson(json);
/// ```
@JsonSerializable()
class DebugLog extends LoggerObjectBase {
  /// Cria um log de depuração.
  ///
  /// [message] é o texto descritivo do evento de debug.
  /// [typeClass] identifica a classe de origem (opcional).
  DebugLog(super.message, {super.typeClass});

  /// Cria uma instância a partir de JSON.
  factory DebugLog.fromJson(Map<String, dynamic> json) =>
      _$DebugLogFromJson(json);

  @override
  LoggerAnsiColor getColor() {
    return const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.yellow);
  }

  @override
  Map<String, dynamic> toJson() => _$DebugLogToJson(this);
}
