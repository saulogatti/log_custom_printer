// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: cast_nullable_to_non_nullable, unnecessary_null_checks,     unnecessary_lambdas, inference_failure_on_collection_literal

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
      );
      $checkedConvert('className', (v) => val.className = v as String);
      $checkedConvert(
        'logCreationDate',
        (v) => val.logCreationDate = DateTime.parse(v as String),
      );
      return val;
    });

Map<String, dynamic> _$ErrorLogToJson(ErrorLog instance) => <String, dynamic>{
  'className': instance.className,
  'message': instance.message,
  'logCreationDate': instance.logCreationDate.toIso8601String(),
  'stackTrace': const StackTraceConverter().toJson(instance.stackTrace),
};
