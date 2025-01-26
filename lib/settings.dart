import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gsolitaire/main.dart';
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
    COLOR_AREA_CARD_BACK: Colors.black12,
    COLOR_AREA_CARD_FRONT: Colors.white38,
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
    super.initState();
    futurePrefs = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_BAR],
        title: Text('Settings', style: TextStyle(color: Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_FOREGROUND])),
      ),
      backgroundColor: Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_BACKGROUND],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/52!-logo.png', width: 50, height: 50),
                const SizedBox(width: 8),
                Text('Solitaire version: ${GSolitaireApp.APP_VERSION}',
                    style: TextStyle(fontSize: 24, color: Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_FOREGROUND])),
              ],
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
            Text('Current screen dimensions', style: TextStyle(color: Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_FOREGROUND])),
            Text('${MediaQuery.of(context).size.width.toStringAsFixed(0)} x ${MediaQuery.of(context).size.height.toStringAsFixed(0)}',
              style: TextStyle(color: Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_FOREGROUND])
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
            style: TextStyle(fontSize: 20, color: Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_FOREGROUND])),
        Text('Games Won: ${prefs.getInt('num_games_won') ?? 0}',
            style: TextStyle(fontSize: 20, color: Settings.colorMapNotifier.value[Settings.COLOR_AREA_APP_FOREGROUND])),
        ElevatedButton(
          onPressed: () {
            prefs.setInt('num_games_played', 0);
            prefs.setInt('num_games_won', 0);
            setState(() {});
          },
          child: const Text('Reset Counts')
        ),

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
                            child: Text('Choose a background color')
                        ),
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
                      builder: (BuildContext context, void Function(void Function()) setState) {
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
                                    )).toList(),
                                    onChanged: (selection) {
                                      setState(() {
                                        selectedAreaForSettingColor = selection;
                                      });
                                    }
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Visibility(
                                visible: selectedAreaForSettingColor != null,
                                child: ColorPicker(
                                  pickerColor: selectedAreaForSettingColor == null ? Colors.white
                                      : (Settings.colorMapNotifier.value[selectedAreaForSettingColor] ?? Colors.white),
                                  onColorChanged: (color) {
                                    if(selectedAreaForSettingColor == null) {
                                      return;
                                    }
                                    setState(() {
                                      // Settings.colorMap[selectedAreaForSettingColor!] = color;
                                      Settings.colorMapNotifier.value[selectedAreaForSettingColor!] = color;
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
                                child: const Text('OK')
                              )
                            ],
                          )
                        );
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
