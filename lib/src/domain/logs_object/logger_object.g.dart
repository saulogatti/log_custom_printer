// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: document_ignores, unnecessary_null_checks, specify_nonobvious_property_types, cast_nullable_to_non_nullable

part of 'logger_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoggerObjectBase _$LoggerObjectBaseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoggerObjectBase', json, ($checkedConvert) {
      final val = LoggerObjectBase(
        $checkedConvert('message', (v) => v as String),
        tag: $checkedConvert('tagLog', (v) => v as String?),
      );
      $checkedConvert('className', (v) => val.className = v as String);
      $checkedConvert(
        'logCreationDate',
        (v) => val.logCreationDate = DateTime.parse(v as String),
      );
      return val;
    }, fieldKeyMap: const {'tag': 'tagLog'});

Map<String, dynamic> _$LoggerObjectBaseToJson(LoggerObjectBase instance) =>
    <String, dynamic>{
      'message': instance.message,
      'className': instance.className,
      'tagLog': instance.tag,
      'logCreationDate': instance.logCreationDate.toIso8601String(),
    };
