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

  bool _isLoading = false;

  // Controller for the text field
  final textControllerApiKey = TextEditingController();
  final textControllerBaseUrl = TextEditingController();
  final textControllerUsername = TextEditingController();

  Future<void> _loadData() async {
    setState(() {
      textControllerApiKey.text = App.localStorage?.getString('apiKey') ?? '';
      textControllerBaseUrl.text = App.localStorage?.getString('baseUrl') ?? '';
      textControllerUsername.text = App.localStorage?.getString('username') ?? '';
    });
  }

  Future<void> _writeData() async {
    textControllerApiKey.text.isNotEmpty ? App.localStorage?.setString('apiKey', textControllerApiKey.text) : null;
    textControllerBaseUrl.text.isNotEmpty ? App.localStorage?.setString('baseUrl', textControllerBaseUrl.text) : null;
    textControllerUsername.text.isNotEmpty ? App.localStorage?.setString('username', textControllerUsername.text) : null;
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
        title: const Text('Settings'),
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
                  labelText: 'Base URL de l\'API',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: textControllerUsername,
                decoration: const InputDecoration(
                  labelText:  'Username utilisateur Ombi',
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
                color: Colors.purple,
                size: GFSize.LARGE,
                onPressed: () {
                  _writeData();
                  GFToast.showToast(
                    "Settings saved",
                    context,
                    toastPosition: GFToastPosition.BOTTOM,
                    toastDuration: 3,
                    backgroundColor: Colors.purple,
                    trailing: const Icon(
                      Icons.check,
                      color: Colors.black,
                    ),
                  );
                },
                text: 'Sauvegarder',
              ),
              const SizedBox(height: 30),
              // Button pour sync les profiles de radarr
              _isLoading
                  ?
              const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const CircularProgressIndicator(),
                )
                  :
              GFButton(
                color: Colors.purple,
                size: GFSize.LARGE,
                onPressed: () {
                  setState(() => _isLoading = true);
                  // Enregistrement en localStorage de la date courante pour la synchronisation formatter jj/mm/aaaa hh:mm:ss
                  App.localStorage?.setString('lastSync', DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()));
                  httpService.syncProfiles().then((value) {
                    GFToast.showToast(
                      value,
                      context,
                      toastPosition: GFToastPosition.BOTTOM,
                      toastDuration: 3,
                      backgroundColor: Colors.purple,
                      trailing: const Icon(
                        Icons.info,
                        color: Colors.black,
                      ),
                    );
                  });
                  setState(() => _isLoading = false);
                },
                text: 'Synchroniser les profiles',
              ),
              // Show last sync
              const SizedBox(height: 15),
              Text(
                App.localStorage?.getString('lastSync') == null ? '' : 'Dernière synchronisation : ${App.localStorage?.getString('lastSync')}',
                style:  const TextStyle(
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
