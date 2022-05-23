import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/movie.dart';
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

  bool _isMovieRequested = false;

  late Future<Map> message;

  bool _isLoading = false;

  @override
  initState() {
    // On Récupère tous les films demandés par l'utilisateur pour savoir si le film est déjà dans la liste on affiche pas le bouton d'ajout
    httpService.getAllMoviesRequested().then((value) {
      setState(() {
        _isMovieRequested = value.any((element) => element.theMovieDbId == widget.movie.theMovieDbId);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détail du film : ${widget.movie.title}"),
      ),
      // Scrollable content
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: _isLoading ? const Padding(
          padding: EdgeInsets.only(top: 100),
          child: Center(
            child: GFLoader(
              size: GFSize.LARGE,
            ),
          ),
        ) :
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie poster
            Center(
              child: Container(
                height: 500,
                padding: const EdgeInsets.all(8),
                child: Image.network("https://image.tmdb.org/t/p/w500/${widget.movie.posterPath}"),
              ),
            ),
            // Movie title
            Padding(
              padding: const EdgeInsets.all(8),
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
              padding: const EdgeInsets.all(8),
              child: Text(
                widget.movie.voteAverage != 0 ?
                "Note IMDB : ${widget.movie.voteAverage.toStringAsFixed(2)} / 10"
                : "Note IMDB : Non renseignée",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Movie overview
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                widget.movie.overview,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            // Bouton d'ajout du film à radarr
            _isMovieRequested
                ?
            const Padding(
              padding: EdgeInsets.all(8),
              child: GFButton(
                onPressed: null,
                text: "Ce film est déjà dans la liste",
                color: Colors.purple,
                type: GFButtonType.solid,
                fullWidthButton: true,
              ),
            )
                :
            Padding(
              padding: const EdgeInsets.all(8),
              child: GFButton(
                onPressed: () {
                  // Activation du loading
                  setState(() {
                    _isLoading = true;
                  });
                  // On ajoute le film à la liste des films demandés
                  message = httpService.addMovie(widget.movie);
                  message.then((value) {
                    // Apparition de la notification
                    GFToast.showToast(
                      value["message"],
                      context,
                      toastPosition: GFToastPosition.BOTTOM,
                      toastDuration: 3,
                      backgroundColor: Colors.purple,
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
                    }
                  });
                },
                text: "Ajouter à Radarr",
                color: Colors.purple,
                fullWidthButton: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
