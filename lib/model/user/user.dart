import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'user_token')
  String? userToken;
  @JsonKey(name: 'user_name')
  String? userName;
  @JsonKey(name: 'user_avator')
  String? userAvator;
  @JsonKey(name: 'user_phone')
  int? userPhone;

  User({
    this.userId,
    this.userToken,
    this.userName,
    this.userAvator,
    this.userPhone,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? userId,
    String? userToken,
    String? userName,
    String? userAvator,
    int? userPhone,
  }) {
    return User(
      userId: userId ?? this.userId,
      userToken: userToken ?? this.userToken,
      userName: userName ?? this.userName,
      userAvator: userAvator ?? this.userAvator,
      userPhone: userPhone ?? this.userPhone,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! User) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      userId.hashCode ^
      userToken.hashCode ^
      userName.hashCode ^
      userAvator.hashCode ^
      userPhone.hashCode;
}
