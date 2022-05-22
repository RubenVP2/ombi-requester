import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  late String _apiKey, _baseUrl, _username;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('apiKey') ?? '';
      _baseUrl = prefs.getString('baseUrl') ?? '';
      _username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _writeData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('apiKey', _apiKey);
    prefs.setString('baseUrl', _baseUrl);
    prefs.setString('username', _username);
  }


  @override
  initState() {
    _loadData();
    super.initState();
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
                controller: TextEditingController(text: _apiKey),
                onChanged: (text) {
                  setState(() {
                    _apiKey = text;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'API Key',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: TextEditingController(text: _baseUrl),
                onChanged: (text) {
                  setState(() {
                    _baseUrl = text;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Base URL de l\'API',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: TextEditingController(text: _username),
                onChanged: (text) {
                  setState(() {
                    _username = text;
                  });
                },
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
