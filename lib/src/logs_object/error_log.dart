import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';
import 'package:log_custom_printer/src/utils/stack_trace_extensions.dart';

part 'error_log.g.dart';

/// Log de erro com formatação vermelha e stack trace.
///
/// Usado para registrar erros e exceções da aplicação. Este tipo de log
/// inclui informações de stack trace para facilitar a depuração. Sempre
/// é processado independentemente da configuração [ConfigLog.enableLog],
/// garantindo que erros críticos sejam sempre registrados. Exibido com
/// cor vermelha em terminais que suportam códigos ANSI.
///
/// {@category Log Types}
///
/// Exemplo de uso:
/// ```dart
/// try {
///   // código que pode lançar exceção
/// } catch (error, stackTrace) {
///   final log = ErrorLog('Falha ao processar dados: $error', stackTrace);
///   log.sendLog();
/// }
/// ```
///
/// Com mixin:
/// ```dart
/// class MinhaClasse with LoggerClassMixin {
///   void metodoComTratamento() {
///     try {
///       // operação arriscada
///     } catch (error, stackTrace) {
///       logError('Erro na operação: $error', stackTrace);
///     }
///   }
/// }
/// ```
@JsonSerializable()
class ErrorLog extends LoggerObjectBase {
  /// Stack trace associado ao erro.
  ///
  /// Captura a pilha de execução no momento do erro para facilitar
  /// a depuração e identificação da origem do problema.
  @StackTraceConverter()
  final StackTrace stackTrace;

  /// Cria um log de erro.
  ///
  /// [message] é a descrição do erro.
  /// [stackTrace] é a pilha de execução capturada.
  /// [typeClass] identifica a classe de origem (opcional).
  ErrorLog(super.message, this.stackTrace, {super.typeClass}) : super();

  /// Cria uma instância a partir de JSON.
  factory ErrorLog.fromJson(Map<String, dynamic> json) =>
      _$ErrorLogFromJson(json);

  @override
  LoggerAnsiColor getColor() {
    return const LoggerAnsiColor(enumAnsiColors: EnumAnsiColors.red);
  }

  @override
  String getMessage([bool withColor = true]) {
    final str = stackTrace.stackInMap(100);
    final color = getColor();
    final strMessage = super
        .getMessage(withColor)
        .split("\n")
        .map((e) => withColor ? color.call(e) : e)
        .toList();

    for (final element in str.keys) {
      if (withColor) {
        strMessage.add(color.call("$element = ${str[element]}"));
      } else {
        strMessage.add("$element = ${str[element]}");
      }
    }

    return strMessage.join("\n\t");
  }

  @override
  Map<String, dynamic> toJson() => _$ErrorLogToJson(this);
}

class StackTraceConverter implements JsonConverter<StackTrace, String> {
  const StackTraceConverter();

  @override
  StackTrace fromJson(String json) {
    // Implement your deserialization logic here
    return StackTrace.fromString(json);
  }

  @override
  String toJson(StackTrace object) {
    // Implemente sua lógica de serialização aqui
    return object.toString();
  }
}
