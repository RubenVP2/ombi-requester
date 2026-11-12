import 'cast.dart';
import 'genre.dart';

class MovieDetail {

  final List<Genre> genres;
  final List<Cast> cast;

  MovieDetail({
    required this.genres,
    required this.cast,
  });

  // Getter cast
  List<Cast> get getCast => cast;

  // Getter genres
  List<Genre> get getGenres => genres;

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      genres: (json['genres'] as List<dynamic>).map((dynamic item) => Genre.fromJson(item)).toList(),
      cast: (json['credits']['cast'] as List<dynamic>).map((dynamic item) => Cast.fromJson(item)).toList(),
    );
  }

  @override
  String toString() {
    return 'MovieDetail{genres: $genres, cast: $cast}';
  }
}