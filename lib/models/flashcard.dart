class Flashcard {
  int? id;
  int deckId;
  String category;
  String spanish;
  String karina;
  String? audioPath;
  String? imagePath;
  String? exampleSentence;
  int? difficultyLevel;

  Flashcard({
    this.id,
    required this.deckId,
    required this.category,
    required this.spanish,
    required this.karina,
    this.audioPath,
    this.imagePath,
    this.exampleSentence,
    this.difficultyLevel,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'deckId': deckId,
      'category': category,
      'spanish': spanish,
      'karina': karina,
      'audioPath': audioPath,
      'imagePath': imagePath,
      'exampleSentence': exampleSentence,
      'difficultyLevel': difficultyLevel,
    };
  }

  static Flashcard fromMap(Map<String, dynamic> flashcardMap) {
    return Flashcard(
      id: flashcardMap['id'] as int?,
      deckId: (flashcardMap['deckId'] as num?)?.toInt() ?? 0,
      category: flashcardMap['category'] as String? ?? 'General',
      spanish: flashcardMap['spanish'] as String? ?? '',
      karina: flashcardMap['karina'] as String? ?? '',
      audioPath: flashcardMap['audioPath'] as String?,
      imagePath: flashcardMap['imagePath'] as String?,
      exampleSentence: flashcardMap['exampleSentence'] as String?,
      difficultyLevel: (flashcardMap['difficultyLevel'] as num?)?.toInt() ?? 1,
    );
  }
}
