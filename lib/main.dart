import 'package:flutter/material.dart';
import 'game_screen.dart';

void main() {
  runApp(const GSolitaireApp());
}

class GSolitaireApp extends StatelessWidget {
  const GSolitaireApp({super.key});

  static const APP_VERSION = '1.1';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSolitaire',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const GameScreen(title: '52! Solitaire'), //8*10^67
    );
  }
}
