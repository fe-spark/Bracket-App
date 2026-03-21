// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListData _$ListDataFromJson(Map<String, dynamic> json) => ListData(
      id: json['id'] as String?,
      name: json['name'] as String?,
      linkList: (json['linkList'] as List<dynamic>?)
          ?.map((e) => PlayItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListDataToJson(ListData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'linkList': instance.linkList,
    };
