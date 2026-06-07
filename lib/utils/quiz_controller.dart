import 'package:karina_app/models/flashcard.dart';

class QuizController {
  final List<Flashcard> allFlashcards;
  int currentLevelIndex = 0;

  QuizController({required this.allFlashcards});

  Flashcard get currentFlashcard => allFlashcards[currentLevelIndex];

  bool get isLessonComplete => currentLevelIndex >= allFlashcards.length;

  int get remainingWords => allFlashcards.length - currentLevelIndex;

  List<String> generateOptions() {
    if (isLessonComplete) return [];

    final current = currentFlashcard;
    Set<String> optionsSet = {current.karina};

    List<String> otherWords = allFlashcards
        .where((f) => f.karina != current.karina)
        .map((f) => f.karina)
        .toList();

    otherWords.shuffle();

    for (var word in otherWords.take(2)) {
      optionsSet.add(word);
    }

    int placeholderCount = 1;
    while (optionsSet.length < 3) {
      optionsSet.add("Opción ${placeholderCount++}");
    }

    return optionsSet.toList()..shuffle();
  }

  bool checkAnswer(String selectedOption) {
    return selectedOption == currentFlashcard.karina;
  }

  void next() {
    currentLevelIndex++;
  }

  void nextMatching(int setSize) {
    currentLevelIndex += setSize;
  }
}
