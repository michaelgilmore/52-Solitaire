import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gsolitaire/game_screen.dart';
import 'package:gsolitaire/main.dart';
import 'package:gsolitaire/playing_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  static String COLOR_AREA_APP_BACKGROUND = 'App Background';
  static String COLOR_AREA_APP_FOREGROUND = 'App Foreground';
  static String COLOR_AREA_APP_BAR = 'App Bar';
  static String COLOR_AREA_BOTTOM_NAV = 'Bottom Nav';
  static String COLOR_AREA_CARD_BACK = 'Card Back';
  static String COLOR_AREA_CARD_FRONT = 'Card Front';

  static ValueNotifier<Map<String, Color>> colorMapNotifier = ValueNotifier({
    COLOR_AREA_APP_BACKGROUND: Colors.white10,
    COLOR_AREA_APP_FOREGROUND: Colors.white,
    COLOR_AREA_APP_BAR: Colors.white12,
    COLOR_AREA_BOTTOM_NAV: Colors.white12,
    COLOR_AREA_CARD_BACK: Colors.grey[600]!,
    COLOR_AREA_CARD_FRONT: Colors.grey[350]!,
  });

  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late final futurePrefs;
  String? selectedAreaForSettingColor;

  @override
  initState() {
    // print('Settings initState()');
    super.initState();
    futurePrefs = SharedPreferences.getInstance().then((prefs) {
      if (GameScreen.weatherKeyController.text.isEmpty) {
        GameScreen.weatherKeyController.text =
            prefs.getString('weatherKey') ?? '';
        // print('weatherKey: ${GameScreen.weatherKeyController.text}');
      }
      if (GameScreen.latitudeController.text.isEmpty) {
        GameScreen.latitudeController.text = prefs.getString('lat') ?? '';
        // print('lat: ${GameScreen.latitudeController.text}');
      }
      if (GameScreen.longitudeController.text.isEmpty) {
        GameScreen.longitudeController.text = prefs.getString('long') ?? '';
        // print('long: ${GameScreen.longitudeController.text}');
      }
      return prefs;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController tmpController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_BAR],
        foregroundColor:
            Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_FOREGROUND],
        title: const Text('Settings'),
      ),
      backgroundColor:
          Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_BACKGROUND],
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/52!-logo.png',
                      width: 50, height: 50),
                  const SizedBox(width: 8),
                  Text('Solitaire version: ${GSolitaireApp.APP_VERSION}',
                      style: TextStyle(
                          fontSize: 24,
                          color: Settings.colorMapNotifier
                              .value[Settings.COLOR_AREA_APP_FOREGROUND])),
                ],
              ),
            ),
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
            Text('Current screen dimensions',
                style: TextStyle(
                    color: Settings.colorMapNotifier
                        .value[Settings.COLOR_AREA_APP_FOREGROUND])),
            Text(
                '${MediaQuery.of(context).size.width.toStringAsFixed(0)} x ${MediaQuery.of(context).size.height.toStringAsFixed(0)}',
                style: TextStyle(
                    color: Settings.colorMapNotifier
                        .value[Settings.COLOR_AREA_APP_FOREGROUND])),

            //Add field for weather API key that is saved in shared preferences
            const SizedBox(height: 20),
            Text('Weather API Key',
                style: TextStyle(
                    color: Settings.colorMapNotifier
                        .value[Settings.COLOR_AREA_APP_FOREGROUND])),

            //Weather key
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 250,
                    child: TextField(
                      controller: GameScreen.weatherKeyController,
                      decoration: const InputDecoration(
                        hintText: 'API key',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    )),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () async {
                      var prefs = await SharedPreferences.getInstance();
                      prefs.setString(
                          'weatherKey', GameScreen.weatherKeyController.text);
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('API Key Saved'),
                              content:
                                  const Text('The API key has been saved.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          });
                    },
                    child: const Text('Save')),
              ],
            ),

            const SizedBox(height: 10),
            Text('Location',
                style: TextStyle(
                    color: Settings.colorMapNotifier
                        .value[Settings.COLOR_AREA_APP_FOREGROUND])),
            //Location text boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 70,
                    child: TextField(
                      controller: GameScreen.latitudeController,
                      decoration: const InputDecoration(
                        hintText: 'Latitude',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    )),
                const SizedBox(width: 10),
                SizedBox(
                    width: 70,
                    child: TextField(
                      controller: GameScreen.longitudeController,
                      decoration: const InputDecoration(
                        hintText: 'Longitude',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    )),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () async {
                      var prefs = await SharedPreferences.getInstance();
                      prefs.setString(
                          'lat', GameScreen.latitudeController.text);
                      prefs.setString(
                          'long', GameScreen.longitudeController.text);
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Location Saved'),
                              content:
                                  const Text('The location has been saved.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          });
                    },
                    child: const Text('Save')),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(GameScreen.savedDeck.map((card) => '${card.value}${card.suit}').join(',')),
            //Add a textfield and a button. When the button is pressed take the textfield contents and write to savedGame and then call replay game using savedGame.
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(controller: tmpController)
                ),
                ElevatedButton(onPressed: () {
                  //Parse string of values and suits into savedGame list
                  List<String> cardStrings = tmpController.text.split(',');
                  GameScreen.savedDeck.clear();
                  for(String cardString in cardStrings) {
                    //Split cardString in value and suit
                    String value = cardString.substring(0, cardString.length - 1);
                    String suit = cardString.substring(cardString.length - 1);
                    GameScreen.savedDeck.add(PlayingCard(value, suit, false));
                  }

                }, child: const Text('Save this game'))
              ],
            ),
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
            style: TextStyle(
                fontSize: 20,
                color: Settings.colorMapNotifier
                    .value[Settings.COLOR_AREA_APP_FOREGROUND])),
        Text('Games Won: ${prefs.getInt('num_games_won') ?? 0}',
            style: TextStyle(
                fontSize: 20,
                color: Settings.colorMapNotifier
                    .value[Settings.COLOR_AREA_APP_FOREGROUND])),
        ElevatedButton(
            onPressed: () {
              prefs.setInt('num_games_played', 0);
              prefs.setInt('num_games_won', 0);
              setState(() {});
            },
            child: const Text('Reset Counts')),

        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 10),

        //Add color chooser button for background
        ElevatedButton(
          onPressed: () {
            setState(() {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                            width: 180,
                            child: Text('Choose a background color')),
                        //Add an X button for closing this popup
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    content: StatefulBuilder(
                      builder: (BuildContext context,
                          void Function(void Function()) setState) {
                        return SingleChildScrollView(
                            child: Column(
                          children: [
                            Row(
                              children: [
                                const Text('Area:'),
                                const SizedBox(width: 12),
                                DropdownButton<String>(
                                    value: selectedAreaForSettingColor,
                                    hint: const Text('[Select]'),
                                    items: Settings.colorMapNotifier.value.keys
                                        .map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ))
                                        .toList(),
                                    onChanged: (selection) {
                                      setState(() {
                                        selectedAreaForSettingColor = selection;
                                      });
                                    }),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Visibility(
                              visible: selectedAreaForSettingColor != null,
                              child: ColorPicker(
                                pickerColor: selectedAreaForSettingColor == null
                                    ? Colors.white
                                    : (Settings.colorMapNotifier.value[
                                            selectedAreaForSettingColor] ??
                                        Colors.white),
                                onColorChanged: (color) {
                                  if (selectedAreaForSettingColor == null) {
                                    return;
                                  }
                                  setState(() {
                                    // Settings.colorMap[selectedAreaForSettingColor!] = color;
                                    Settings.colorMapNotifier.value[
                                        selectedAreaForSettingColor!] = color;
                                  });
                                  Settings.colorMapNotifier.notifyListeners();
                                },
                                pickerAreaHeightPercent: 0.8,
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'))
                          ],
                        ));
                      },
                    ),
                  );
                },
              );
            });
          },
          child: const Text('Choose Background Color'),
        ),
      ],
    );
  }
}
