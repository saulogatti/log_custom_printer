// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_json_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$LoggerJsonListToJson(LoggerJsonList instance) =>
    <String, dynamic>{
      'type': instance.type,
<<<<<<< HEAD
      'loggerJson': instance.loggerEntries.map((e) => e.toJson()).toList(),
=======
      'loggerJson': instance.loggerJson.map((e) => e.toJson()).toList(),
      'maxLogEntries': instance.maxLogEntries,
>>>>>>> origin/log_doc
    };
