import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'category.dart';
import 'content.dart';

part 'data.g.dart';

@JsonSerializable()
class Data {
  final Category? category;
  final List<Content>? content;

  const Data({this.category, this.content});

  @override
  String toString() => 'Data(category: $category, content: $content)';

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);

  Data copyWith({
    Category? category,
    List<Content>? content,
  }) {
    return Data(
      category: category ?? this.category,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Data) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => category.hashCode ^ content.hashCode;
}
