import 'package:karina_app/utils/db_helper.dart';

class Flashcard {
  int? id;
  int deckId;
  String category;
  String spanish;
  String karina;
  String? audioPath;
  String? exampleSentence;
  int? difficultyLevel;

  Flashcard({
    this.id,
    required this.deckId,
    required this.category,
    required this.spanish,
    required this.karina,
    this.audioPath,
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
      'exampleSentence': exampleSentence,
      'difficultyLevel': difficultyLevel,
    };
  }

  static Flashcard fromMap(Map<String, dynamic> flashcardMap) {
    return Flashcard(
      id: flashcardMap['id'] as int?,
      deckId: flashcardMap['deckId'] as int,
      category: flashcardMap['category'] as String,
      spanish: flashcardMap['spanish'] as String,
      karina: flashcardMap['karina'] as String,
      audioPath: flashcardMap['audioPath'] as String?,
      exampleSentence: flashcardMap['exampleSentence'] as String?,
      difficultyLevel: flashcardMap['difficultyLevel'] as int?,
    );
  }

  Future<void> dbSave() async {
    id = await DBHelper().insert('flashcard', toMap());
  }

  Future<void> dbUpdate() async {
    await DBHelper().update('flashcard', toMap(), 'id = ?', [id]);
  }

  Future<void> dbDelete() async {
    if (id != null) {
      await DBHelper().delete('flashcard', 'id = ?', [id]);
    }
  }
}
