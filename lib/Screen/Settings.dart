import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final textControllerApiKey = TextEditingController();
  final textControllerBaseUrl = TextEditingController();
  final textControllerUsername = TextEditingController();

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      textControllerApiKey.text = prefs.getString('apiKey') ?? '';
      textControllerBaseUrl.text = prefs.getString('baseUrl') ?? '';
      textControllerUsername.text = prefs.getString('username') ?? '';
    });
  }

  Future<void> _writeData() async {
    final prefs = await SharedPreferences.getInstance();
    textControllerApiKey.text.isNotEmpty ? prefs.setString('apiKey', textControllerApiKey.text) : null;
    textControllerBaseUrl.text.isNotEmpty ? prefs.setString('baseUrl', textControllerBaseUrl.text) : null;
    textControllerUsername.text.isNotEmpty ? prefs.setString('username', textControllerUsername.text) : null;
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
                'Les données déjà saisies seront écrasées, elles apparaissent quand vous sélectionnez un champ.',
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
            ],
          ),
        ),
      ),
    );
  }
}
