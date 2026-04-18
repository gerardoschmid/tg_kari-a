import 'package:flutter/material.dart';
import 'package:karina_app/models/flashcard.dart';

class FlashcardEditor extends StatefulWidget {
  final int deckId;
  final int flashcardId;
  final bool canBeDeleted;
  final Flashcard? flashcard;

  const FlashcardEditor({
    super.key,
    required this.canBeDeleted,
    required this.deckId,
    required this.flashcardId,
    this.flashcard,
  });
  @override
  State<FlashcardEditor> createState() => _FlashcardEditorState();
}

class _FlashcardEditorState extends State<FlashcardEditor> {
  final TextEditingController _spanishController = TextEditingController();
  final TextEditingController _karinaController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  int _difficulty = 1;

  @override
  void initState() {
    super.initState();
    if (widget.flashcard != null) {
      _spanishController.text = widget.flashcard!.spanish;
      _karinaController.text = widget.flashcard!.karina;
      _categoryController.text = widget.flashcard!.category;
      _exampleController.text = widget.flashcard!.exampleSentence ?? '';
      _difficulty = widget.flashcard!.difficultyLevel ?? 1;
    } else {
      _categoryController.text = 'General';
    }
  }

  @override
  void dispose() {
    _spanishController.dispose();
    _karinaController.dispose();
    _categoryController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  void applyChanges() async {
    Flashcard flashcard = Flashcard(
      id: widget.flashcardId == 0 ? null : widget.flashcardId,
      deckId: widget.deckId,
      category: _categoryController.text,
      spanish: _spanishController.text,
      karina: _karinaController.text,
      exampleSentence: _exampleController.text,
      difficultyLevel: _difficulty,
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void deleteFlashcard() {
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          widget.canBeDeleted ? 'Editar Tarjeta' : 'Nueva Tarjeta',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.green[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            _buildTextField(_categoryController, 'Categoría'),
            const SizedBox(height: 16),
            _buildTextField(_spanishController, 'Español'),
            const SizedBox(height: 16),
            _buildTextField(_karinaController, 'Kariña'),
            const SizedBox(height: 16),
            _buildTextField(_exampleController, 'Frase de Ejemplo', maxLines: 2),
            const SizedBox(height: 24),
            const Text('Nivel de Dificultad', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _difficulty.toDouble(),
              min: 1,
              max: 3,
              divisions: 2,
              label: _difficulty.toString(),
              onChanged: (double value) {
                setState(() {
                  _difficulty = value.toInt();
                });
              },
              activeColor: Colors.green[700],
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
                  onPressed: applyChanges,
                  child: const Text('Guardar'),
                ),
                if (widget.canBeDeleted) ...[
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: deleteFlashcard,
                    child: const Text('Eliminar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.brown),
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
    );
  }
}
