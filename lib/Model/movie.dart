///
/// Class representing a movie.
///
class Movie {

  final String title;
  late final String posterPath;
  final String overview;
  final int id;
  final String imdbId;
  final double voteAverage;
  final bool requested;
  final bool approved;
  final bool available;
  final bool denied;
  dynamic theMovieDbId;

  Movie({
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.id,
    required this.imdbId,
    required this.voteAverage,
    required this.requested,
    required this.approved,
    required this.available,
    required this.denied,
    required this.theMovieDbId,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      posterPath: json['posterPath'],
      overview: json['overview'],
      id: json['id'],
      imdbId: json['imdbId'],
      requested: json['requested'],
      denied: json['denied'],
      approved: json['approved'],
      available: json['available'],
      voteAverage: json['voteAverage'],
      // Cast theMovieDbId as a String to avoid a null value and int
      theMovieDbId: json['theMovieDbId'].toString(),
    );
  }

  @override
  toString() {
    return 'Movie{title: $title, posterPath: $posterPath, overview: $overview, voteAverage: $voteAverage, id: $id, imdbId: $imdbId, '
        'theMovieDbId: $theMovieDbId, requested: $requested, approved: $approved, available: $available}';
  }

}