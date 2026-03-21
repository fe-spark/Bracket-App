// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Detail _$DetailFromJson(Map<String, dynamic> json) => Detail(
      id: (json['id'] as num?)?.toInt(),
      cid: (json['cid'] as num?)?.toInt(),
      pid: (json['pid'] as num?)?.toInt(),
      name: json['name'] as String?,
      picture: json['picture'] as String?,
      playFrom: (json['playFrom'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      downFrom: json['DownFrom'] as String?,
      playList: (json['playList'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>)
              .map((e) => PlayItem.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
      downloadList: (json['downloadList'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>)
              .map((e) => DownloadList.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
      descriptor: json['descriptor'] == null
          ? null
          : Descriptor.fromJson(json['descriptor'] as Map<String, dynamic>),
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => ListData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DetailToJson(Detail instance) => <String, dynamic>{
      'id': instance.id,
      'cid': instance.cid,
      'pid': instance.pid,
      'name': instance.name,
      'picture': instance.picture,
      'playFrom': instance.playFrom,
      'DownFrom': instance.downFrom,
      'playList': instance.playList,
      'downloadList': instance.downloadList,
      'descriptor': instance.descriptor,
      'list': instance.list,
    };
