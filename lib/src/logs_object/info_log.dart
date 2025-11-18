import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';
import 'package:json_annotation/json_annotation.dart';

part 'info_log.g.dart';

/// Log de informação geral com formatação branca.
///
/// Usado para registrar eventos informativos da aplicação, como operações
/// bem-sucedidas, marcos de execução ou informações de estado. Exibido com
/// cor branca em terminais que suportam códigos ANSI.
///
/// {@category Log Types}
///
/// Exemplo de uso:
/// ```dart
/// final log = InfoLog('Usuário autenticado com sucesso');
/// log.sendLog();
/// ```
///
/// Com mixin:
/// ```dart
/// class MinhaClasse with LoggerClassMixin {
///   void processarDados() {
///     logInfo('Processamento de dados iniciado');
///     // ... lógica de processamento
///     logInfo('Processamento concluído');
///   }
/// }
/// ```
@JsonSerializable()
class InfoLog extends LoggerObjectBase {
  /// Cria um log informativo.
  ///
  /// [message] é o texto descritivo do evento informativo.
  /// [typeClass] identifica a classe de origem (opcional).
  InfoLog(super.message, {super.typeClass}) : super();

  /// Cria uma instância a partir de JSON.
  factory InfoLog.fromJson(Map<String, dynamic> json) =>
      _$InfoLogFromJson(json);

  @override
  LoggerAnsiColor getColor() {
    return const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.white);
  }

  @override
  Map<String, dynamic> toJson() => _$InfoLogToJson(this);
}
