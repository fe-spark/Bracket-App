// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoSource _$VideoSourceFromJson(Map<String, dynamic> json) => VideoSource(
      source:
          (json['source'] as List<dynamic>?)?.map((e) => e as String).toList(),
      actived: json['actived'] as String?,
    );

Map<String, dynamic> _$VideoSourceToJson(VideoSource instance) =>
    <String, dynamic>{
      'source': instance.source,
      'actived': instance.actived,
    };
