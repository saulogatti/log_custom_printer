import 'package:json_annotation/json_annotation.dart';
import 'package:log_custom_printer/src/log_helpers/enum_logger_type.dart';
import 'package:log_custom_printer/src/log_helpers/logger_enum.dart';
import 'package:log_custom_printer/src/logs_object/debug_log.dart';
import 'package:log_custom_printer/src/logs_object/error_log.dart';
import 'package:log_custom_printer/src/logs_object/info_log.dart';
import 'package:log_custom_printer/src/logs_object/logger_object.dart';
import 'package:log_custom_printer/src/logs_object/warning_log.dart';

part 'logger_json_list.g.dart';

/// Uma lista serializável de objetos logger de um tipo específico.
///
/// Esta classe é usada para serializar e desserializar listas de entradas de log,
/// onde cada entrada é uma subclasse de [LoggerObjectBase] (como [ErrorLog],
/// [DebugLog], [WarningLog], ou [InfoLog]). O campo [type] indica o
/// tipo de entradas de log contidas em [loggerEntries].
///
/// Use [fromJson] para criar uma instância a partir de um mapa JSON, e [toJson] para
/// converter a instância de volta para JSON.
///
/// {@category Utilities}
///
/// Campos:
/// - [type]: O tipo de entradas de log na lista (ex: "ErrorLog").
/// - [loggerEntries]: A lista de objetos de entrada de log.
@JsonSerializable(createFactory: false)
class LoggerJsonList {
  static final Map<String, LoggerObjectBase Function(Map<String, dynamic>)> _typeConstructors = {
    "ErrorLog": ErrorLog.fromJson,
    "DebugLog": DebugLog.fromJson,
    "WarningLog": WarningLog.fromJson,
    "InfoLog": InfoLog.fromJson,
  };

  /// O tipo de entradas de log armazenadas nesta lista.
  ///
  /// Este campo identifica qual subclasse de [LoggerObjectBase] está
  /// sendo armazenada (ex: "ErrorLog", "DebugLog", "WarningLog", "InfoLog").
  String type;

  /// A lista de objetos de log do tipo especificado.
  ///
  /// Contém instâncias de [LoggerObjectBase] ou suas subclasses,
  /// organizadas com os logs mais recentes no início da lista.
  // O nome do campo no JSON é "loggerJson" (legado)
  final List<LoggerObjectBase> _loggerEntries = [];

  /// Limite máximo de logs armazenados na lista.
  ///
  /// Quando este limite é excedido, o log mais antigo é removido
  /// para manter o tamanho da lista controlado.
  @JsonKey(includeFromJson: false, includeToJson: false)
  int maxLogEntries = 100;

  /// Cria uma nova instância de [LoggerJsonList] para o [type] especificado.
  ///
  /// Parâmetros:
  /// * [type]: O tipo de entradas de log que esta lista irá conter
  ///
  /// Exemplo:
  /// ```dart
  /// final errorList = LoggerJsonList(type: 'ErrorLog');
  /// final debugList = LoggerJsonList(type: 'DebugLog');
  /// ```
  LoggerJsonList({required this.type, this.maxLogEntries = 100});

  /// Cria uma instância de [LoggerJsonList] a partir de dados JSON.
  ///
  /// Desserializa um mapa JSON em uma instância de [LoggerJsonList],
  /// recriando os objetos de log apropriados com base no tipo especificado.
  /// Suporta os tipos: "ErrorLog", "DebugLog", "WarningLog", e "InfoLog".
  ///
  /// Parâmetros:
  /// * [json]: Mapa JSON contendo os dados serializados
  ///
  /// Retorna:
  /// * [LoggerJsonList]: Nova instância com os logs desserializados
  ///
  /// Lança:
  /// * [AssertionError]: Se um tipo de log desconhecido for encontrado
  ///
  /// Exemplo:
  /// ```dart
  /// final json = {
  ///   'type': 'ErrorLog',
  ///   'loggerJson': [/* lista de logs */]
  /// };
  /// final loggerList = LoggerJsonList.fromJson(json);
  /// ```
  factory LoggerJsonList.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String;
    final LoggerJsonList loggerJsonList = LoggerJsonList(type: type);
    final list = json['loggerJson'] as List;
    for (final element in list) {
      if (element is Map<String, dynamic>) {
        LoggerObjectBase? ob;
        ob = _typeConstructors[type]?.call(element);
        assert(ob != null, "Tipo de logger desconhecido: $type");
        loggerJsonList.addLogger(ob!);
      }
    }
    return loggerJsonList;
  }
@JsonKey(includeFromJson: false, includeToJson: false)
EnumLoggerType? get enumLoggerType => loggerEntries.isNotEmpty ? loggerEntries.first.enumLoggerType : null;
  /// A lista de objetos de log do tipo especificado.
  ///
  /// Contém instâncias de [LoggerObjectBase] ou suas subclasses,
  /// organizadas com os logs mais recentes no início da lista.
  /// O nome do campo no JSON é "loggerJson" (legado), mas internamente é armazenado em [_loggerEntries].
  /// O getter [loggerEntries] é usado para acessar a lista de logs e é anotado com @JsonKey para garantir que seja serializado corretamente. Sempre retorna uma nova lista para evitar modificações externas à lista interna.
  @JsonKey(name: "loggerJson")
  List<LoggerObjectBase> get loggerEntries => List<LoggerObjectBase>.from(_loggerEntries);

  /// A lista de objetos de log do tipo especificado.
  ///
  /// Contém instâncias de [LoggerObjectBase] ou suas subclasses,
  /// organizadas com os logs mais recentes no início da lista.

  /// Adiciona um novo objeto de log à lista.
  ///
  /// Insere o [logger] no início da lista, mantendo os logs mais recentes primeiro.
  /// Se o número de logs exceder [maxLogEntries], remove o log mais antigo
  /// (último da lista) para manter o limite de tamanho.
  ///
  /// Parâmetros:
  /// * [logger]: O objeto de log a ser adicionado à lista
  ///
  /// Exemplo:
  /// ```dart
  /// final loggerList = LoggerJsonList(type: 'ErrorLog');
  /// final errorLog = ErrorLog('Erro ocorreu', StackTrace.current);
  /// loggerList.addLogger(errorLog);
  /// ```
  void addLogger(LoggerObjectBase logger) {
    if (_loggerEntries.length >= maxLogEntries) {
      _loggerEntries.removeLast();
    }
    _loggerEntries.insert(0, logger);
  }

  /// Converte esta instância em um mapa JSON.
  ///
  /// Serializa todos os logs contidos nesta lista em um formato JSON
  /// que pode ser persistido ou transmitido. O mapa resultante pode
  /// ser usado com [fromJson] para recriar a instância.
  ///
  /// Retorna:
  /// * [Map<String, dynamic>]: Representação JSON desta instância
  ///
  /// Exemplo:
  /// ```dart
  /// final loggerList = LoggerJsonList(type: 'ErrorLog');
  /// loggerList.addLogger(errorLog);
  /// final json = loggerList.toJson();
  /// // Resultado: {'type': 'ErrorLog', 'loggerJson': [...]}
  /// ```
  Map<String, dynamic> toJson() => _$LoggerJsonListToJson(this);
}
