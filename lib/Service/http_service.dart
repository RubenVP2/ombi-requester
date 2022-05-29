import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertest/Model/rootFolder.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import '../Model/movieDetail.dart';
import '../Model/movie.dart';
import '../globals.dart';
import 'dart:developer';

///
/// Classe permettant de récupérer les données depuis l'API
///
class HttpService {

  String baseUrl = "";
  String apiKey = "";
  String username = "";

  HttpService() {
    // On récupère les données de l'API
    baseUrl = App.getString("baseUrl");
    apiKey = App.getString("apiKey");
    username = App.getString("username");
  }
  ///
  /// Récupère les films populaires
  ///
  Future<List<Movie>?> getMovies(int currentPosition, int amountToLoad, String typeRequest) async {
    // Check pour savoir si l'url est correcte
    if (baseUrl.isEmpty) {
      // Generation d'une erreur
      return Future.error("Url invalide, veuillez vérifier les données de l'API dans les paramètres");
    }
    // Récupération des films populaires
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
  ///  Execute une requête d'ajout de film
  ///
  Future<Map> addMovie(Movie movie, int quality, int rootFolderOverride, bool is4kRequest) async {
    // Variable en dur pour la configuration de radarr
    var url = Uri.parse("$baseUrl/v1/Request/movie");

    Map data = {
      'theMovieDbId': movie.theMovieDbId,
      'languageCode': 'fr',
      'qualityPathOverride': quality,
      'rootFolderOverride': rootFolderOverride,
      'is4kRequest': is4kRequest,
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
  /// Récupère tous les films déjà ajoutés ou demandés
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
  /// Récupère tous les profiles Radarr disponibles
  ///
  Future<String> syncProfiles() async {
    var url = Uri.parse("$baseUrl/v1/Radarr/Profiles");

    Response res = await get(url, headers: {
        "ApiKey": apiKey,
      }
    );

    if (res.statusCode == 200) {
      // Sauvegarde des profiles dans le localStorage
      App.setString('profiles', res.body);
      return "Données bien récupérées : ${jsonDecode(res.body).length} profils trouvé(s).";
    } else {
      return "Erreur de récupération des données";
    }
  }

  ///
  /// Récupère plus d'informations sur un films en fonction de son id
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
  /// Récupère le rootPathFolder
  ///
  Future<String> syncRootPath() async {
    var url = Uri.parse("$baseUrl/v1/Radarr/RootFolders");

    Response res = await get(url, headers: {
        "ApiKey": apiKey,
    });

    if (res.statusCode == 200) {
      if (kDebugMode) {
        log("Requête de récupération des films réussie", name: "HttpService", error: false );
        log("Body : ${res.body}", name: "HttpService", error: false );
      }
      App.setString('rootPath', res.body);
      return "Données bien récupérées : ${jsonDecode(res.body).length} répertoires trouvé(s).";
    } else {
      throw "Erreur de récupération des données";
    }
  }
}