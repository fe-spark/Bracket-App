// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'film_play_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FilmPlayInfo _$FilmPlayInfoFromJson(Map<String, dynamic> json) => FilmPlayInfo(
      code: (json['code'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String?,
    );

Map<String, dynamic> _$FilmPlayInfoToJson(FilmPlayInfo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'msg': instance.msg,
    };
