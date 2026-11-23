// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: document_ignores, unnecessary_null_checks, specify_nonobvious_property_types, cast_nullable_to_non_nullable

part of 'error_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorLog _$ErrorLogFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ErrorLog', json, ($checkedConvert) {
      final val = ErrorLog(
        $checkedConvert('message', (v) => v as String),
        $checkedConvert(
          'stackTrace',
          (v) => const StackTraceConverter().fromJson(v as String),
        ),
        object: $checkedConvert(
          'object',
          (v) => _$JsonConverterFromJson<String, Object>(
            v,
            const ObjectConverter().fromJson,
          ),
        ),
      );
      $checkedConvert('className', (v) => val.className = v as String);
      $checkedConvert(
        'logCreationDate',
        (v) => val.logCreationDate = DateTime.parse(v as String),
      );
      return val;
    });

Map<String, dynamic> _$ErrorLogToJson(ErrorLog instance) => <String, dynamic>{
  'message': instance.message,
  'className': instance.className,
  'logCreationDate': instance.logCreationDate.toIso8601String(),
  'stackTrace': const StackTraceConverter().toJson(instance.stackTrace),
  'object': const ObjectConverter().toJson(instance.object),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);
