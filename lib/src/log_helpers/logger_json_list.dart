import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/log_helpers/logger_enum.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/logs_object/error_log.dart';
import 'package:log_custom_printer/src/logs_object/info_log.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/logs_object/warning_log.dart';
import 'dart:developer' as dev;

part 'logger_json_list.g.dart';

/// Uma lista serializável de objetos logger de um tipo específico.
///
/// Esta classe é usada para gerenciar, serializar e desserializar listas de entradas de log,
/// onde cada entrada é uma subclasse de [LoggerObjectBase]. O campo [type] indica o
/// nome da classe das entradas de log contidas (ex: "ErrorLog").
///
/// Mantém um limite máximo de entradas ([maxLogEntries]) descartando as mais antigas.
///
/// {@category Utilities}
@JsonSerializable(createFactory: false)
class LoggerJsonList {
  /// Mapa de construtores para desserialização baseada no nome do tipo.
  static final Map<String, LoggerObjectBase Function(Map<String, dynamic>)> _typeConstructors = {
    "ErrorLog": ErrorLog.fromJson,
    "DebugLog": DebugLog.fromJson,
    "WarningLog": WarningLog.fromJson,
    "InfoLog": InfoLog.fromJson,
  };

  /// O tipo de entradas de log armazenadas nesta lista (nome da classe).
  String type;

  /// Lista interna de entradas de log.
  final List<LoggerObjectBase> _loggerEntries = [];

  /// Limite máximo de logs armazenados nesta lista.
  @JsonKey(includeFromJson: false, includeToJson: false)
  int maxLogEntries = 100;

  /// Cria uma nova lista para o [type] especificado.
  LoggerJsonList({required this.type, this.maxLogEntries = 100});

  /// Cria uma instância a partir de dados JSON.
  ///
  /// Identifica o tipo de log e usa o construtor apropriado para recriar os objetos.
  factory LoggerJsonList.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;
    final LoggerJsonList loggerJsonList = LoggerJsonList(type: type);
    final list = json['loggerJson'] as List;
    for (final element in list) {
      if (element is Map<String, dynamic>) {
        final constructor = _typeConstructors[type];
        if (constructor != null) {
          final ob = constructor(element);
          loggerJsonList.addLogger(ob);
        } else {
          devLog('Tipo de logger desconhecido: $type');
        }
      }
    }
    return loggerJsonList;
  }

  /// Retorna o [EnumLoggerType] correspondente ao tipo de logs nesta lista.
  @JsonKey(includeFromJson: false, includeToJson: false)
  EnumLoggerType? get enumLoggerType => _loggerEntries.isNotEmpty ? _loggerEntries.first.enumLoggerType : null;

  /// A lista de objetos de log, organizada do mais recente para o mais antigo.
  ///
  /// O nome do campo no JSON é `loggerJson` por compatibilidade.
  @JsonKey(name: "loggerJson")
  List<LoggerObjectBase> get loggerEntries => List<LoggerObjectBase>.from(_loggerEntries);

  /// Adiciona um novo objeto de log à lista.
  ///
  /// Insere no início (índice 0). Se [maxLogEntries] for atingido, remove o último.
  void addLogger(LoggerObjectBase logger) {
    if (_loggerEntries.length >= maxLogEntries) {
      _loggerEntries.removeLast();
    }
    _loggerEntries.insert(0, logger);
  }

  /// Converte a instância em um mapa JSON.
  Map<String, dynamic> toJson() => _$LoggerJsonListToJson(this);
}

/// Atalho interno para log de desenvolvedor para evitar loops.
void devLog(String message) {
  dev.log(message, name: 'log_custom_printer');
}
