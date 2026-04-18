import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/models/flashcard.dart';
import 'package:karina_app/utils/db_helper.dart';
import 'package:karina_app/providers/game_provider.dart';
import 'package:karina_app/views/karina_matching_view.dart';
import 'package:karina_app/views/game_over_screen.dart';
import 'package:karina_app/views/quiz_results.dart';

enum GameType { multipleChoice, matching }

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
  int currentLevelIndex = 0;
  int score = 0;

  // Quiz state
  List<String> currentOptions = [];
  bool hasAnswered = false;
  String? selectedOption;

  // Game flow state
  GameType? currentGameType;
  late Stopwatch _stopwatch;

  // For matching game, we might want to group flashcards
  List<Flashcard> currentMatchingSet = [];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _flashcardsFuture = _loadFlashcards();
    context.read<GameProvider>().resetLives();
  }

  Future<List<Flashcard>> _loadFlashcards() async {
    final List<Map<String, dynamic>> maps = await DBHelper().query(
      'flashcard',
      where: 'deckId = ?',
      whereArgs: [widget.deckId],
    );
    allFlashcards = maps.map((e) => Flashcard.fromMap(e)).toList();
    allFlashcards.shuffle();
    _nextLevel();
    return allFlashcards;
  }

  void _nextLevel() {
    if (currentLevelIndex >= allFlashcards.length && currentGameType == GameType.multipleChoice) {
       _finishQuiz();
       return;
    }

    setState(() {
      hasAnswered = false;
      selectedOption = null;

      // Randomly choose game type
      // If we have at least 3 cards remaining, we can do matching
      if (allFlashcards.length - currentLevelIndex >= 3 && Random().nextBool()) {
        currentGameType = GameType.matching;
        int setSize = min(4, allFlashcards.length - currentLevelIndex);
        currentMatchingSet = allFlashcards.sublist(currentLevelIndex, currentLevelIndex + setSize);
      } else {
        currentGameType = GameType.multipleChoice;
        _generateOptions();
      }
    });
  }

  void _generateOptions() {
    if (allFlashcards.isEmpty || currentLevelIndex >= allFlashcards.length) return;

    final currentFlashcard = allFlashcards[currentLevelIndex];
    List<String> options = [currentFlashcard.karina];

    List<String> otherWords = allFlashcards
        .where((f) => f.karina != currentFlashcard.karina)
        .map((f) => f.karina)
        .toList();

    otherWords.shuffle();
    options.addAll(otherWords.take(2));

    while (options.length < 3) {
      options.add("Palabra ${options.length + 1}");
    }

    options.shuffle();
    currentOptions = options;
  }

  void _checkAnswer(String option) {
    if (hasAnswered) return;

    final gameProvider = context.read<GameProvider>();
    setState(() {
      hasAnswered = true;
      selectedOption = option;
      if (option == allFlashcards[currentLevelIndex].karina) {
        score++;
      } else {
        HapticFeedback.vibrate();
        gameProvider.subtractLife();
        if (gameProvider.isGameOver) {
          _handleGameOver();
        }
      }
    });
  }

  void _handleGameOver() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameOverScreen()),
    );
  }

  void _finishQuiz() {
    _stopwatch.stop();
    final duration = _stopwatch.elapsed;
    final timeStr = "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
    final livesRemaining = context.read<GameProvider>().lives;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResults(
          score: score,
          totalQuestions: allFlashcards.length,
          timeSpent: timeStr,
          livesRemaining: livesRemaining,
        ),
      ),
    );
  }

  void _onMatchingComplete() {
    setState(() {
      int setSize = currentMatchingSet.length;
      score += setSize;
      currentLevelIndex += setSize;
    });

    if (currentLevelIndex >= allFlashcards.length) {
      _finishQuiz();
    } else {
      _nextLevel();
    }
  }

  void _onMatchingIncorrect() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.subtractLife();
    if (gameProvider.isGameOver) {
      _handleGameOver();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckTitle),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          Consumer<GameProvider>(
            builder: (context, gp, child) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    '${gp.lives}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green[50],
      body: FutureBuilder<List<Flashcard>>(
        future: _flashcardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tarjetas en este mazo.'));
          }

          if (currentGameType == GameType.matching) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Empareja las palabras',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: KarinaMatchingView(
                      flashcards: currentMatchingSet,
                      onCorrect: () {},
                      onIncorrect: _onMatchingIncorrect,
                      onAllMatched: () {
                        Timer(const Duration(milliseconds: 800), () {
                          if (mounted) _onMatchingComplete();
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          final currentFlashcard = allFlashcards[currentLevelIndex];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (currentLevelIndex + 1) / allFlashcards.length,
                  backgroundColor: Colors.green[100],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pregunta ${currentLevelIndex + 1} de ${allFlashcards.length}',
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
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        currentLevelIndex++;
                      });
                      _nextLevel();
                    },
                    child: Text(
                      currentLevelIndex < allFlashcards.length - 1
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
