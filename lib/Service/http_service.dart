import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertest/Model/root_folder.dart';
import 'package:fluttertest/Model/serie_detail.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import '../Model/movie_detail.dart';
import '../Model/movie.dart';
import '../Model/serie.dart';
import '../globals.dart';
import 'dart:developer';

///
/// Class Service to communicate with the server
///
class HttpService {

  /// Variables
  String baseUrl = "";
  String apiKey = "";
  String username = "";

  /// Constructor
  HttpService() {
    // On récupère les données de l'API
    baseUrl = App.getString("baseUrl");
    apiKey = App.getString("apiKey");
    username = App.getString("username");
  }

  ///
  /// Get all movies for the type requested
  ///
  Future<List<Movie>?> getMovies(int currentPosition, int amountToLoad, String typeRequest) async {
    // Check if the url is valid
    if (baseUrl.isEmpty) {
      // Generation d'une erreur
      return Future.error("Url invalide, veuillez vérifier les données de l'API dans les paramètres");
    }
    // Construction of the url
    var url = Uri.parse("$baseUrl/v2/Search/movie/${typeRequest.toLowerCase()}/$currentPosition/$amountToLoad");
    late Response res;
    log("Requête de récupération des films sur l'url : $url", name: "HttpService", error: false );
    try {
      res = await get(url, headers: {
        "ApiKey": apiKey,
      }
      );
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
    }
    if (res.statusCode == 200) {
      if (kDebugMode) {
        log("Requête de récupération des films réussie", name: "HttpService", error: false );
        log("Body : ${res.body}", name: "HttpService", error: false );
      }
      List<dynamic> body = jsonDecode(res.body);
      List<Movie> movies = body.map((dynamic item) => Movie.fromJson(item)).toList();
      return movies;
    } else {
      return null;
    }
  }

  ///
  /// Get all series for the type requested
  ///
  Future<List<Serie>?> getSeries(int currentPosition, int amountToLoad, String typeRequest) async {
    // Check if the url is valid
    if (baseUrl.isEmpty) {
      // Generation d'une erreur
      return Future.error("Url invalide, veuillez vérifier les données de l'API dans les paramètres");
    }
    // Construction of the url
    var url = Uri.parse("$baseUrl/v2/Search/tv/${typeRequest.toLowerCase()}/$currentPosition/$amountToLoad");
    late Response res;
    log("Requête de récupération des séries sur l'url : $url", name: "HttpService", error: false );
    try {
      res = await get(url, headers: {
        "ApiKey": apiKey,
      }
      );
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
      }
    }
    // Check if the request was successful
    if (res.statusCode == 200) {
      if (kDebugMode) {
        log("Requête de récupération des séries réussie", name: "HttpService", error: false );
        log("Body : ${res.body}", name: "HttpService", error: false );
      }
      List<dynamic> body = jsonDecode(res.body);
      List<Serie> series = body.map((dynamic item) => Serie.fromJson(item)).toList();
      return series;
    } else {
      return null;
    }
  }

  ///
  ///  Query to add a Movie
  ///
  Future<Map> addMovie(Movie movie, int quality, int rootFolderOverride) async {
    // Create the url
    var url = Uri.parse("$baseUrl/v1/Request/movie");

    Map data = {
      'theMovieDbId': movie.theMovieDbId,
      'languageCode': 'fr',
      'qualityPathOverride': quality,
      'rootFolderOverride': rootFolderOverride,
      'is4kRequest': false,
    };
    // Encode Map to JSON
    var body = jsonEncode(data);
    // Envoi de la requête
    Response res = await post(url, headers: {"Content-Type": "application/json", "ApiKey": apiKey, "UserName": username}, body: body);

    if ( res.statusCode == 200 ) {
      var body = jsonDecode(res.body);
      return body;
    } else {
      throw "Erreur d'ajout du film";
    }
  }

  ///
  /// Query to add a serie
  ///
  Future<Map> addSerie(Serie serie, int quality, int rootFolderOverride, bool requestAll, bool latestSeason, bool firstSeason, int langageProfil, List seasons) async {
    // Create the url
    var url = Uri.parse("$baseUrl/v2/Requests/tv");

    Map data = {
        "theMovieDbId": serie.theMovieDbId,
        "languageCode": "fr",
        "requestAll": requestAll,
        "latestSeason": latestSeason,
        "languageProfile": langageProfil.toString(),
        "firstSeason": firstSeason,
        "seasons": seasons,
        "rootFolderOverride": rootFolderOverride,
        "qualityPathOverride": quality,
      };

    // Encode Map to JSON
    var body = jsonEncode(data);
    // Send the request
    Response res = await post(url, headers: {"Content-Type": "application/json", "ApiKey": apiKey, "UserName": username}, body: body);

    if ( res.statusCode == 200 ) {
      var body = jsonDecode(res.body);
      return body;
    } else {
      throw "Erreur d'ajout de la série";
    }
  }

  ///
  /// Get all movies already added or requested
  ///
  Future<List<Movie>> getAllMoviesRequested() async {
    var url = Uri.parse("$baseUrl/v1/Request/movie");

    Response res = await get(url, headers: {
        "ApiKey": apiKey,
      }
    );

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      List<Movie> movies = body.map((dynamic item) => Movie.fromJson(item)).toList();
      return movies;
    } else {
      throw "Erreur de récupération des données";
    }
  }

  ///
  /// Get all profiles from Radarr
  ///
  Future<String> syncProfilesRadarr() async {
    var url = Uri.parse("$baseUrl/v1/Radarr/Profiles");

    Response res = await get(url, headers: {
        "ApiKey": apiKey,
      }
    );

    if (res.statusCode == 200) {
      // Sauvegarde des profiles dans le localStorage
      App.setString('profilesRadarr', res.body);
      return "[Radarr] Données bien récupérées : ${jsonDecode(res.body).length} profils trouvé(s).";
    } else {
      return "Erreur de récupération des données";
    }
  }

  ///
  /// Get more informations about a movie from TheMovieDB
  ///
  Future<MovieDetail> getMovieById(int id) async {
    var url = Uri.parse("$baseUrl/v2/Search/movie/$id");

    Response res = await get(url, headers: {
        "ApiKey": apiKey,
    });

    if (res.statusCode == 200) {
      dynamic body = jsonDecode(res.body);
      return MovieDetail.fromJson(body);
    } else {
      throw "Erreur de récupération des données";
    }
  }

  ///
  /// Get more informations about a serie from TheMovieDB
  ///
  Future<SerieDetail> getSerieById(int id) async {
    var url = Uri.parse("$baseUrl/v2/Search/tv/$id");

    Response res = await get(url, headers: {
        "ApiKey": apiKey,
    });

    if (res.statusCode == 200) {
      dynamic body = jsonDecode(res.body);
      return SerieDetail.fromJson(body);
    } else {
      throw "Erreur de récupération des données";
    }
  }

  ///
  /// Get rootPathFolder from Radarr
  ///
  Future<String> syncRootPathRadarr() async {
    var url = Uri.parse("$baseUrl/v1/Radarr/RootFolders");

    Response res = await get(url, headers: {
        "ApiKey": apiKey,
    });

    if (res.statusCode == 200) {
      if (kDebugMode) {
        log("Requête de récupération des rootFolder pour Radarr réussie", name: "HttpService", error: false );
        log("Body : ${res.body}", name: "HttpService", error: false );
      }
      App.setString('rootPathRadarr', res.body);
      return "[Radarr] Données bien récupérées : ${jsonDecode(res.body).length} répertoires trouvé(s).";
    } else {
      throw "Erreur de récupération des données";
    }
  }

  ///
  /// Get rootPathFolder from Sonarr
  ///
  Future<String> syncRootPathSonarr() async {
    var url = Uri.parse("$baseUrl/v1/Sonarr/RootFolders");

    Response res = await get(url, headers: {
        "ApiKey": apiKey,
    });

    if (res.statusCode == 200) {
      if (kDebugMode) {
        log("Requête de récupération des rootFolder pour Sonarr réussie", name: "HttpService", error: false );
        log("Body : ${res.body}", name: "HttpService", error: false );
      }
      App.setString('rootPathSonarr', res.body);
      return "[Sonarr] Données bien récupérées depuis  : ${jsonDecode(res.body).length} répertoires trouvé(s).";
    } else {
      throw "Erreur de récupération des données";
    }
  }

  ///
  /// Get Profiles from Sonarr
  ///
  Future<String> syncProfilesSonarr() async {
    var url = Uri.parse("$baseUrl/v1/Sonarr/Profiles");

    Response res = await get(url, headers: {
        "ApiKey": apiKey,
    });

    if (res.statusCode == 200) {
      App.setString('profilesSonarr', res.body);
      return "[Sonarr] Données bien récupérées : ${jsonDecode(res.body).length} profils trouvé(s).";
    } else {
      throw "Erreur de récupération des données";
    }
  }

  ///
  /// Get Lanage Profiles from Sonarr
  ///
  Future<String> syncLangageProfilesSonarr() async {
    var url = Uri.parse("$baseUrl/v1/Sonarr/v3/LanguageProfiles");

    Response res = await get(url, headers: {
        "ApiKey": apiKey,
    });

    if (res.statusCode == 200) {
      App.setString('langageProfilesSonarr', res.body);
      return "[Sonarr] Données bien récupérées : ${jsonDecode(res.body).length} profils trouvé(s).";
    } else {
      throw "Erreur de récupération des données";
    }
  }
}