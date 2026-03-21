// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

History _$HistoryFromJson(Map<String, dynamic> json) => History(
      id: (json['id'] as num?)?.toInt(),
      timeStamp: (json['timeStamp'] as num?)?.toInt(),
      name: json['name'] as String?,
      picture: json['picture'] as String?,
    );

Map<String, dynamic> _$HistoryToJson(History instance) => <String, dynamic>{
      'id': instance.id,
      'timeStamp': instance.timeStamp,
      'name': instance.name,
      'picture': instance.picture,
    };
