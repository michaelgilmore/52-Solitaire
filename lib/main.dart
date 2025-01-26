import 'package:flutter/material.dart';
import 'game_screen.dart';

void main() {
  runApp(const GSolitaireApp());
}

class GSolitaireApp extends StatelessWidget {
  const GSolitaireApp({super.key});

  // ignore: constant_identifier_names
  static const APP_VERSION = '1.4.1';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSolitaire',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const GameScreen(), //8*10^67
    );
  }
}
