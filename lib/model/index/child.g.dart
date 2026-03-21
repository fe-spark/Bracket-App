// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Child _$ChildFromJson(Map<String, dynamic> json) => Child(
      id: (json['id'] as num?)?.toInt(),
      pid: (json['pid'] as num?)?.toInt(),
      name: json['name'] as String?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => Child.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChildToJson(Child instance) => <String, dynamic>{
      'id': instance.id,
      'pid': instance.pid,
      'name': instance.name,
      'children': instance.children,
    };
