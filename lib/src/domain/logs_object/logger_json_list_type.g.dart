// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: document_ignores, unnecessary_null_checks, specify_nonobvious_property_types, cast_nullable_to_non_nullable

part of 'logger_json_list_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$LoggerJsonListTypeToJson(LoggerJsonListType instance) =>
    <String, dynamic>{
      'type': _$EnumLoggerTypeEnumMap[instance.type]!,
      'valueMaxNumberOfEntries': instance.valueMaxNumberOfEntries,
      'loggerJson': instance.loggerEntries.map((e) => e.toJson()).toList(),
    };

const _$EnumLoggerTypeEnumMap = {
  EnumLoggerType.error: 'error',
  EnumLoggerType.debug: 'debug',
  EnumLoggerType.warning: 'warning',
  EnumLoggerType.info: 'info',
};
