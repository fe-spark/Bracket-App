import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'data.dart';

part 'index.g.dart';

@JsonSerializable()
class Recommend {
  final Data? data;
  final String? status;

  const Recommend({this.data, this.status});

  @override
  String toString() => 'Recommend(data: $data, status: $status)';

  factory Recommend.fromJson(Map<String, dynamic> json) {
    return _$RecommendFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RecommendToJson(this);

  Recommend copyWith({
    Data? data,
    String? status,
  }) {
    return Recommend(
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Recommend) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => data.hashCode ^ status.hashCode;
}
