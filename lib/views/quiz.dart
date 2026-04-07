import 'dart:math';
import 'package:flutter/material.dart';
import 'package:karina_app/models/flashcard.dart';
import 'package:karina_app/utils/db_helper.dart';

class QuizPage extends StatefulWidget {
  final String deckTitle;
  final int deckId;

  const QuizPage({
    super.key,
    required this.deckTitle,
    required this.deckId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<Flashcard>> _flashcardsFuture;
  List<Flashcard> allFlashcards = [];
  int currentQuestionIndex = 0;
  int score = 0;
  List<String> currentOptions = [];
  bool hasAnswered = false;
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    _flashcardsFuture = _loadFlashcards();
  }

  Future<List<Flashcard>> _loadFlashcards() async {
    final List<Map<String, dynamic>> maps = await DBHelper().query(
      'flashcard',
      where: 'deckId = ?',
      whereArgs: [widget.deckId],
    );
    allFlashcards = maps.map((e) => Flashcard.fromMap(e)).toList();
    allFlashcards.shuffle();
    _generateOptions();
    return allFlashcards;
  }

  void _generateOptions() {
    if (allFlashcards.isEmpty) return;

    final currentFlashcard = allFlashcards[currentQuestionIndex];
    List<String> options = [currentFlashcard.karina];

    // Get other words from the same deck (or all words if small)
    List<String> otherWords = allFlashcards
        .where((f) => f.karina != currentFlashcard.karina)
        .map((f) => f.karina)
        .toList();

    otherWords.shuffle();
    options.addAll(otherWords.take(2));

    // If not enough words in deck, add some generic placeholders
    while (options.length < 3) {
      options.add("Palabra ${options.length + 1}");
    }

    options.shuffle();
    currentOptions = options;
  }

  void _checkAnswer(String option) {
    if (hasAnswered) return;

    setState(() {
      hasAnswered = true;
      selectedOption = option;
      if (option == allFlashcards[currentQuestionIndex].karina) {
        score++;
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < allFlashcards.length - 1) {
      setState(() {
        currentQuestionIndex++;
        hasAnswered = false;
        selectedOption = null;
        _generateOptions();
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Quiz Terminado!'),
        content: Text('Tu puntaje es $score de ${allFlashcards.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckTitle),
        backgroundColor: Colors.green[400],
      ),
      body: FutureBuilder<List<Flashcard>>(
        future: _flashcardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tarjetas en este mazo.'));
          }

          final currentFlashcard = allFlashcards[currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pregunta ${currentQuestionIndex + 1} de ${allFlashcards.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  '¿Cómo se dice "${currentFlashcard.spanish}" en Kariña?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 40),
                ...currentOptions.map((option) {
                  bool isCorrect = option == currentFlashcard.karina;
                  bool isSelected = option == selectedOption;

                  Color? btnColor = Colors.white;
                  if (hasAnswered) {
                    if (isCorrect) {
                      btnColor = Colors.green[100];
                    } else if (isSelected) {
                      btnColor = Colors.red[100];
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        foregroundColor: Colors.brown,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: isSelected ? Colors.brown : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                      ),
                      onPressed: () => _checkAnswer(option),
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 40),
                if (hasAnswered)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _nextQuestion,
                    child: Text(
                      currentQuestionIndex < allFlashcards.length - 1
                          ? 'Siguiente'
                          : 'Finalizar',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
