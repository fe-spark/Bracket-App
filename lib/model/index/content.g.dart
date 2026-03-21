// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Content _$ContentFromJson(Map<String, dynamic> json) => Content(
      hot: (json['hot'] as List<dynamic>?)
          ?.map((e) => Hot.fromJson(e as Map<String, dynamic>))
          .toList(),
      movies: (json['movies'] as List<dynamic>?)
          ?.map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .toList(),
      nav: json['nav'] == null
          ? null
          : Nav.fromJson(json['nav'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContentToJson(Content instance) => <String, dynamic>{
      'hot': instance.hot,
      'movies': instance.movies,
      'nav': instance.nav,
    };
