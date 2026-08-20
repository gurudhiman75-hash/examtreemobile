import 'package:sqflite/sqflite.dart';

import '../domain/question_language.dart';

abstract interface class QuestionLanguageStore {
  Future<QuestionLanguage> load();
  Future<void> save(QuestionLanguage language);
}

class SqfliteQuestionLanguageStore implements QuestionLanguageStore {
  static const _databaseName = 'examtree_preferences.db';
  static const _table = 'device_preferences';
  static const _languageKey = 'question_language';

  Database? _database;

  Future<Database> _open() async {
    final existing = _database;
    if (existing != null) return existing;

    final basePath = await getDatabasesPath();
    final database = await openDatabase(
      '$basePath/$_databaseName',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            preference_key TEXT PRIMARY KEY,
            preference_value TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
    _database = database;
    return database;
  }

  @override
  Future<QuestionLanguage> load() async {
    final db = await _open();
    final rows = await db.query(
      _table,
      columns: ['preference_value'],
      where: 'preference_key = ?',
      whereArgs: [_languageKey],
      limit: 1,
    );
    if (rows.isEmpty) return QuestionLanguage.english;
    return QuestionLanguage.fromStorage(rows.first['preference_value']?.toString());
  }

  @override
  Future<void> save(QuestionLanguage language) async {
    final db = await _open();
    await db.insert(
      _table,
      {
        'preference_key': _languageKey,
        'preference_value': language.name,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
