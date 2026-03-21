// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Search _$SearchFromJson(Map<String, dynamic> json) => Search(
      sortList: (json['sortList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: json['tags'] == null
          ? null
          : Tags.fromJson(json['tags'] as Map<String, dynamic>),
      titles: json['titles'] == null
          ? null
          : Titles.fromJson(json['titles'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchToJson(Search instance) => <String, dynamic>{
      'sortList': instance.sortList,
      'tags': instance.tags,
      'titles': instance.titles,
    };
