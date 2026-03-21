import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'child.g.dart';

@JsonSerializable()
class Child {
  final int? id;
  final int? pid;
  final String? name;
  final List<Child>? children;

  const Child({this.id, this.pid, this.name, this.children});

  @override
  String toString() {
    return 'Child(id: $id, pid: $pid, name: $name, children: $children)';
  }

  factory Child.fromJson(Map<String, dynamic> json) => _$ChildFromJson(json);

  Map<String, dynamic> toJson() => _$ChildToJson(this);

  Child copyWith({
    int? id,
    int? pid,
    String? name,
    List<Child>? children,
  }) {
    return Child(
      id: id ?? this.id,
      pid: pid ?? this.pid,
      name: name ?? this.name,
      children: children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Child) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      id.hashCode ^ pid.hashCode ^ name.hashCode ^ children.hashCode;
}
