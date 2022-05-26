import 'package:flutter/material.dart';
import 'package:fluttertest/Screen/MoviePage.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import './globals.dart';

void main() {
  start();
  runApp(const MyApp());
}

// Cette méthode charge les données en localStorage de l'application
Future start() async {
  await App.init();
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
        title: 'Récupération API',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: const MoviePage(),
        ),
    );
  }
}
