// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: cast_nullable_to_non_nullable, unnecessary_null_checks,     unnecessary_lambdas, inference_failure_on_collection_literal

part of 'warning_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarningLog _$WarningLogFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WarningLog', json, ($checkedConvert) {
      final val = WarningLog($checkedConvert('message', (v) => v as String));
      $checkedConvert('className', (v) => val.className = v as String);
      $checkedConvert(
        'logCreationDate',
        (v) => val.logCreationDate = DateTime.parse(v as String),
      );
      return val;
    });

Map<String, dynamic> _$WarningLogToJson(WarningLog instance) =>
    <String, dynamic>{
      'message': instance.message,
      'className': instance.className,
      'logCreationDate': instance.logCreationDate.toIso8601String(),
    };
