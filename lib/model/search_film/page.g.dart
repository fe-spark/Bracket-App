// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Page _$PageFromJson(Map<String, dynamic> json) => Page(
      pageSize: (json['pageSize'] as num?)?.toInt(),
      current: (json['current'] as num?)?.toInt(),
      pageCount: (json['pageCount'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PageToJson(Page instance) => <String, dynamic>{
      'pageSize': instance.pageSize,
      'current': instance.current,
      'pageCount': instance.pageCount,
      'total': instance.total,
    };
