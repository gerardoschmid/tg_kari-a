import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karina_app/models/deck.dart';
import 'package:karina_app/models/flashcard.dart';
import 'package:karina_app/utils/db_helper.dart';

class DeckProvider with ChangeNotifier {
  List<Deck> _decks = [];
  bool _isLoading = false;

  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;

  // OPTIMIZADO: Método de inicialización sin dependencia de BuildContext
  Future<void> initializeProvider() async {
    await loadDecks();
  }

  Future<void> loadDecks() async {
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
      // OPTIMIZADO: Si la DB está vacía, repoblar automáticamente desde JSON
      await _loadDecksFromJson();
      await loadDecks(); // Recarga después de insertar
      return;
    }

    _decks = loadedDecks;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadDecksFromJson() async {
    try {
      // OPTIMIZADO: Uso de rootBundle para evitar error de BuildContext en el arranque
      final String jsonContent = await rootBundle.loadString('assets/flashcards.json');
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
    } catch (e) {
      debugPrint('Error crítico al poblar la base de datos desde JSON: $e');
    }
  }
}
