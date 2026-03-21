// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) => Data(
      current: json['current'] == null
          ? null
          : Current.fromJson(json['current'] as Map<String, dynamic>),
      currentEpisode: (json['currentEpisode'] as num?)?.toInt(),
      currentPlayFrom: json['currentPlayFrom'] as String?,
      detail: json['detail'] == null
          ? null
          : Detail.fromJson(json['detail'] as Map<String, dynamic>),
      relate: (json['relate'] as List<dynamic>?)
          ?.map((e) => Relate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
      'current': instance.current,
      'currentEpisode': instance.currentEpisode,
      'currentPlayFrom': instance.currentPlayFrom,
      'detail': instance.detail,
      'relate': instance.relate,
    };
