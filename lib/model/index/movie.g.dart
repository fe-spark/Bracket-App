// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
      id: (json['id'] as num?)?.toInt(),
      cid: (json['cid'] as num?)?.toInt(),
      pid: (json['pid'] as num?)?.toInt(),
      name: json['name'] as String?,
      subTitle: json['subTitle'] as String?,
      cName: json['cName'] as String?,
      state: json['state'] as String?,
      picture: json['picture'] as String?,
      actor: json['actor'] as String?,
      director: json['director'] as String?,
      blurb: json['blurb'] as String?,
      remarks: json['remarks'] as String?,
      area: json['area'] as String?,
      year: json['year'] as String?,
    );

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
      'id': instance.id,
      'cid': instance.cid,
      'pid': instance.pid,
      'name': instance.name,
      'subTitle': instance.subTitle,
      'cName': instance.cName,
      'state': instance.state,
      'picture': instance.picture,
      'actor': instance.actor,
      'director': instance.director,
      'blurb': instance.blurb,
      'remarks': instance.remarks,
      'area': instance.area,
      'year': instance.year,
    };
