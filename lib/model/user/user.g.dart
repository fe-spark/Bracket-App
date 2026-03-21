// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: (json['user_id'] as num?)?.toInt(),
      userToken: json['user_token'] as String?,
      userName: json['user_name'] as String?,
      userAvator: json['user_avator'] as String?,
      userPhone: (json['user_phone'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.userId,
      'user_token': instance.userToken,
      'user_name': instance.userName,
      'user_avator': instance.userAvator,
      'user_phone': instance.userPhone,
    };
