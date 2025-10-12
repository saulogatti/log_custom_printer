// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebugLog _$DebugLogFromJson(Map<String, dynamic> json) =>
    DebugLog(json['message'] as String)
      ..className = json['className'] as String
      ..creationDateTime = DateTime.parse(json['creationDateTime'] as String);

Map<String, dynamic> _$DebugLogToJson(DebugLog instance) => <String, dynamic>{
  'className': instance.className,
  'message': instance.message,
  'creationDateTime': instance.creationDateTime.toIso8601String(),
};
