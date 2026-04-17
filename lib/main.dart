import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/deck_provider.dart';
import 'package:karina_app/providers/game_provider.dart';
import 'views/decklist.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DeckProvider()),
        ChangeNotifierProvider(create: (context) => GameProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DeckList(),
      ),
    ),
  );
}
