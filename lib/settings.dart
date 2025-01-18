import 'package:flutter/material.dart';
import 'package:gsolitaire/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  late final futurePrefs;

  @override
  initState() {
    super.initState();
    futurePrefs = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(GSolitaireApp.APP_VERSION),
          const Text(
            'Settings - coming soon',
            style: TextStyle(fontSize: 24),
          ),
          FutureBuilder(
            future: futurePrefs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _buildSettings(context, snapshot.data);
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          Text('${MediaQuery.of(context).size.width.toStringAsFixed(0)} x ${MediaQuery.of(context).size.height.toStringAsFixed(0)}'),

        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context, Object? data) {
    final prefs = data as SharedPreferences;
    return Column(
      children: [
        Text('Games Played: ${prefs.getInt('num_games_played') ?? 0}'),
        Text('Games Won: ${prefs.getInt('num_games_won') ?? 0}'),
      ],
    );
  }
}
