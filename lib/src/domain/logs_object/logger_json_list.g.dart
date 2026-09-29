// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage:ignore-file
// ignore_for_file: cast_nullable_to_non_nullable, unnecessary_null_checks,     unnecessary_lambdas, inference_failure_on_collection_literal

part of 'logger_json_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$LoggerJsonListToJson(LoggerJsonList instance) =>
    <String, dynamic>{
      'type': instance.type,
      'loggerJson': instance.loggerEntries.map((e) => e.toJson()).toList(),
    };
