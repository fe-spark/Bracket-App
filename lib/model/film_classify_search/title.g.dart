// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'title.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Title _$TitleFromJson(Map<String, dynamic> json) => Title(
      id: (json['id'] as num?)?.toInt(),
      pid: (json['pid'] as num?)?.toInt(),
      name: json['name'] as String?,
      show: json['show'] as bool?,
    );

Map<String, dynamic> _$TitleToJson(Title instance) => <String, dynamic>{
      'id': instance.id,
      'pid': instance.pid,
      'name': instance.name,
      'show': instance.show,
    };
