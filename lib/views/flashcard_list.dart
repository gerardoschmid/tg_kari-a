import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/providers/deck_provider.dart';
import 'package:karina_app/views/karina_card.dart';
import 'package:karina_app/views/quiz.dart';

class FlashcardList extends StatefulWidget {
  final int deckId;
  final String deckTitle;

  const FlashcardList({
    super.key,
    required this.deckId,
    required this.deckTitle,
  });

  @override
  State<FlashcardList> createState() => _FlashcardListState();
}

class _FlashcardListState extends State<FlashcardList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          widget.deckTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded, size: 30),
            onPressed: () async {
              final deckProvider = Provider.of<DeckProvider>(context, listen: false);
              final deck = deckProvider.decks.firstWhere((d) => d.id == widget.deckId);
              if (deck.flashcards.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No hay tarjetas para practicar.')),
                );
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(
                    deckTitle: widget.deckTitle,
                    deckId: widget.deckId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.green[50],
      body: Consumer<DeckProvider>(
        builder: (context, deckProvider, child) {
          final deck = deckProvider.decks.firstWhere(
            (d) => d.id == widget.deckId,
            orElse: () => throw Exception('Deck not found'),
          );
          final flashcards = deck.flashcards;

          if (flashcards.isEmpty) {
            return const Center(child: Text('Agrega algunas tarjetas para comenzar.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = flashcards[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: KarinaCard(
                  flashcard: flashcard,
                  onTap: () {
                    // Just show the card or do nothing
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
