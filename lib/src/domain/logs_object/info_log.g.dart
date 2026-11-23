// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: document_ignores, unnecessary_null_checks, specify_nonobvious_property_types, cast_nullable_to_non_nullable

part of 'info_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoLog _$InfoLogFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InfoLog', json, ($checkedConvert) {
      final val = InfoLog($checkedConvert('message', (v) => v as String));
      $checkedConvert('className', (v) => val.className = v as String);
      $checkedConvert(
        'logCreationDate',
        (v) => val.logCreationDate = DateTime.parse(v as String),
      );
      return val;
    });

Map<String, dynamic> _$InfoLogToJson(InfoLog instance) => <String, dynamic>{
  'message': instance.message,
  'className': instance.className,
  'logCreationDate': instance.logCreationDate.toIso8601String(),
};
