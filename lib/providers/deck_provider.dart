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

<<<<<<< HEAD
  /// Carga los mazos desde la DB local e inicia la sincronización remota.
  Future<void> loadDecks(BuildContext context) async {
    if (_isLoading) return; // evita llamadas concurrentes
=======
  /// Carga los mazos desde la DB.
  /// [context] solo se usa para cargar el JSON inicial; se captura antes
  /// de cualquier await para evitar el uso de BuildContext en async gaps.
  Future<void> loadDecks(BuildContext context) async {
    if (_isLoading) return; // BUG FIX: evita llamadas concurrentes
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final deckData = await DBHelper().query('deck');
      final flashCardData = await DBHelper().query('flashcard');

      if (deckData.isEmpty) {
<<<<<<< HEAD
        final bundle = DefaultAssetBundle.of(context);
        await _loadDecksFromJson(bundle);

=======
        // BUG FIX: capturamos el bundle ANTES del primer await de escritura
        // para no usar context después de un gap asíncrono.
        final bundle = DefaultAssetBundle.of(context);
        await _loadDecksFromJson(bundle);

        // Segunda lectura — sin recursión
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
        final freshDeckData = await DBHelper().query('deck');
        final freshFlashcardData = await DBHelper().query('flashcard');
        _decks = _buildDecks(freshDeckData, freshFlashcardData);
      } else {
        _decks = _buildDecks(deckData, flashCardData);
      }
<<<<<<< HEAD
      
      // Sincronización en segundo plano
      _triggerBackgroundSync();
=======
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
    } catch (e, stack) {
      debugPrint('DeckProvider.loadDecks error: $e\n$stack');
      _error = 'No se pudieron cargar los mazos. Intenta de nuevo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

<<<<<<< HEAD
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

=======
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
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
