// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'descriptor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Descriptor _$DescriptorFromJson(Map<String, dynamic> json) => Descriptor(
      subTitle: json['subTitle'] as String?,
      cName: json['cName'] as String?,
      enName: json['enName'] as String?,
      initial: json['initial'] as String?,
      classTag: json['classTag'] as String?,
      actor: json['actor'] as String?,
      director: json['director'] as String?,
      writer: json['writer'] as String?,
      blurb: json['blurb'] as String?,
      remarks: json['remarks'] as String?,
      releaseDate: json['releaseDate'] as String?,
      area: json['area'] as String?,
      language: json['language'] as String?,
      year: json['year'] as String?,
      state: json['state'] as String?,
      updateTime: json['updateTime'] as String?,
      addTime: (json['addTime'] as num?)?.toInt(),
      dbId: (json['dbId'] as num?)?.toInt(),
      dbScore: json['dbScore'] as String?,
      hits: (json['hits'] as num?)?.toInt(),
      content: json['content'] as String?,
    );

Map<String, dynamic> _$DescriptorToJson(Descriptor instance) =>
    <String, dynamic>{
      'subTitle': instance.subTitle,
      'cName': instance.cName,
      'enName': instance.enName,
      'initial': instance.initial,
      'classTag': instance.classTag,
      'actor': instance.actor,
      'director': instance.director,
      'writer': instance.writer,
      'blurb': instance.blurb,
      'remarks': instance.remarks,
      'releaseDate': instance.releaseDate,
      'area': instance.area,
      'language': instance.language,
      'year': instance.year,
      'state': instance.state,
      'updateTime': instance.updateTime,
      'addTime': instance.addTime,
      'dbId': instance.dbId,
      'dbScore': instance.dbScore,
      'hits': instance.hits,
      'content': instance.content,
    };
