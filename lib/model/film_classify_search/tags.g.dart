// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tags _$TagsFromJson(Map<String, dynamic> json) => Tags(
      area: (json['Area'] as List<dynamic>?)
          ?.map((e) => Area.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: (json['Category'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      initial: (json['Initial'] as List<dynamic>?)
          ?.map((e) => Initial.fromJson(e as Map<String, dynamic>))
          .toList(),
      language: (json['Language'] as List<dynamic>?)
          ?.map((e) => Language.fromJson(e as Map<String, dynamic>))
          .toList(),
      plot: (json['Plot'] as List<dynamic>?)
          ?.map((e) => Plot.fromJson(e as Map<String, dynamic>))
          .toList(),
      sort: (json['Sort'] as List<dynamic>?)
          ?.map((e) => Sort.fromJson(e as Map<String, dynamic>))
          .toList(),
      year: (json['Year'] as List<dynamic>?)
          ?.map((e) => Year.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TagsToJson(Tags instance) => <String, dynamic>{
      'Area': instance.area,
      'Category': instance.category,
      'Initial': instance.initial,
      'Language': instance.language,
      'Plot': instance.plot,
      'Sort': instance.sort,
      'Year': instance.year,
    };
