import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

part 'warning_log.g.dart';

/// Log de aviso (warning) com formatação verde.
///
/// Usado para registrar avisos, alertas ou situações que merecem atenção,
/// mas que não impedem o funcionamento da aplicação. Exibido com cor verde
/// em terminais que suportam códigos ANSI.
///
/// {@category Log Types}
///
/// Exemplo de uso:
/// ```dart
/// final log = WarningLog('Cache está próximo do limite');
/// log.sendLog();
/// ```
///
/// Com mixin:
/// ```dart
/// class MinhaClasse with LoggerClassMixin {
///   void verificarRecursos() {
///     if (memoriaUsada > limiteAviso) {
///       logWarning('Uso de memória acima do esperado');
///     }
///   }
/// }
/// ```
@JsonSerializable()
class WarningLog extends LoggerObjectBase {
  /// Cria um log de aviso.
  ///
  /// [message] é o texto descritivo do aviso.
  /// [typeClass] identifica a classe de origem (opcional).
  WarningLog(super.message, {super.typeClass}) : super();

  /// Cria uma instância a partir de JSON.
  factory WarningLog.fromJson(Map<String, dynamic> json) =>
      _$WarningLogFromJson(json);

  @override
  LoggerAnsiColor getColor() {
    return const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.green);
  }

  @override
  Map<String, dynamic> toJson() => _$WarningLogToJson(this);
}
