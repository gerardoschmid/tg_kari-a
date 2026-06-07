import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:karina_app/models/deck.dart';
import 'package:karina_app/models/flashcard.dart';
import 'package:karina_app/utils/db_helper.dart';
import 'package:karina_app/utils/sync_service.dart';

class DeckProvider with ChangeNotifier {
  List<Deck> _decks = [];
  bool _isLoading = false;
  String? _error;

  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga los mazos desde la DB local e inicia la sincronización remota.
  Future<void> loadDecks(BuildContext context) async {
    if (_isLoading) return; // evita llamadas concurrentes

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final deckData = await DBHelper().query('deck');
      final flashCardData = await DBHelper().query('flashcard');

      if (deckData.isEmpty) {
        final bundle = DefaultAssetBundle.of(context);
        await _loadDecksFromJson(bundle);

        final deckDataAfterLoad = await DBHelper().query('deck');
        final flashCardDataAfterLoad = await DBHelper().query('flashcard');
        _decks = _buildDecks(deckDataAfterLoad, flashCardDataAfterLoad);
      } else {
        _decks = _buildDecks(deckData, flashCardData);
      }
      
      // Sincronización en segundo plano
      _triggerBackgroundSync();
    } catch (e, stack) {
      debugPrint('DeckProvider.loadDecks error: $e\n$stack');
      _error = 'No se pudieron cargar los mazos. Intenta de nuevo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _triggerBackgroundSync() {
    SyncService().syncDecksAndFlashcards().then((_) async {
      final freshDeckData = await DBHelper().query('deck');
      final freshFlashcardData = await DBHelper().query('flashcard');
      _decks = _buildDecks(freshDeckData, freshFlashcardData);
      notifyListeners();
    }).catchError((err) {
      debugPrint("DeckProvider background sync error: $err");
    });
  }

  List<Deck> _buildDecks(
    List<Map<String, dynamic>> deckData,
    List<Map<String, dynamic>> flashCardData,
  ) {
    return deckData.map((deckMap) {
      final int deckId = deckMap['id'] as int;
      final flashcards = flashCardData
          .where((fc) => fc['deckId'] == deckId)
          .map((fc) => Flashcard.fromMap(fc))
          .toList();
      return Deck(
        id: deckId,
        title: deckMap['title'] as String,
        flashcards: flashcards,
      );
    }).toList();
  }

  Future<void> _loadDecksFromJson(AssetBundle bundle) async {
    final String jsonContent =
        await bundle.loadString('assets/flashcards.json');
    final List<dynamic> jsonData = json.decode(jsonContent) as List<dynamic>;

    for (final dynamic item in jsonData) {
      final String title = item['title'] as String;
      final int deckId =
          await DBHelper().insert('deck', {'title': title});

      final List<dynamic> flashcardsData =
          item['flashcards'] as List<dynamic>;
      for (final fcData in flashcardsData) {
        final flashcard = Flashcard(
          deckId: deckId,
          category: fcData['category'] as String? ?? 'General',
          spanish: fcData['spanish'] as String? ?? '',
          karina: fcData['karina'] as String? ?? '',
          audioPath: fcData['audioPath'] as String?,
          imagePath: fcData['imagePath'] as String?,
          exampleSentence: fcData['exampleSentence'] as String?,
          difficultyLevel: (fcData['difficultyLevel'] as num?)?.toInt() ?? 1,
        );
        await DBHelper().insert('flashcard', flashcard.toMap());
      }
    }
  }
}
