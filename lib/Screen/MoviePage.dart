import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertest/Screen/MovieDetailPage.dart';
import 'package:fluttertest/Service/http_service.dart';
import '../Model/movie.dart';
import 'package:getwidget/getwidget.dart';

import 'Settings.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({Key? key}) : super(key: key);

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {

  final HttpService httpService = HttpService();

  int currentNumberOfMovieLoaded = 20;

  final int amountToLoad = 20;

  late Future<List<Movie>?> futureMovies;

  String dropdownValue = 'Popular';

  static const menuItems = <String>['Popular', 'TopRated', 'Upcoming', 'Requested'];

  final List<DropdownMenuItem<String>> _dropDownMenuItems = menuItems
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Padding( padding: const EdgeInsets.only(left: 15), child: Text(value)),
        ),
      ).toList();

  @override
  initState() {
    futureMovies = httpService.getPopular(0, amountToLoad, dropdownValue);
    super.initState();
  }

  Widget customCard(Movie movie) {
    // Custom card with movie poster and title
    // On tap, open MovieDetailPage
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailPage(movie: movie),
          ),
        );
      },
      child: SizedBox(
        height: 275,
        child: Row(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Image.network("https://image.tmdb.org/t/p/w500/${movie.posterPath}"),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5) ,
                            child: Text(movie.title)
                        ),
                        subtitle: movie.overview.isEmpty ? const Text("Synopsis non renseigné.") : Text(
                          maxLines: 14,
                          movie.overview,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customDropDown() {
    return DropdownButton<String>(
      isExpanded: true,
      value: dropdownValue,
      icon: const Padding(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.filter_list_alt),
      ),
      elevation: 16,
      onChanged: (String? newValue) {
        if ( newValue != null && newValue != dropdownValue) {
          setState(() {
            dropdownValue = newValue;
            // Reset curentNumberOfMovieLoaded to default value
            currentNumberOfMovieLoaded = 20;
          });
          // Appel de la fonction qui va récupérer les films et les afficher
          futureMovies = httpService.getPopular(0, amountToLoad, dropdownValue);
        }
      },
      items: _dropDownMenuItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = AdaptiveTheme.of(context).mode.isDark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ombi Requester'),
        // Bouton à droite pour accéder à la page de configuration
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
        ),
        // Add a button to toggle theme on the AppBar
        actions: [
          IconButton(
            icon: isDarkMode ? const Icon(Icons.wb_sunny) : const Icon(Icons.brightness_3),
            onPressed: () {
                AdaptiveTheme.of(context).toggleThemeMode();
                setState(() {
                  isDarkMode = AdaptiveTheme.of(context).mode.isDark;
                });
           }),
        ],
      ),
      body: Column(
        children: [
          // Selector pour le type de recherche (Popular, Top Rated, ...)
          SizedBox(
              height: 50,
              width: double.infinity,
              child: customDropDown()
          ),
          Flexible(
            child: FutureBuilder(
                future: futureMovies,
                builder: (context, AsyncSnapshot snapshot) {
                  // If the future is null, return a progress indicator
                  if ( snapshot.hasData && snapshot.data != null ) {
                    List<Movie> movies = snapshot.data;
                    return ListView(
                      shrinkWrap: true,
                      key: const PageStorageKey('movieList'),
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                      children: [
                        for (final movie in movies) customCard(movie),
                        // Button for load more content
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: GFButton(
                            onPressed: () {
                              setState(() {
                                // Load more content when button is pressed
                                currentNumberOfMovieLoaded += amountToLoad;
                                futureMovies = httpService.getPopular(currentNumberOfMovieLoaded, amountToLoad, dropdownValue);
                              });
                            },
                            text: 'Charger plus',
                            type: GFButtonType.solid,
                            size: GFSize.LARGE,
                            color: Colors.purple,
                          ),
                        ),
                          // Si plusieurs fois le bouton a été appuyé, alors on propose de reset le nombre de film chargé pour revenir au début
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: currentNumberOfMovieLoaded != 20 ?
                            GFButton(
                              onPressed: () {
                                setState(() {
                                  currentNumberOfMovieLoaded = 20;
                                  futureMovies = httpService.getPopular(currentNumberOfMovieLoaded, amountToLoad, dropdownValue);
                                });
                              },
                              text: 'Repartir au plus populaire',
                              type: GFButtonType.solid,
                              size: GFSize.LARGE,
                              color: Colors.purple,
                            )
                                :
                            Container(),
                          ),
                      ],
                    );
                  } else if ( snapshot.hasError || snapshot.data == null ) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.error_outline, color: Colors.red, size: 60),
                        SizedBox(height: 20),
                        Text(
                              "Erreur lors du chargement des films, veuillez vérifier votre connexion internet ou l'URL de l'api.",
                              textAlign: TextAlign.center,
                          ),
                      ],
                    );
                  }
                  else {
                    return const Center(
                      child: SizedBox(
                          height: 70,
                          width: 70,
                          child: CircularProgressIndicator()
                      ),
                    );
                  }
                },
            ),
          ),
        ],
      ),
    );
  }
}