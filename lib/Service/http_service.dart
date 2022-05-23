import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/movie.dart';

///
/// Classe permettant de récupérer les données depuis l'API
///
class HttpService {

  String baseUrl = "";
  String apiKey = "";
  String username = "";

  HttpService() {
    // On récupère les données de l'API
    SharedPreferences.getInstance().then((prefs) {
      baseUrl = prefs.getString('baseUrl') ?? baseUrl;
      apiKey = prefs.getString('apiKey') ?? apiKey;
      username = prefs.getString('username') ?? username;
    });
  }
  ///
  /// Récupère les films populaires
  ///
  Future<List<Movie>?> getPopular(int currentPosition, int amountToLoad, String typeRequest) async {
    // Check pour savoir si l'url est correcte
    if (baseUrl.isEmpty) {
      return null;
    }
    // Récupération des films populaires
    var url = Uri.parse("$baseUrl/v2/Search/movie/${typeRequest.toLowerCase()}/$currentPosition/$amountToLoad");
    late Response res;

    try {
      res = await get(url, headers: {
        "ApiKey": "8d116c0af172470f83a9b454e1ea7bb2"
      }
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    if (res.statusCode == 200) {
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
  Future<Map> addMovie(Movie movie) async {
    // Variable en dur pour la configuration de radarr
    var url = Uri.parse("$baseUrl/v1/Request/movie");

    Map data = {
      'theMovieDbId': movie.theMovieDbId,
      'languageCode': 'fr',
      'qualityPathOverride': 4,
      'rootFolderOverride': 5,
      'requestOnBehalf': '91f4eeb2-7a9b-4103-9c39-6a35ed8b3e35',
      'is4kRequest': false,
    };
    // Encode Map to JSON
    var body = jsonEncode(data);
    // Envoi de la requête
    Response res = await post(url, headers: {"Content-Type": "application/json", "ApiKey": "8d116c0af172470f83a9b454e1ea7bb2", "UserName": "ruben"}, body: body);

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
        "ApiKey": "8d116c0af172470f83a9b454e1ea7bb2"
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

}