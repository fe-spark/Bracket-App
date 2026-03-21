import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'child.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int? id;
  final int? pid;
  final String? name;
  final List<Child>? children;

  const Category({this.id, this.pid, this.name, this.children});

  @override
  String toString() {
    return 'Category(id: $id, pid: $pid, name: $name, children: $children)';
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return _$CategoryFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  Category copyWith({
    int? id,
    int? pid,
    String? name,
    List<Child>? children,
  }) {
    return Category(
      id: id ?? this.id,
      pid: pid ?? this.pid,
      name: name ?? this.name,
      children: children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Category) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      id.hashCode ^ pid.hashCode ^ name.hashCode ^ children.hashCode;
}
