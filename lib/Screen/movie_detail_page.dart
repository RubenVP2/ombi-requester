import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertest/Model/cast_serie.dart';
import 'package:fluttertest/Model/root_folder.dart';
import 'package:fluttertest/Model/serie_detail.dart';
import 'package:fswitch_nullsafety/fswitch_nullsafety.dart';
import 'package:getwidget/getwidget.dart';
import '../Model/cast.dart';
import '../Model/genre.dart';
import '../Model/movie.dart';
import '../Model/movie_detail.dart';
import '../Model/profiles.dart';
import '../Model/serie.dart';
import '../Service/http_service.dart';
import '../globals.dart';

class MovieDetailPage extends StatefulWidget {
  static const String routeName = '/mediaDetail';

  Object media;
  String mediaType;

  MovieDetailPage({Key? key, required this.media, required this.mediaType})
      : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final HttpService httpService = HttpService();

  late final Movie? movie;

  late final Serie? serie;

  late Future<Map> message;

  late bool _isMediaRequested;

  bool _isLoading = false;

  late bool _isMovie;

  bool _isProfileSync = false;

  bool _isMediaSync = false;

  bool _showContent = false;


  // Future that get the media detail
  late Future<MovieDetail> movieDetail;
  late Future<SerieDetail> serieDetail;

  // Variable for alertDialog for tv show
  bool _isAllRequested = false;
  bool _isFirstSeasonRequested = false;
  bool _isLastSeasonRequested = false;
  final List _seasonsList = [];
  // All is empty and in function of what user want to download we will fill it
  final List _seasonsListForSonarr = [];

  // Controller
  late String dropdownValueProfilesRadarr;
  late String dropdownValueRootFolderRadarr;

  late String dropdownValueProfilesSonarr;
  late String dropdownValueRootFolderSonarr;

  late String dropdownValueLanguageProfileSonarr;

  // Create a map to store in key the id from jsonDecode of localStorage profiles and the value = name
  String profilesRadarrString = App.getString('profilesRadarr');
  List<Profile> profilesRadarrList = [];

  String rootPathStringRadarr = App.getString('rootPathRadarr');
  List<RootFolder> rootPathRadarrList = [];

  String profilesSonarrString = App.getString('profilesSonarr');
  List<Profile> profilesSonarrList = [];

  String rootPathStringSonarr = App.getString('rootPathSonarr');
  List<RootFolder> rootPathSonarrList = [];

  String langageProfilesSonarrString = App.getString('langageProfilesSonarr');
  List<Profile> langageProfilesSonarrList = [];

  @override
  initState() {
    // Cast the widget.media to Movie or Serie
    if (widget.mediaType == 'movie') {
      _isMovie = true;
      serie = null;
      movie = widget.media as Movie;
      // isMedia requested ?
      _isMediaRequested = movie!.requested;
      // Get from localStorage Radarr informations
      if (profilesRadarrString != '') {
        // Convert string to json
        for (var profile in jsonDecode(profilesRadarrString)) {
          profilesRadarrList.add(Profile.fromJson(profile));
        }
        dropdownValueProfilesRadarr = profilesRadarrList.first.name;
        _isProfileSync = true;
        // Convert string to json
        for (var rootPath in jsonDecode(rootPathStringRadarr)) {
          rootPathRadarrList.add(RootFolder.fromJson(rootPath));
        }
        dropdownValueRootFolderRadarr = rootPathRadarrList.first.path;
        _isMediaSync = true;
      }
      movieDetail = httpService.getMovieById(int.parse(movie!.theMovieDbId));
    } else {
      _isMovie = false;
      movie = null;
      serie = widget.media as Serie;
      // isMedia requested ?
      _isMediaRequested = serie!.requested;
      // Get from localStorage Radarr informations
      if (profilesSonarrString != '') {
        // Convert string to json
        for (var profile in jsonDecode(profilesSonarrString)) {
          profilesSonarrList.add(Profile.fromJson(profile));
        }
        dropdownValueProfilesSonarr = profilesSonarrList.first.name;
        _isProfileSync = true;
        // Convert string to json
        for (var rootPath in jsonDecode(rootPathStringSonarr)) {
          rootPathSonarrList.add(RootFolder.fromJson(rootPath));
        }
        dropdownValueRootFolderSonarr = rootPathSonarrList.first.path;
        _isMediaSync = true;
      }
      // Get the language from localStorage
      if (langageProfilesSonarrString != '') {
        // Convert string to json
        for (var language in jsonDecode(langageProfilesSonarrString)) {
          langageProfilesSonarrList.add(Profile.fromJson(language));
        }
        dropdownValueLanguageProfileSonarr =
            langageProfilesSonarrList.first.name;
      }
      // Get the serie detail
      serie!.id != 0 ? serieDetail = httpService.getSerieById(serie!.id) : null;
      // Create list of seasons
      serieDetail.then((value) {
        for (SeasonRequest seasonRequest in value.seasonRequests) {
          SeasonRequest season = SeasonRequest.fromJson({
            'episodes':
            seasonRequest.episodes.isEmpty
                ? []
                : seasonRequest.episodes
                .map((e) => {
              'episodeNumber':
              e.episodeNumber,
              'title': e.title,
            })
                .toList(),
            'seasonNumber':
            seasonRequest.seasonNumber,
          });
          _seasonsList.add(season);
          _seasonsListForSonarr.add(SeasonRequest.fromJson({'episodes': [], 'seasonNumber': seasonRequest.seasonNumber}));
        }
      });
    }
    super.initState();
  }

  Future _showMovieDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _isProfileSync && _isMediaSync
            ?
            // Le StatefulWidget pour le DropdownButton est nécessaire pour pouvoir utiliser le state lors du changement de valeur
            AlertDialog(
                title: const Text("Sélectionnez vos paramètres"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Select for profiles
                    StatefulBuilder(builder: (context, setState) {
                      return DropdownButton<String>(
                        isExpanded: true,
                        value: dropdownValueProfilesRadarr,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValueProfilesRadarr = newValue!;
                          });
                        },
                        items: profilesRadarrList.map((Profile profile) {
                          return DropdownMenuItem<String>(
                            value: profile.name,
                            child: Text(profile.name),
                          );
                        }).toList(),
                      );
                    }),
                    // Select for rootPath
                    StatefulBuilder(builder: (context, setState) {
                      return DropdownButton<String>(
                        isExpanded: true,
                        value: dropdownValueRootFolderRadarr,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValueRootFolderRadarr = newValue!;
                          });
                        },
                        items: rootPathRadarrList.map((RootFolder rootPath) {
                          return DropdownMenuItem<String>(
                            value: rootPath.path,
                            child: Text(rootPath.path),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
                actions: [
                  // Bouton d'annulation
                  TextButton(
                    child: const Text('Annuler',
                        style: TextStyle(color: Colors.red)),
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
                          movie!,
                          profilesRadarrList
                              .firstWhere((element) =>
                                  element.name == dropdownValueProfilesRadarr)
                              .id,
                          rootPathRadarrList
                              .firstWhere((element) =>
                                  element.path == dropdownValueRootFolderRadarr)
                              .id);
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
                        if (value["isError"] == "false" ||
                            value["isError"] == false) {
                          setState(() {
                            _isMediaRequested = true;
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
                    child: const Text('Annuler',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
      },
    );
  }

  Widget accordion(String title, SeasonRequest seasonRequest) {
    return StatefulBuilder(builder: (context, setState) {
      return Card( // Add color to border
        margin: const EdgeInsets.all(10),
        child: Column(children: [
          ListTile(
            // Only take last string from title because it's the season number
            title: Text('Saison ${title
                .split(' ')
                .last}'),
            trailing: IconButton(
              icon: Icon(
                  _showContent ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              onPressed: () {
                setState(() {
                  _showContent = !_showContent;
                });
              },
            ),
          ),
          _showContent
              ? // Wrap the content in a scrollable list that represent the list of episodes of the season
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.5,
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: seasonRequest.episodes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  // Leading is checkbox to select episode
                  leading: Checkbox(
                    onChanged: (value) {
                      setState(() {
                        // Pass to isChecked true for current episode
                        seasonRequest.episodes[index].isChecked = value!;
                        // Search in the map inside of _seasonListForSonarr to find if the episode is already in the list
                        if ( _seasonsListForSonarr.firstWhere((season) => season.seasonNumber == seasonRequest.seasonNumber).isEpisodeAvailable(seasonRequest.episodes[index])) {
                          // Remove the episode
                          _seasonsListForSonarr.firstWhere((element) => element.seasonNumber == seasonRequest.seasonNumber)
                              .removeEpisode(seasonRequest.episodes[index]);
                        } else {
                          // Add the episode
                          _seasonsListForSonarr.firstWhere((element) => element.seasonNumber == seasonRequest.seasonNumber)
                              .addEpisode(seasonRequest.episodes[index]);
                        }
                      });
                    }, value: seasonRequest.episodes[index].isChecked,
                  ),
                  title: Text(
                      'Épisode ${index + 1} :  ${seasonRequest.episodes[index]
                          .title}'),
                );
              },
            ),
          )
              : Container()
        ]),
      );
    });
  }

  Future _showSerieDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _isProfileSync && _isMediaSync
            ?
            // The stateful widget for the DropdownButton is necessary to use the state during the change of value
            SingleChildScrollView(
              child: AlertDialog(
                  title: const Text("Sélectionnez vos paramètres"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Select for profiles
                      StatefulBuilder(builder: (context, setState) {
                        return DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValueProfilesSonarr,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValueProfilesSonarr = newValue!;
                            });
                          },
                          items: profilesSonarrList.map((Profile profile) {
                            return DropdownMenuItem<String>(
                              value: profile.name,
                              child: Text(profile.name),
                            );
                          }).toList(),
                        );
                      }),
                      // Select for rootPath
                      StatefulBuilder(builder: (context, setState) {
                        return DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValueRootFolderSonarr,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValueRootFolderSonarr = newValue!;
                            });
                          },
                          items: rootPathSonarrList.map((RootFolder rootPath) {
                            return DropdownMenuItem<String>(
                              value: rootPath.path,
                              child: Text(rootPath.path),
                            );
                          }).toList(),
                        );
                      }),
                      // Select for langage
                      StatefulBuilder(builder: (context, setState) {
                        return DropdownButton<String>(
                          isExpanded: true,
                          value: dropdownValueLanguageProfileSonarr,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValueLanguageProfileSonarr = newValue!;
                            });
                          },
                          items: langageProfilesSonarrList.map((Profile profile) {
                            return DropdownMenuItem<String>(
                              value: profile.name,
                              child: Text(profile.name),
                            );
                          }).toList(),
                        );
                      }),
                      // Toggle for isAllRequested
                      Row(
                        // Spacing between the switch and the text
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Toutes les saisons'),
                          FSwitch(
                            width: 65,
                            height: 30,
                            open: _isAllRequested,
                            openColor: Colors.deepPurple,
                            onChanged: (bool value) {
                              setState(() {
                                _isAllRequested = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Switch for First season
                      Row(
                        // Spacing between the switch and the text
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Première saison ?'),
                          FSwitch(
                            width: 65,
                            height: 30,
                            open: _isFirstSeasonRequested,
                            openColor: Colors.deepPurple,
                            onChanged: (bool value) {
                              setState(() {
                                _isFirstSeasonRequested = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Switch for last season
                      Row(
                        // Spacing between the switch and the text
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Dernière saison ?'),
                          FSwitch(
                            width: 65,
                            height: 30,
                            open: _isLastSeasonRequested,
                            openColor: Colors.deepPurple,
                            onChanged: (bool value) {
                              setState(() {
                                _isLastSeasonRequested = value;
                              });
                            },
                          ),
                        ],
                      ),
                      // Acordion for each season
                      for (SeasonRequest season in _seasonsList)
                        accordion('Season ${season.seasonNumber}', season)
                    ],
                  ),
                  actions: [
                    // Bouton d'annulation
                    TextButton(
                      child: const Text('Annuler',
                          style: TextStyle(color: Colors.red)),
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
                        message = httpService.addSerie(
                            serie!,
                            profilesSonarrList
                                .firstWhere((element) =>
                                    element.name == dropdownValueProfilesSonarr)
                                .id,
                            rootPathSonarrList
                                .firstWhere((element) =>
                                    element.path == dropdownValueRootFolderSonarr)
                                .id,
                            _isAllRequested,
                            _isLastSeasonRequested,
                            _isFirstSeasonRequested,
                            langageProfilesSonarrList
                                .firstWhere((element) =>
                                    element.name ==
                                    dropdownValueLanguageProfileSonarr)
                                .id,
                            _seasonsList.map((season) => season.toSonarrJson()).toList());
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
                          if (value["isError"] == "false" ||
                              value["isError"] == false) {
                            setState(() {
                              _isMediaRequested = true;
                              _isLoading = false;
                            });
                            Navigator.of(context).pop();
                          }
                        });
                      },
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
            )
            :
            // Si le localStorage n'est pas synchronisé on affiche un message d'erreur
            AlertDialog(
                title: const Text("Profils non synchronisés"),
                content: const Text("Veuillez synchroniser vos profils"),
                actions: [
                  // Bouton d'annulation
                  TextButton(
                    child: const Text('Annuler',
                        style: TextStyle(color: Colors.red)),
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
        title: _isMovie
            ? Text("Détails du film : ${movie!.title}")
            : Text("Détails de la série : ${serie!.title}"),
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
                // Media poster
                Stack(children: [
                  // Poster blur effect behing the poster
                  Container(
                    height: MediaQuery.of(context).size.height / 1.3,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://image.tmdb.org/t/p/w500/${_isMovie ? movie!.posterPath : serie!.backdropPath}"),
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
                      child: Image.network(
                        "https://image.tmdb.org/t/p/w500/${_isMovie ? movie!.posterPath : serie!.backdropPath}",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ]),
                // Movie title
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 10),
                  child: Text(
                    _isMovie ? movie!.title : serie!.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Movie vote average rounded to 2 decimals and emojis for stars
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: _isMovie
                      ? Text(
                          movie!.voteAverage == 0
                              ? "Note IMDB : Non renseignée"
                              : "Note IMDB : ${movie!.voteAverage.toStringAsFixed(2)} / 10",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          serie!.rating == 0
                              ? "Note IMDB : Non renseignée"
                              : "Note IMDB : ${serie!.rating.toStringAsFixed(2)} / 10",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                // Movie overview
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: _isMovie
                      ? Text(
                          movie!.overview.isEmpty
                              ? "Aucun synopsis disponible pour ce film."
                              : movie!.overview,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        )
                      : Text(
                          serie!.overview.isEmpty
                              ? "Aucun synopsis disponible pour cette série."
                              : serie!.overview,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
                // List of casting actors from the movie
                _isLoading
                    ? FutureBuilder(
                        future: movieDetail,
                        builder: (BuildContext context,
                            AsyncSnapshot<MovieDetail> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            case ConnectionState.done:
                              if (snapshot.hasError) {
                                return const Center(
                                  child: Text(
                                      "Oops erreur lors de la récupération des acteurs"),
                                );
                              } else {
                                MovieDetail? movieDetailFromSnapshot =
                                    snapshot.data;
                                return Column(
                                  // Column not centered
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(
                                          top: 10, left: 10, bottom: 10),
                                      child: Text(
                                        "Genre(s) :",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Affichage de badge pour les genres du film
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Wrap(
                                        spacing: 5,
                                        runSpacing: 10,
                                        children: movieDetailFromSnapshot!
                                            .genres
                                            .map((Genre genre) {
                                          return Chip(
                                            label: Text(genre.name, style: const TextStyle(color: Colors.white)),
                                            backgroundColor: Colors.deepPurple,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(
                                          top: 20, left: 10, bottom: 10),
                                      child: Text(
                                        "Casting :",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      // Make SizedBox dynamic height to avoid overflow error
                                      // This SizedBox is for row spacing
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2.3,
                                      width: double.maxFinite,
                                      child: ListView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.all(10),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            for (Cast cast
                                                in movieDetailFromSnapshot
                                                    .getCast)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 30, top: 10),
                                                child: Column(
                                                  children: [
                                                    // Actor avatar
                                                    GFAvatar(
                                                      backgroundImage: NetworkImage(
                                                          "https://image.tmdb.org/t/p/w500/${cast.profilePath}"),
                                                      shape: GFAvatarShape
                                                          .standard,
                                                      size:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              6,
                                                    ),
                                                    // Actor name
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: Text(
                                                        cast.name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    // Character name
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
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
                                          ]),
                                    ),
                                  ],
                                );
                              }
                            default:
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                          }
                        },
                      )
                    // List of casting actors from the serie
                    : serie != null
                        ? FutureBuilder(
                            future: serieDetail,
                            builder: (BuildContext context,
                                AsyncSnapshot<SerieDetail> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                case ConnectionState.done:
                                  if (snapshot.hasError) {
                                    return const Center(
                                      child: Text(
                                          "Oops erreur lors de la récupération des acteurs"),
                                    );
                                  } else {
                                    SerieDetail? serieDetailFromSnapshot =
                                        snapshot.data;
                                    return Column(
                                      // Column not centered
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              top: 10, left: 10, bottom: 10),
                                          child: Text(
                                            "Genre(s) :",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        // Affichage de badge pour les genres du film
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Wrap(
                                            spacing: 5,
                                            runSpacing: 10,
                                            children: serieDetailFromSnapshot!
                                                .genres
                                                .map((Genre genre) {
                                              return Chip(
                                                label: Text(genre.name, style: const TextStyle(color: Colors.white)),
                                                backgroundColor:
                                                    Colors.deepPurple,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              top: 20, left: 10, bottom: 10),
                                          child: Text(
                                            "Casting :",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          // Make SizedBox dynamic height to avoid overflow error
                                          // This SizedBox is for row spacing
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2.3,
                                          width: double.maxFinite,
                                          child: ListView(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              padding: const EdgeInsets.all(10),
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              children: [
                                                for (CastSerie cast
                                                    in serieDetailFromSnapshot
                                                        .getCast)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 30, top: 10),
                                                    child: Column(
                                                      children: [
                                                        // Actor avatar
                                                        GFAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  "https://image.tmdb.org/t/p/w500/${cast.image}"),
                                                          shape: GFAvatarShape
                                                              .standard,
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              6,
                                                        ),
                                                        // Actor name
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 10),
                                                          child: Text(
                                                            cast.person,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        // Character name
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Text(
                                                            cast.character,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ]),
                                        ),
                                      ],
                                    );
                                  }
                                default:
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                              }
                            },
                          )
                        : const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Aucun casting disponible pour le moment",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                // Bouton d'ajout du film à radarr
                _isMediaRequested
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: GFButton(
                          onPressed: null,
                          textColor: Colors.white,
                          text: "Ce média est déjà dans votre liste.",
                          color: Colors.deepPurple,
                          type: GFButtonType.solid,
                          fullWidthButton: true,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: GFButton(
                          onPressed: () {
                            // Dialog pour choisir les paramètres de l'ajout
                            _isMovie ? _showMovieDialog() : _showSerieDialog();
                          },
                          text: "Demander",
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
