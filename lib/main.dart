import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/deck_provider.dart';
import 'views/decklist.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DeckProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DeckList(),
      ),
    ),
  );
}
