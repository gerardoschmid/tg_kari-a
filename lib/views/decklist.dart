import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/models/deck.dart';
import 'package:karina_app/providers/deck_provider.dart';
import 'package:karina_app/views/flashcard_list.dart';

class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeckProvider>(context, listen: false).loadDecks(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: const Text(
          'Kariña Learning',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.green[50],
      body: Consumer<DeckProvider>(
        builder: (context, deckProvider, child) {
          if (deckProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final localDecks = deckProvider.decks;

          if (localDecks.isEmpty) {
            return const Center(child: Text('No hay mazos disponibles.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: localDecks.length,
            itemBuilder: (context, index) {
              final deck = localDecks[index];
              return _buildDeckCard(deck);
            },
          );
        },
      ),
    );
  }

  Widget _buildDeckCard(Deck deck) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardList(
                deckId: deck.id ?? 0,
                deckTitle: deck.title,
              ),
            ),
          );
          if (mounted) {
            Provider.of<DeckProvider>(context, listen: false).loadDecks(context);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 50, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              deck.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${deck.flashcards.length} tarjetas',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
