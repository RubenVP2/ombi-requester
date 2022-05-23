import 'package:shared_preferences/shared_preferences.dart';

///
/// Classe permettant de récupérer les données depuis le localStorage
///
class App {
  static SharedPreferences? localStorage;
  static Future init() async {
    localStorage = await SharedPreferences.getInstance();
  }
}