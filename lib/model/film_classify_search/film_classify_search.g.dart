// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'film_classify_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FilmClassifySearch _$FilmClassifySearchFromJson(Map<String, dynamic> json) =>
    FilmClassifySearch(
      code: (json['code'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String?,
    );

Map<String, dynamic> _$FilmClassifySearchToJson(FilmClassifySearch instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
    };
