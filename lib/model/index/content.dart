import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'hot.dart';
import 'movie.dart';
import 'nav.dart';

part 'content.g.dart';

@JsonSerializable()
class Content {
  final List<Hot>? hot;
  final List<Movie>? movies;
  final Nav? nav;

  const Content({this.hot, this.movies, this.nav});

  @override
  String toString() => 'Content(hot: $hot, movies: $movies, nav: $nav)';

  factory Content.fromJson(Map<String, dynamic> json) {
    return _$ContentFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ContentToJson(this);

  Content copyWith({
    List<Hot>? hot,
    List<Movie>? movies,
    Nav? nav,
  }) {
    return Content(
      hot: hot ?? this.hot,
      movies: movies ?? this.movies,
      nav: nav ?? this.nav,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Content) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => hot.hashCode ^ movies.hashCode ^ nav.hashCode;
}
