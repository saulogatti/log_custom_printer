// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorLog _$ErrorLogFromJson(Map<String, dynamic> json) =>
    ErrorLog(
        json['message'] as String,
        const StackTraceConverter().fromJson(json['stackTrace'] as String),
      )
      ..className = json['className'] as String
      ..creationDateTime = DateTime.parse(json['creationDateTime'] as String);

Map<String, dynamic> _$ErrorLogToJson(ErrorLog instance) => <String, dynamic>{
  'className': instance.className,
  'message': instance.message,
  'creationDateTime': instance.creationDateTime.toIso8601String(),
  'stackTrace': const StackTraceConverter().toJson(instance.stackTrace),
};
