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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('52!Solitaire version: ${GSolitaireApp.APP_VERSION}',
                style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            const Text('Current screen dimensions'),
            Text('${MediaQuery.of(context).size.width.toStringAsFixed(0)} x ${MediaQuery.of(context).size.height.toStringAsFixed(0)}'),

          ],
        ),
      ),
    );
  }

  Widget _buildSettings(BuildContext context, Object? data) {
    final prefs = data as SharedPreferences;
    return Column(
      children: [
        Text('Games Played: ${prefs.getInt('num_games_played') ?? 0}',
            style: const TextStyle(fontSize: 20)),
        Text('Games Won: ${prefs.getInt('num_games_won') ?? 0}',
            style: const TextStyle(fontSize: 20)),
        ElevatedButton(
          onPressed: () {
            prefs.setInt('num_games_played', 0);
            prefs.setInt('num_games_won', 0);
            setState(() {});
          },
          child: const Text('Reset Counts')
        )
      ],
    );
  }
}
