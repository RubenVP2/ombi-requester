import 'cast_serie.dart';
import 'genre.dart';

class SerieDetail {

  final List<Genre> genres;
  final List<CastSerie> cast;
  final List<SeasonRequest> seasonRequests;

  SerieDetail({
    required this.genres,
    required this.cast,
    required this.seasonRequests,
  });

  // Getter cast
  List<CastSerie> get getCast => cast;

  // Getter genres
  List<Genre> get getGenres => genres;

  factory SerieDetail.fromJson(Map<String, dynamic> json) {
    return SerieDetail(
      genres: (json['genres'] as List<dynamic>).map((dynamic item) => Genre.fromJson(item)).toList(),
      cast: (json['cast'] as List<dynamic>).map((dynamic item) => CastSerie.fromJson(item)).toList(),
      seasonRequests: (json['seasonRequests'] as List<dynamic>).map((dynamic item) => SeasonRequest.fromJson(item)).toList(),
    );
  }

  @override
  String toString() {
    return 'MovieDetail{genres: $genres, cast: $cast}';
  }
}

class SeasonRequest {

  final int seasonNumber;
  final String overview;
  final bool seasonAvailable;
  final List<Episode> episodes;

  SeasonRequest({
    required this.seasonNumber,
    required this.overview,
    required this.seasonAvailable,
    required this.episodes,
  });

  factory SeasonRequest.fromJson(Map<String, dynamic> json) {
    return SeasonRequest(
      seasonNumber: json['seasonNumber'],
      overview: json['overview'],
      seasonAvailable: json['seasonAvailable'],
      episodes: (json['episodes'] as List<dynamic>).map((dynamic item) => Episode.fromJson(item)).toList(),
    );
  }

  // this method test if inside episodes list, there is an episode with the same number
  // if yes, return true
  bool isEpisodeAvailable(Episode episode) {
    for (var ep in episodes) {
      if (ep.episodeNumber == episode.episodeNumber) {
        return true;
      }
    }
    return false;
  }

  // this method add an episode to the list of episodes with the episode number
  // if the episode is already in the list, it will not add it
  void addEpisode(Episode episode) {
    if (!isEpisodeAvailable(episode)) {
      episodes.add(episode);
    }
  }

  // this method remove an episode from the list of episodes with the episode number
  // if the episode is not in the list, it will not remove it
  void removeEpisode(Episode episode) {
    if (isEpisodeAvailable(episode)) {
      episodes.remove(episode);
    }
  }

  // This method only return the season number and the list of episodes from toSonarrJson()
  Map<String, dynamic> toSonarrJson() {
    return {
      'seasonNumber': seasonNumber,
      'episodes': episodes.map((dynamic item) => item.toSonarrJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'SeasonRequest{seasonNumber: $seasonNumber, overview: $overview, seasonAvailable: $seasonAvailable, episodes: $episodes}';
  }
}

class Episode {
  int episodeNumber;
  String title;
  bool available;
  bool approved;
  bool requested;
  bool denied;
  String airDateDisplay;
  bool isChecked;

  Episode({
    required this.episodeNumber,
    required this.title,
    required this.available,
    required this.approved,
    required this.requested,
    required this.denied,
    required this.airDateDisplay,
    required this.isChecked,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNumber: json['episodeNumber'],
      title: json['title'],
      available: json['available'],
      approved: json['approved'],
      requested: json['requested'],
      denied: json['denied'],
      airDateDisplay: json['airDateDisplay'],
      isChecked: false,
    );
  }

  // This method only return a map that contains the values for only episodeNumber
  // Sonarr api doesn't return the other values
  Map<String, dynamic> toSonarrJson() {
    return {
      'episodeNumber': episodeNumber,
    };
  }

  @override
  String toString() {
    return 'Episode{episodeNumber: $episodeNumber, title: $title, available: $available, approved: $approved, requested: $requested, denied: $denied, airDateDisplay: $airDateDisplay}';
  }
}