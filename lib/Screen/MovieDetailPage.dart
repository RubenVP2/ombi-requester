import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import '../Model/cast.dart';
import '../Model/genre.dart';
import '../Model/movie.dart';
import '../Model/movieDetail.dart';
import '../Model/profiles.dart';
import '../Service/http_service.dart';
import '../globals.dart';

class MovieDetailPage extends StatefulWidget {

  final Movie movie;

  const MovieDetailPage({Key? key, required this.movie}) : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {

  final HttpService httpService = HttpService();

  late Future<Map> message;

  bool _isMovieRequested = false;

  bool _isLoading = false;

  bool _isProfileSync = false;

  late Future<MovieDetail> movieDetail;

  // Controller
  late String dropdownValue;

  // Création d'une map pour stocker en key les id provenant du jsonDecode du localStorage profiles et la value = name
  String stringJson = App.getString('profiles');

  List<Profile> profilesList = [];

  @override
  initState() {
    // On Récupère tous les films demandés par l'utilisateur pour savoir si le film est déjà dans la liste on affiche pas le bouton d'ajout
    httpService.getAllMoviesRequested().then((value) {
      setState(() {
        _isMovieRequested = value.any((element) => element.theMovieDbId == widget.movie.theMovieDbId);
      });
    });
    // Cast json to Profile class
    if (stringJson != '') {
      for (var profile in jsonDecode(stringJson)) {
        profilesList.add(Profile.fromJson(profile));
      }
      dropdownValue = profilesList.first.name;
      _isProfileSync = true;
    }
    movieDetail = httpService.getMovieById(int.parse(widget.movie.theMovieDbId));
    super.initState();
  }

  Future _showDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _isProfileSync ?
        // Le StatefulWidget pour le DropdownButton est nécessaire pour pouvoir utiliser le state lors du changement de valeur
        AlertDialog(
            title: const Text("Ajouter le film à Radarr"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Choix du choix de la qualité dans un DropDown
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButton<String>(
                      isExpanded: true,
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: profilesList.map((Profile profile) {
                        return DropdownMenuItem<String>(
                          value: profile.name,
                          child: Text(profile.name),
                        );
                      }).toList(),
                    );
                  }
                ),
              ],
            ),
            actions: [
              // Bouton d'annulation
              TextButton(
                child: const Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              // Bouton d'ajout
              TextButton(
                child: const Text('Ajouter'),
                onPressed: () {
                  setState(() => _isLoading = true);
                  // On ajoute le film à la liste des films demandés
                  message = httpService.addMovie(widget.movie, profilesList.firstWhere((element) => element.name == dropdownValue).id);
                  message.then((value) {
                    // Apparition de la notification
                    GFToast.showToast(
                      value["message"],
                      context,
                      toastPosition: GFToastPosition.BOTTOM,
                      toastDuration: 3,
                      backgroundColor: Colors.deepPurple,
                      trailing: const Icon(
                        Icons.info,
                        color: Colors.black,
                      ),
                    );
                    // On change la variable qui permet de savoir si le film est déjà dans la liste
                    if ( value["isError"] == "false" || value["isError"] == false ) {
                      setState(() {
                        _isMovieRequested = true;
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                    }
                  });
                },
              ),
            ],
        )
            :
        // Si le localStorage n'est pas synchronisé on affiche un message d'erreur
        AlertDialog(
          title: const Text("Erreur"),
          content: const Text("Veuillez synchroniser vos profiles"),
          actions: [
            // Bouton d'annulation
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détails du film : ${widget.movie.title}"),
      ),
      // Scrollable content
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie poster
                Stack(
                    children: [
                      // Poster blur effect behing the poster
                      Container(
                        height: MediaQuery.of(context).size.height / 1.3,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage("https://image.tmdb.org/t/p/w500/${widget.movie.posterPath}"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height / 1.3,
                          padding: const EdgeInsets.all(8),
                          child: Image.network("https://image.tmdb.org/t/p/w500/${widget.movie.posterPath}")
                        ),
                      ),
                    ]
                ),
                // Movie title
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 10),
                  child: Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Movie vote average rounded to 2 decimals and emojis for stars
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: Text(
                    widget.movie.voteAverage != 0 ?
                    "Note IMDB : ${widget.movie.voteAverage.toStringAsFixed(2)} / 10"
                        : "Note IMDB : Non renseignée",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Movie overview
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    widget.movie.overview.isEmpty ? "Aucun synopsis disponible" : widget.movie.overview,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                // List of casting actors from MovieDetail
                FutureBuilder(
                  future: movieDetail,
                  builder: (BuildContext context, AsyncSnapshot<MovieDetail> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text("Erreur lors de la récupération des acteurs"),
                          );
                        } else {
                          MovieDetail? movieDetailFromSnapshot = snapshot.data;
                          return Column(
                            children: [
                              // Affichage de badge pour les genres du film
                              Wrap(
                                spacing: 5,
                                runSpacing: 10,
                                children: movieDetailFromSnapshot!.genres.map((Genre genre) {
                                  return Chip(
                                    label: Text(genre.name),
                                    backgroundColor: Colors.deepPurple,
                                  );
                                }).toList(),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 3.15,
                                width: double.maxFinite,
                                child: ListView(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(10),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      for (Cast cast in movieDetailFromSnapshot.getCast)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 30, top: 20),
                                          child: Column(
                                            children: [
                                              // Actor avatar
                                              GFAvatar(
                                                backgroundImage: NetworkImage("https://image.tmdb.org/t/p/w500/${cast.profilePath}"),
                                                shape: GFAvatarShape.standard,
                                                size: 100,
                                              ),
                                              // Actor name
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Text(
                                                  cast.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              // Character name
                                              Padding(
                                                padding: const EdgeInsets.only(top: 5),
                                                child: Text(
                                                  cast.character,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ]
                                ),
                              ),
                            ],
                          );
                        }
                      default:
                        return const Center(child: CircularProgressIndicator(),);
                    }
                  },
                ),
                // Bouton d'ajout du film à radarr
                _isMovieRequested
                    ?
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: GFButton(
                    onPressed: null,
                    text: "Ce film a déjà été ajouté.",
                    color: Colors.deepPurple,
                    type: GFButtonType.solid,
                    fullWidthButton: true,
                  ),
                )
                    :
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GFButton(
                    onPressed: () {
                      // Dialog pour choisir les paramètres de l'ajout
                      _showDialog();
                    },
                    text: "Ajouter à Radarr",
                    color: Colors.deepPurple,
                    fullWidthButton: true,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
    );
  }
}
