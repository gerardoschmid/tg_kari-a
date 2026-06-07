import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/providers/deck_provider.dart';
import 'package:karina_app/models/deck.dart';
import 'package:karina_app/views/karina_card.dart';
import 'package:karina_app/views/color_card.dart';
import 'package:karina_app/views/quiz.dart';

class FlashcardList extends StatelessWidget {
  final int deckId;
  final String deckTitle;

  const FlashcardList({
    super.key,
    required this.deckId,
    required this.deckTitle,
  });

  bool get _isColorsUnit => deckTitle.toLowerCase().contains('colores');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          deckTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded, size: 30),
            onPressed: () => _startQuiz(context),
          ),
        ],
      ),
      backgroundColor: Colors.green[50],
      body: Consumer<DeckProvider>(
        builder: (context, deckProvider, child) {
          // BUG FIX: orElse devuelve null en lugar de lanzar excepción,
          // lo que crasheaba en hot-reload y re-navegación.
          final Deck? deck = deckProvider.decks.where((d) => d.id == deckId).firstOrNull;

          if (deck == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (deck.flashcards.isEmpty) {
            return const Center(
              child: Text('Agrega algunas tarjetas para comenzar.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: _isColorsUnit ? 0.8 : 2.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: deck.flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = deck.flashcards[index];
              if (_isColorsUnit || flashcard.category == 'Colores') {
                return ColorCard(flashcard: flashcard, onTap: () {});
              }
              return KarinaCard(flashcard: flashcard, onTap: () {});
            },
          );
        },
      ),
    );
  }

  void _startQuiz(BuildContext context) {
    final deckProvider = Provider.of<DeckProvider>(context, listen: false);
    final deck = deckProvider.decks.where((d) => d.id == deckId).firstOrNull;

    if (deck == null || deck.flashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay tarjetas para practicar.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          deckTitle: deckTitle,
          deckId: deckId,
        ),
      ),
    );
  }
}
