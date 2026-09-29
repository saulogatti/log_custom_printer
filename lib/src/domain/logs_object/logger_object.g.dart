// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: cast_nullable_to_non_nullable, unnecessary_null_checks, unused_element, unnecessary_lambdas, inference_failure_on_collection_literal

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
      'className': instance.className,
      'tagLog': instance.tag,
      'message': instance.message,
      'logCreationDate': instance.logCreationDate.toIso8601String(),
    };
