import 'package:flutter/material.dart';
import 'package:fluttertest/Screen/MovieDetailPage.dart';
import 'package:fluttertest/Screen/MoviePage.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import './globals.dart';
import 'Model/movie.dart';
import 'Screen/Settings.dart';

void main() async {
  // You only need to call this method if you need the binding to be initialized before calling
  WidgetsFlutterBinding.ensureInitialized();
  await App.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(

      light: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (context) => const MoviePage(),
              );
            case '/settings':
              return MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              );
            case '/movieDetail':
              return MaterialPageRoute(
                builder: (context) => MovieDetailPage(
                  movie: settings.arguments as Movie,
                ),
              );
          }
          // The code only supports
          // PassArgumentsScreen.routeName right now.
          // Other values need to be implemented if we
          // add them. The assertion here will help remind
          // us of that higher up in the call stack, since
          // this assertion would otherwise fire somewhere
          // in the framework.
          assert(false, 'Invalid route: ${settings.name}');
          return null;
        },
        initialRoute: '/',
        title: 'Ombi Requester',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        ),
    );
  }
}
