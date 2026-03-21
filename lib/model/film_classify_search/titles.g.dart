// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'titles.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Titles _$TitlesFromJson(Map<String, dynamic> json) => Titles(
      area: json['Area'] as String?,
      category: json['Category'] as String?,
      initial: json['Initial'] as String?,
      language: json['Language'] as String?,
      plot: json['Plot'] as String?,
      sort: json['Sort'] as String?,
      year: json['Year'] as String?,
    );

Map<String, dynamic> _$TitlesToJson(Titles instance) => <String, dynamic>{
      'Area': instance.area,
      'Category': instance.category,
      'Initial': instance.initial,
      'Language': instance.language,
      'Plot': instance.plot,
      'Sort': instance.sort,
      'Year': instance.year,
    };
