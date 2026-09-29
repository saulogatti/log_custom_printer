// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: cast_nullable_to_non_nullable, unnecessary_null_checks,     unnecessary_lambdas, inference_failure_on_collection_literal

part of 'logger_json_list_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$LoggerJsonListTypeToJson(LoggerJsonListType instance) =>
    <String, dynamic>{
      'type': _$EnumLoggerTypeEnumMap[instance.type]!,
      'maxLogEntries': instance.maxLogEntries,
      'loggerJson': instance.loggerEntries.map((e) => e.toJson()).toList(),
    };

const _$EnumLoggerTypeEnumMap = {
  EnumLoggerType.error: 'error',
  EnumLoggerType.debug: 'debug',
  EnumLoggerType.warning: 'warning',
  EnumLoggerType.info: 'info',
};
