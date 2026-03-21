import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'child.dart';

part 'nav.g.dart';

@JsonSerializable()
class Nav {
  final int? id;
  final int? pid;
  final String? name;
  final List<Child>? children;

  const Nav({this.id, this.pid, this.name, this.children});

  @override
  String toString() {
    return 'Nav(id: $id, pid: $pid, name: $name, children: $children)';
  }

  factory Nav.fromJson(Map<String, dynamic> json) => _$NavFromJson(json);

  Map<String, dynamic> toJson() => _$NavToJson(this);

  Nav copyWith({
    int? id,
    int? pid,
    String? name,
    List<Child>? children,
  }) {
    return Nav(
      id: id ?? this.id,
      pid: pid ?? this.pid,
      name: name ?? this.name,
      children: children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Nav) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      id.hashCode ^ pid.hashCode ^ name.hashCode ^ children.hashCode;
}
