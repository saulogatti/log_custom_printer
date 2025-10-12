import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/utils/date_time_log_helper.dart';
import 'package:log_custom_printer/src/utils/logger_ansi_color.dart';

sealed class LoggerObject {}

abstract class LoggerObjectBase extends LoggerObject {
  late String className;
  @JsonKey(name: "message")
  final String message;
  @JsonKey(name: "creationDateTime")
  DateTime creationDateTime = DateTime.now();
  LoggerObjectBase(
    this.message, {
    DateTime? creationDateTime,
    String? className,
  }) {
    assert(
      message.isNotEmpty && message.trim().isNotEmpty,
      "Message cannot be empty or just whitespace",
    );
    assert(
      className == null || className.trim().isNotEmpty,
      "className cannot be just whitespace",
    );
    this.creationDateTime = creationDateTime ?? DateTime.now();
    this.className = className ?? runtimeType.toString();
  }
  LoggerAnsiColor getColor();
  String getMessage([bool withColor = true]) {
    final messageFormated = "${creationDateTime.logFullDateTime} $message";
    final String messa = withColor
        ? getColor().call(messageFormated)
        : messageFormated;

    return messa;
  }

  void sendLog() {
    //TODO: implementar envio de log
  }
  Map<String, dynamic> toJson();
  @override
  String toString() {
    return getMessage();
  }
}
