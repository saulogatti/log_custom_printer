// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: cast_nullable_to_non_nullable, unnecessary_null_checks, unused_element, unnecessary_lambdas, inference_failure_on_collection_literal

part of 'debug_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebugLog _$DebugLogFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DebugLog', json, ($checkedConvert) {
      final val = DebugLog($checkedConvert('message', (v) => v as String));
      $checkedConvert('className', (v) => val.className = v as String);
      $checkedConvert(
        'logCreationDate',
        (v) => val.logCreationDate = DateTime.parse(v as String),
      );
      return val;
    });

Map<String, dynamic> _$DebugLogToJson(DebugLog instance) => <String, dynamic>{
  'className': instance.className,
  'message': instance.message,
  'logCreationDate': instance.logCreationDate.toIso8601String(),
};
