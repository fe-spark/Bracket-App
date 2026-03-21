// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_film.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchFilm _$SearchFilmFromJson(Map<String, dynamic> json) => SearchFilm(
      code: (json['code'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String?,
    );

Map<String, dynamic> _$SearchFilmToJson(SearchFilm instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
    };
