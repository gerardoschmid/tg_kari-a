import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String _databaseName = 'karina_flashcards_v2.db';
  static const int _databaseVersion = 2;

  DBHelper._();

  static final DBHelper _singleton = DBHelper._();

  factory DBHelper() => _singleton;

  Database? _database;

  Future<Database> get db async {
    _database ??= await _initDatabase();
    // OPTIMIZADO [NUL-001]: Uso de null-check seguro
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);

    var db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE flashcard ADD COLUMN imagePath TEXT');
        }
      },
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE deck(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE flashcard(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deckId INTEGER NOT NULL,
            category TEXT NOT NULL,
            spanish TEXT NOT NULL,
            karina TEXT NOT NULL,
            audioPath TEXT,
            imagePath TEXT,
            exampleSentence TEXT,
            difficultyLevel INTEGER,
            FOREIGN KEY (deckId) REFERENCES deck (id) ON DELETE CASCADE
          )
        ''');
      }
    );
    return db;
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) async {
    final dbInstance = await db;
    return dbInstance.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final dbInstance = await db;
    int id = await dbInstance.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> update(String table, Map<String, dynamic> data, String whereClause, List<dynamic> whereArgs) async {
    final dbInstance = await db;
    await dbInstance.update(
      table,
      data,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  Future<void> delete(String table, String whereClause, List<dynamic> whereArgs) async {
    final dbInstance = await db;
    await dbInstance.delete(
      table,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  Future<void> deleteDeckAndRelatedFlashcards(int deckId) async {
    final dbInstance = await db;
    await dbInstance.transaction((txn) async {
      await txn.delete('flashcard', where: 'deckId = ?', whereArgs: [deckId]);
      await txn.delete('deck', where: 'id = ?', whereArgs: [deckId]);
    });
  }
}
