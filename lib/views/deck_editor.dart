import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/providers/deck_provider.dart';

class DeckEditor extends StatefulWidget {
  const DeckEditor({
    super.key,
    required this.deckIndex,
    required this.deckTitle,
    required this.isBeingCreated,
  });

  final int deckIndex;
  final String deckTitle;
  final bool isBeingCreated;

  @override
  State<DeckEditor> createState() => _DeckEditorState();
}

class _DeckEditorState extends State<DeckEditor> {
  final TextEditingController _deckNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!widget.isBeingCreated) {
      _deckNameController.text = widget.deckTitle;
    }
  }

  Future<void> createOrUpdateDeck() async {
    final String newDeckTitle = _deckNameController.text;
    final deckProvider = Provider.of<DeckProvider>(context, listen: false);

    if (widget.isBeingCreated) {
      await deckProvider.addDeck(newDeckTitle);
    } else {
      await deckProvider.updateDeck(widget.deckIndex, newDeckTitle);
    }
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> deleteDeck() async {
    final deckProvider = Provider.of<DeckProvider>(context, listen: false);
    await deckProvider.deleteDeck(widget.deckIndex);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = !widget.isBeingCreated;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          isEditing ? 'Editar Mazo' : 'Nuevo Mazo',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.green[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _deckNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Mazo',
                  labelStyle: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: createOrUpdateDeck,
                    child: const Text('Guardar'),
                  ),
                  if (isEditing) ...[
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: deleteDeck,
                      child: const Text('Eliminar'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
