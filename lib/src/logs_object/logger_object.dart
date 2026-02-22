import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/log_custom_printer.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

/// Marca base para objetos de log.
///
/// Usado como tipo selado para distinguir objetos que representam logs
/// dentro do pacote. Atualmente não tem membros — existe para permitir
/// uma hierarquia de tipos clara para os diferentes logs (debug, info,
/// warning, error).
///
/// {@category Core}
sealed class LoggerObject {}

/// Contrato base para objetos de log que podem ser impressos/serializados.
///
/// Implementações concretas devem fornecer a cor do log via [getColor]
/// e a representação JSON via [toJson]. O construtor já valida a mensagem
/// e inicializa campos auxiliares como [logCreationDate] e [className].
///
/// {@category Core}
abstract class LoggerObjectBase extends LoggerObject {
  /// Nome da classe/origem que emitiu o log.
  ///
  /// Inicializado no construtor a partir de `typeClass` (quando fornecido)
  /// ou do `runtimeType` da instância.
  late String className;

  /// Mensagem principal do log.
  ///
  /// É anotado com `@JsonKey(name: 'message')` para manter o campo com
  /// o nome esperado na serialização.
  @JsonKey(name: "message")
  final String message;

  /// Data/hora em que o log foi criado.
  ///
  /// Quando não é informado via [createdAt], o construtor define para
  /// `DateTime.now()`; caso contrário usa o valor fornecido.
  @JsonKey(name: "logCreationDate")
  DateTime logCreationDate = DateTime.now();

  /// Cria um objeto de log.
  ///
  /// [message] deve ser não vazio — caso contrário uma `assert` é lançada
  /// em modo de desenvolvimento. [createdAt] permite controlar a data do
  /// log (útil em testes); quando omitido, o objeto NÃO enviará o log
  /// automaticamente. Use o construtor nomeado `LoggerObjectBase.send`
  /// para criar e enviar em uma única chamada.
  LoggerObjectBase(this.message, {DateTime? createdAt, Type? typeClass}) {
    assert(
      message.isNotEmpty && message.trim().isNotEmpty,
      "Mensagem não pode ser vazia ou apenas espaços em branco",
    );

    logCreationDate = createdAt ?? DateTime.now();
    className = typeClass?.toString() ?? runtimeType.toString();
  }

  /// Cabeçalho formatado do log (nome da classe/origem).
  String get _logHeader =>
      runtimeType.toString().toUpperCase() +
      (className.isNotEmpty ? " - $className".toUpperCase() : "");

  /// Retorna a cor/estilo ANSI que será aplicada à mensagem quando
  /// [getMessage] for chamada com `withColor = true`.
  LoggerAnsiColor getColor();

  /// Formata a mensagem incluindo timestamp e aplicando cor opcional.
  ///
  /// [withColor]: quando `true` aplica a transformação de cor retornada
  /// por [getColor]; quando `false` retorna texto sem códigos ANSI.
  String getMessage([bool withColor = true]) {
    final messageFormated = "${logCreationDate.logFullDateTime} $message";
    final String messa = withColor
        ? getColor().call(messageFormated)
        : messageFormated;

    return messa;
  }

  /// Retorna o cabeçalho do log (nome da classe/origem) formatado.
  ///
  /// [withColor]: quando `true` aplica a transformação de cor retornada
  /// por [getColor]; quando `false` retorna texto sem códigos ANSI.
  String getStartLog([bool withColor = true]) {
    if (withColor) {
      return getColor().call(_logHeader);
    }
    return _logHeader;
  }

  /// Envia (imprime) o log usando o `LogPrinterBase` configurado no
  /// pacote.
  /// Checa se o log está habilitado via configuração antes de imprimir.
  /// Se o log não pode ser impresso e não é um ErrorLog, retorna sem fazer nada.
  ///
  /// Implementação padrão obtém o `LogPrinterBase` a partir de
  /// `LogCustomPrinterBase().getLogPrinterBase()` e delega a impressão.
  @mustCallSuper
  void sendLog() {
    final logPrinterBase = LogCustomPrinterBase().getLogPrinterBase();
    final bool canPrintLog =
        logPrinterBase.configLog.enableLog &&
        (logPrinterBase.configLog.onlyClasses.isEmpty ||
            logPrinterBase.configLog.onlyClasses.contains(runtimeType));
    // Se o log não pode ser impresso e não é um ErrorLog, retorna sem fazer nada
    if (!canPrintLog && this is! ErrorLog) {
      return;
    }

    logPrinterBase.printLog(this);
  }

  /// Serializa o objeto de log para JSON.
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return getMessage();
  }
}
