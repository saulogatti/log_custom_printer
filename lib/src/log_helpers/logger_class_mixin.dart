import 'package:flutter/material.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/logs_object/error_log.dart';
import 'package:log_custom_printer/src/logs_object/info_log.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/logs_object/warning_log.dart';

/// Mixin que fornece métodos utilitários de log para uma classe.
///
/// As implementações criam objetos de log específicos (`DebugLog`,
/// `ErrorLog`, `InfoLog`, `WarningLog`) e os encaminham para
/// `_sendLog` para processamento. O campo `typeClass` dos objetos de log
/// é preenchido com o `runtimeType` da classe que usa este mixin via
/// [logClassType].
///
/// Use este mixin em classes que queiram facilitar o registro de mensagens
/// sem se preocupar com a criação manual dos objetos de log.
mixin LoggerClassMixin {
  /// Tipo (classe) que está emitindo o log.
  ///
  /// Retorna `runtimeType` da instância que usa este mixin. É usado como
  /// `typeClass` nos objetos de log para identificar a origem da mensagem.
  Type get logClassType => runtimeType;

  /// Registra uma mensagem de debug.
  ///
  /// [message]: texto descritivo do evento de debug. O `typeClass` do
  /// `DebugLog` será preenchido com [logClassType].
  void logDebug(String message) {
    final log = DebugLog(message, typeClass: logClassType);
    _sendLog(log);
  }

  /// Registra um erro com `stackTrace` associado.
  ///
  /// [message]: descrição do erro.
  /// [stackTrace]: pilha de execução referente ao erro.
  void logError(String message, StackTrace stackTrace) {
    final log = ErrorLog(message, stackTrace, typeClass: logClassType);
    _sendLog(log);
  }

  /// Registra uma informação (info).
  ///
  /// [message]: texto informativo.
  void logInfo(String message) {
    final log = InfoLog(message, typeClass: logClassType);
    _sendLog(log);
  }

  /// Registra um aviso (warning).
  ///
  /// [message]: texto de aviso.
  void logWarning(String message) {
    final log = WarningLog(message, typeClass: logClassType);
    _sendLog(log);
  }

  /// Envia o objeto de log para o seu mecanismo de saída.
  ///
  /// Implementação atual chama `log.sendLog()`. Mantido privado pois é a
  /// função de encaminhamento interno do mixin.
  void _sendLog(LoggerObjectBase log) {
    log.sendLog();
  }
}

extension LoggerDispose on State {
  void debugDispose() {
    final logDebug = DebugLog("Disposing ${runtimeType.toString()}", typeClass: runtimeType);
    logDebug.sendLog();
  }
}
