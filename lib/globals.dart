import 'package:shared_preferences/shared_preferences.dart';

///
/// Classe permettant de récupérer les données depuis le localStorage
///
class App {
  static Future<SharedPreferences> get _instance async => localStorage ?? await SharedPreferences.getInstance();
  static SharedPreferences? localStorage;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences?> init() async {
    localStorage = await _instance;
    return localStorage;
  }

  static String getString(String key, [String? defaultValue]) {
    return localStorage?.getString(key) ?? defaultValue ?? "";
  }

  static Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    return prefs.setString(key, value);
  }
}