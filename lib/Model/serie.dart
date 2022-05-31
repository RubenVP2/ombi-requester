///
/// Class representing a serie
///
class Serie {

  // Variables
  final String title;
  final String overview;
  final String backdropPath;
  final dynamic theMovieDbId;
  final double rating;
  final bool requestAll;
  final bool latestSeason;
  final bool firstSeason;
  final bool fullyAvailable;
  final bool partlyAvailable;
  final int id;
  final bool approved;
  final bool requested;
  final bool available;
  final bool denied;
  final dynamic imdbId;
  final dynamic theTvDbId;

  // Constructor
  Serie({
    required this.title,
    required this.overview,
    required this.backdropPath,
    required this.theMovieDbId,
    required this.rating,
    required this.requestAll,
    required this.latestSeason,
    required this.firstSeason,
    required this.fullyAvailable,
    required this.partlyAvailable,
    required this.id,
    required this.approved,
    required this.requested,
    required this.available,
    required this.denied,
    required this.imdbId,
    required this.theTvDbId,
  });


  // Methodes
  factory Serie.fromJson(Map<String, dynamic> json) {
    return Serie(
      title: json['title'],
      overview: json['overview'],
      backdropPath: json['backdropPath'],
      theMovieDbId: json['theMovieDbId'],
      rating: double.parse(json['rating']),
      requestAll: json['requestAll'],
      latestSeason: json['latestSeason'],
      firstSeason: json['firstSeason'],
      fullyAvailable: json['fullyAvailable'],
      partlyAvailable: json['partlyAvailable'],
      id: json['id'],
      approved: json['approved'],
      requested: json['requested'],
      available: json['available'],
      denied: json['denied'],
      imdbId: json['imdbId'],
      theTvDbId: json['theTvDbId'],
    );
  }

  @override
  String toString() {
    return 'Serie{title: $title, overview: $overview, backdropPath: $backdropPath, theMovieDbId: $theMovieDbId, rating: $rating, requestAll: $requestAll, latestSeason: $latestSeason, firstSeason: $firstSeason, fullyAvailable: $fullyAvailable, partlyAvailable: $partlyAvailable, id: $id, approved: $approved, requested: $requested, available: $available, denied: $denied, imdbId: $imdbId, theTvDbId: $theTvDbId}';
  }
}