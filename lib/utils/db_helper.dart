import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String _databaseName = 'karina_flashcards_v2.db'; // Renamed to avoid conflicts with old schema
  static const int _databaseVersion = 1;

  DBHelper._(); // private constructor (can't be called from outside)

  // the single instance
  static final DBHelper _singleton = DBHelper._();

  // factory constructor that always returns the single instance
  factory DBHelper() => _singleton;

  // the singleton will hold a reference to the database once opened
  Database? _database;

  // initialize the database when it's first requested
  Future<Database> get db async {
    _database ??= await _initDatabase(); // if null, initialize it
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);

    var db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        // create the deck table
        await db.execute('''
          CREATE TABLE deck(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL
          )
        ''');
        // create the flashcard table with new schema
        await db.execute('''
          CREATE TABLE flashcard(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deckId INTEGER NOT NULL,
            category TEXT NOT NULL,
            spanish TEXT NOT NULL,
            karina TEXT NOT NULL,
            audioPath TEXT,
            exampleSentence TEXT,
            difficultyLevel INTEGER,
            FOREIGN KEY (deckId) REFERENCES deck (id) ON DELETE CASCADE
          )
        ''');
      }
    );
    return db;
  }

  // fetch records from a table with an optional "where" clause
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await this.db;
    return db.query(table, where: where, whereArgs: whereArgs);
  }

  // insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int id = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // update a record in a table
  Future<void> update(String table, Map<String, dynamic> data, String whereClause, List<dynamic> whereArgs) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  // delete a record from a table
  Future<void> delete(String table, String whereClause, List<dynamic> whereArgs) async {
    final db = await this.db;
    await db.delete(
      table,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  Future<void> deleteDeckAndRelatedFlashcards(int deckId) async {
    final db = await this.db;
    await db.transaction((txn) async {
      await txn.delete('flashcard', where: 'deckId = ?', whereArgs: [deckId]);
      await txn.delete('deck', where: 'id = ?', whereArgs: [deckId]);
    });
  }
}
