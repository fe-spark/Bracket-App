// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hot _$HotFromJson(Map<String, dynamic> json) => Hot(
      id: (json['ID'] as num?)?.toInt(),
      createdAt: json['CreatedAt'] as String?,
      updatedAt: json['UpdatedAt'] as String?,
      deletedAt: json['DeletedAt'],
      mid: (json['mid'] as num?)?.toInt(),
      cid: (json['cid'] as num?)?.toInt(),
      pid: (json['pid'] as num?)?.toInt(),
      name: json['name'] as String?,
      subTitle: json['subTitle'] as String?,
      cName: json['CName'] as String?,
      classTag: json['classTag'] as String?,
      area: json['area'] as String?,
      language: json['language'] as String?,
      year: (json['year'] as num?)?.toInt(),
      initial: json['initial'] as String?,
      updateStamp: (json['updateStamp'] as num?)?.toInt(),
      hits: (json['hits'] as num?)?.toInt(),
      state: json['state'] as String?,
      remarks: json['remarks'] as String?,
      releaseStamp: (json['releaseStamp'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HotToJson(Hot instance) => <String, dynamic>{
      'ID': instance.id,
      'CreatedAt': instance.createdAt,
      'UpdatedAt': instance.updatedAt,
      'DeletedAt': instance.deletedAt,
      'mid': instance.mid,
      'cid': instance.cid,
      'pid': instance.pid,
      'name': instance.name,
      'subTitle': instance.subTitle,
      'CName': instance.cName,
      'classTag': instance.classTag,
      'area': instance.area,
      'language': instance.language,
      'year': instance.year,
      'initial': instance.initial,
      'updateStamp': instance.updateStamp,
      'hits': instance.hits,
      'state': instance.state,
      'remarks': instance.remarks,
      'releaseStamp': instance.releaseStamp,
    };
