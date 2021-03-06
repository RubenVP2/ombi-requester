import 'package:flutter/material.dart';
import 'package:fluttertest/Service/http_service.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import '../globals.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  HttpService httpService = HttpService();

  // Controller for the text field
  final textControllerApiKey = TextEditingController();
  final textControllerBaseUrl = TextEditingController();
  final textControllerUsername = TextEditingController();

  Future<void> _loadData() async {
    setState(() {
      textControllerApiKey.text = App.getString("apiKey");
      textControllerBaseUrl.text = App.getString("baseUrl");
      textControllerUsername.text = App.getString("username");
    });
  }

  Future<void> _writeData() async {
    // Manage baseUrl, i don't want to have a trailing slash
    String baseUrl = textControllerBaseUrl.text;
    if (baseUrl.endsWith("/")) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      // Update the text field
      textControllerBaseUrl.text = baseUrl;
    }
    App.setString('apiKey', textControllerApiKey.text.toString());
    App.setString('baseUrl', textControllerBaseUrl.text.toString());
    App.setString('username', textControllerUsername.text.toString());
  }

  @override
  initState() {
    _loadData();
    super.initState();
  }

  @override
  dispose() {
    textControllerApiKey.dispose();
    textControllerBaseUrl.dispose();
    textControllerUsername.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        // Personalized back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Navigate back to the first screen and force a rebuild
            Navigator.of(context).pushNamed('/');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: textControllerApiKey,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: textControllerBaseUrl,
                decoration: const InputDecoration(
                  labelText: 'Url de l\'API',
                  helperText: 'Exemple : http(s)://domaine.com/api',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: textControllerUsername,
                decoration: const InputDecoration(
                  labelText:  'Pseudo utilisateur Ombi',
                )
              ),
              // Information
              const SizedBox(height: 15),
              const Text(
                'Les données déjà saisies seront écrasées.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              // Button to save settings
              GFButton(
                color: Colors.deepPurple,
                size: GFSize.LARGE,
                onPressed: () {
                  _writeData();
                  GFToast.showToast(
                    "Les paramètres ont été sauvegardés.",
                    context,
                    toastPosition: GFToastPosition.BOTTOM,
                    toastDuration: 3,
                    backgroundColor: Colors.deepPurple,
                    trailing: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  );
                },
                text: 'Sauvegarder',
              ),
              const SizedBox(height: 30),
              // Button pour sync les profiles de radarr
              GFButton(
                color: Colors.deepPurple,
                size: GFSize.LARGE,
                onPressed: () {
                  if ( textControllerBaseUrl.text == '' || textControllerApiKey.text == '' || textControllerUsername.text == '' ) {
                    GFToast.showToast(
                      "Veuillez remplir tous les champs",
                      context,
                      toastPosition: GFToastPosition.BOTTOM,
                      toastDuration: 3,
                      backgroundColor: Colors.deepPurple,
                      trailing: const Icon(
                        Icons.error,
                        color: Colors.white,
                      ),
                    );
                  } else {
                    // Enregistrement en localStorage de la date courante pour la synchronisation formatter jj/mm/aaaa hh:mm:ss
                    App.setString('lastSync', DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()));
                    httpService.syncProfiles().then((profileResponse) {
                      httpService.syncRootPath().then((rootPathResponse) =>
                          GFToast.showToast(
                            "$rootPathResponse\n$profileResponse",
                            context,
                            toastPosition: GFToastPosition.BOTTOM,
                            toastDuration: 3,
                            backgroundColor: Colors.deepPurple,
                            trailing: const Icon(
                              Icons.info,
                              color: Colors.white,
                            ),
                          )
                      );
                    });
                  }
                },
                text: 'Synchroniser les profils et répertoires',
              ),
              // Show last sync
              const SizedBox(height: 15),
              Text(
                App.getString('lastSync') == '' ? '' : 'Dernière synchronisation le : ${App.getString('lastSync')}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
