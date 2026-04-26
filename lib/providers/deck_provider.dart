import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:karina_app/models/deck.dart';
import 'package:karina_app/models/flashcard.dart';
import 'package:karina_app/utils/db_helper.dart';

class DeckProvider with ChangeNotifier {
  List<Deck> _decks = [];
  bool _isLoading = false;

  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;

  Future<void> loadDecks(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final deckData = await DBHelper().query('deck');
    final flashCardData = await DBHelper().query('flashcard');

    List<Deck> loadedDecks = [];
    for (var deckMap in deckData) {
      int deckId = deckMap['id'] as int;
      List<Flashcard> flashcards = flashCardData
          .where((fc) => fc['deckId'] == deckId)
          .map((fc) => Flashcard.fromMap(fc))
          .toList();

      loadedDecks.add(Deck(
        id: deckId,
        title: deckMap['title'] as String,
        flashcards: flashcards,
      ));
    }

    if (loadedDecks.isEmpty) {
      await _loadDecksJson(context);
      await loadDecks(context); // Recursive call after initial load
      return;
    }

    _decks = loadedDecks;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadDecksJson(BuildContext context) async {
    final String jsonContent = await DefaultAssetBundle.of(context)
        .loadString('assets/flashcards.json');
    final List<dynamic> jsonData = json.decode(jsonContent);

    for (final dynamic item in jsonData) {
      final String title = item['title'];
      final int deckId = await DBHelper().insert('deck', {'title': title});

      final List<dynamic> flashcardsData = item['flashcards'] as List<dynamic>;
      for (var fcData in flashcardsData) {
        Flashcard flashcard = Flashcard(
          deckId: deckId,
          category: fcData['category'] ?? 'General',
          spanish: fcData['spanish'],
          karina: fcData['karina'],
          audioPath: fcData['audioPath'],
          imagePath: fcData['imagePath'],
          exampleSentence: fcData['exampleSentence'],
          difficultyLevel: fcData['difficultyLevel'] ?? 1,
        );
        await DBHelper().insert('flashcard', flashcard.toMap());
      }
    }
  }

}
