import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertest/Screen/MovieDetailPage.dart';
import 'package:fluttertest/Service/http_service.dart';
import '../Model/movie.dart';
import 'package:getwidget/getwidget.dart';
import 'package:fswitch_nullsafety/fswitch_nullsafety.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({Key? key}) : super(key: key);

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {

  final HttpService httpService = HttpService();

  int currentMediaLoaded = 20;

  final int amountToLoad = 20;

  // List of movies to display
  late Future<List<Movie>?> futureMovies;

  String dropdownValue = 'Popular';

  static const String errorMessage = "Erreur lors du chargement, veuillez vérifier votre connexion internet ou les paramètres de l'api.";

  // La map contient en key la valeur française et en value la valeur anglaise
  static const Map<String, String> dropdownItemsMap = {
    'Les plus populaires': 'Popular',
    'Les mieux notés': 'TopRated',
    'A venir': 'Upcoming',
    'Demandé': 'Requested',
  };

  final List<DropdownMenuItem<String>> _dropDownMenuItems =
    dropdownItemsMap.keys.map((String key) {
      return DropdownMenuItem<String>(
        value: dropdownItemsMap[key],
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(key),
        ),
      );
    }).toList();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    futureMovies = httpService.getMovies(0, amountToLoad, dropdownValue);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildBadge(Movie movie) {
    // Movie is available ?
    if ( movie.available) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
        ),
        child: const Text(
          'Disponible',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );
    } else if ( movie.approved ) {
      // Movie is approved ?
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
        ),
        child: const Text(
          'Approuvé',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );
    } else if ( movie.denied ) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
        ),
        child: const Text(
          'Refusé',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );
    } else {
      // The movie is not available and not approved so it's requested maybe ?
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
        ),
        child: const Text(
          'Demandé',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );
    }
  }

  Widget customCard(Movie movie) {
    // Custom card with movie poster and title
    // On tap, open MovieDetailPage
    return GestureDetector(
      onTap: () {
        // Navigate to the screen named "MovieDetailPage" that show the movie detail
        Navigator.pushNamed(context,
          MovieDetailPage.routeName,
          arguments: movie,
        );
      },
      child: Card(
        child: SizedBox(
          height: 275,
          child: Row(
            children: [
              Container(
                width: 200,
                height: 450,
                padding: const EdgeInsets.all(8),
                child: Stack(
                  // This stack is used to display the poster and a badge if the movie is already requested
                  children: [
                    // Poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Switch the status of the movie we display the badge ( requested / available / approved )
                    if (movie.requested)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _buildBadge(movie),
                      ),
                  ],
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
                              child: Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                          subtitle: movie.overview.isEmpty ? const Text("Synopsis non renseigné.") : Text(
                            maxLines: 12,
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
      onChanged: (String? newValue) {
        if ( newValue != null && newValue != dropdownValue) {
          setState(() {
            dropdownValue = newValue;
            // Reset curentNumberOfMovieLoaded to default value
            currentMediaLoaded = 20;
          });
          // Appel de la fonction qui va récupérer les films et les afficher
          futureMovies = httpService.getMovies(0, amountToLoad, dropdownValue);
        }
      },
      items: _dropDownMenuItems,
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 600),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = AdaptiveTheme.of(context).mode.isDark;
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Ombi Requester')),
        // Bouton à droite pour accéder à la page de configuration
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
        // Add a button to toggle theme on the AppBar
        actions: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: FSwitch(
              open: isDarkMode,
              color: Colors.black87,
              openColor: Colors.white70,
              onChanged: (value) {
                if (value) {
                  AdaptiveTheme.of(context).setDark();
                } else {
                  AdaptiveTheme.of(context).setLight();
                }
              },
              closeChild: const Icon(Icons.sunny, size: 16, color: Colors.white,),
              // reverse icon for dark mode
              openChild: Transform.scale(
                scaleX: -1,
                child: const Icon(
                  Icons.brightness_3_sharp,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          )
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
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.done:
                      // Gestion de l'erreur
                      if (snapshot.hasError) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.error_outline, color: Colors.red, size: 60),
                            SizedBox(height: 20),
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      } else {
                        // Cas passant
                        if ( snapshot.data != null ) {
                          List<Movie> movies = snapshot.data;
                          return ListView(
                            shrinkWrap: true,
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                            children: [
                              for (Movie movie in movies)
                                customCard(movie),
                              // Button for load more content
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: GFButton(
                                  onPressed: () {
                                    setState(() {
                                      // Load more content when button is pressed
                                      currentMediaLoaded += amountToLoad;
                                      futureMovies = httpService.getMovies(currentMediaLoaded, amountToLoad, dropdownValue);
                                    });
                                  },
                                  text: 'Charger plus',
                                  type: GFButtonType.solid,
                                  size: GFSize.LARGE,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              // Si plusieurs fois le bouton a été appuyé, alors on propose de reset le nombre de film chargé pour revenir au début
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: currentMediaLoaded == 20 ? Container() :
                                GFButton(
                                  onPressed: () {
                                    setState(() {
                                      currentMediaLoaded = 20;
                                      futureMovies = httpService.getMovies(currentMediaLoaded, amountToLoad, dropdownValue);
                                    });
                                  },
                                  text: 'Repartir au début de la recherche',
                                  type: GFButtonType.solid,
                                  size: GFSize.LARGE,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              // If we are at the end of the page, we display a deepPurple floating action button to scroll to the top
                              if ( MediaQuery.of(context).viewInsets.bottom == 0 )
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.deepPurple,
                                    onPressed: _scrollToTop,
                                    child: const Icon(Icons.arrow_upward),
                                  ),
                                ),
                            ],
                          );
                        } else {
                          return const Center(
                            child: Text(errorMessage),
                          );
                        }
                      }
                    default:
                      return const Center(child: CircularProgressIndicator());
                  }
                },
            ),
          ),
        ],
      ),
    );
  }
}
