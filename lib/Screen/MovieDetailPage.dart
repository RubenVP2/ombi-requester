import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertest/Model/rootFolder.dart';
import 'package:getwidget/getwidget.dart';
import '../Model/cast.dart';
import '../Model/genre.dart';
import '../Model/movie.dart';
import '../Model/movieDetail.dart';
import '../Model/profiles.dart';
import '../Service/http_service.dart';
import '../globals.dart';

class MovieDetailPage extends StatefulWidget {

  static const String routeName = '/movieDetail';

  final Movie movie;

  const MovieDetailPage({Key? key, required this.movie}) : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {

  final HttpService httpService = HttpService();

  late Future<Map> message;

  late bool _isMovieRequested;

  bool _isLoading = false;

  bool _isProfileSync = false;

  bool _isMovieSync = false;

  late Future<MovieDetail> movieDetail;

  // Controller
  late String dropdownValueProfiles;
  late String dropdownValueRootFolder;

  // Création d'une map pour stocker en key les id provenant du jsonDecode du localStorage profiles et la value = name
  String stringJson = App.getString('profiles');
  List<Profile> profilesList = [];

  String stringJsonRootPath = App.getString('rootPath');
  List<RootFolder> rootPathList = [];

  @override
  initState() {
    // isMovie requested ?
    _isMovieRequested = widget.movie.requested;
    if (stringJson != '' && stringJson != null) {
      // Convert string to json
      for (var profile in jsonDecode(stringJson)) {
        profilesList.add(Profile.fromJson(profile));
      }
      dropdownValueProfiles = profilesList.first.name;
      _isProfileSync = true;
      // Convert string to json
      for (var rootPath in jsonDecode(stringJsonRootPath)) {
        rootPathList.add(RootFolder.fromJson(rootPath));
      }
      dropdownValueRootFolder = rootPathList.first.path;
      _isMovieSync = true;
    }
    movieDetail = httpService.getMovieById(int.parse(widget.movie.theMovieDbId));
    super.initState();
  }

  Future _showDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _isProfileSync && _isMovieSync ?
        // Le StatefulWidget pour le DropdownButton est nécessaire pour pouvoir utiliser le state lors du changement de valeur
        AlertDialog(
            title: const Text("Sélectionnez vos paramètres"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Select for profiles
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButton<String>(
                      isExpanded: true,
                      value: dropdownValueProfiles,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValueProfiles = newValue!;
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
                // Select for rootPath
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButton<String>(
                      isExpanded: true,
                      value: dropdownValueRootFolder,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValueRootFolder = newValue!;
                        });
                      },
                      items: rootPathList.map((RootFolder rootPath) {
                        return DropdownMenuItem<String>(
                          value: rootPath.path,
                          child: Text(rootPath.path),
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
                child: const Text('Annuler', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              // Bouton d'ajout
              GFButton(
                color: Colors.deepPurple,
                textColor: Colors.white,
                onPressed: () {
                  setState(() => _isLoading = true);
                  // On ajoute le film à la liste des films demandés
                  message = httpService.addMovie(
                      widget.movie, profilesList.firstWhere((element) => element.name == dropdownValueProfiles).id,
                      rootPathList.firstWhere((element) => element.path == dropdownValueRootFolder).id
                  );
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
                child: const Text('Ajouter'),
              ),
            ],
        )
            :
        // Si le localStorage n'est pas synchronisé on affiche un message d'erreur
        AlertDialog(
          title: const Text("Profils non synchronisés"),
          content: const Text("Veuillez synchroniser vos profils"),
          actions: [
            // Bouton d'annulation
            TextButton(
              child: const Text('Annuler', style: TextStyle(color: Colors.red)),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                    widget.movie.voteAverage == 0 ? "Note IMDB : Non renseignée" :
                    "Note IMDB : ${widget.movie.voteAverage.toStringAsFixed(2)} / 10",
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
                    widget.movie.overview.isEmpty ? "Aucun synopsis disponible pour ce film." : widget.movie.overview,
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
                            child: Text("Oops erreur lors de la récupération des acteurs"),
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
                                // Make SizedBox dynamic height to avoid overflow error
                                // This SizedBox is for row spacing
                                height: MediaQuery.of(context).size.height / 2,
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
                    textColor: Colors.white,
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
                    text: "Demander le film",
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
