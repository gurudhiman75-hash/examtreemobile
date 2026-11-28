import 'package:sqflite/sqflite.dart';

import '../domain/question_language.dart';

/// Stores the language used for menus, buttons and screen text. It is kept
/// separate from the question language so a learner can, for example, read
/// the app in Punjabi and practise questions in English.
abstract interface class AppLanguageStore {
  /// Null when the learner has never chosen an app language.
  Future<QuestionLanguage?> load();
  Future<void> save(QuestionLanguage language);
}

class SqfliteAppLanguageStore implements AppLanguageStore {
  static const _databaseName = 'examtree_preferences.db';
  static const _table = 'device_preferences';
  static const _key = 'app_language';

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
  Future<QuestionLanguage?> load() async {
    final db = await _open();
    final rows = await db.query(
      _table,
      columns: ['preference_value'],
      where: 'preference_key = ?',
      whereArgs: [_key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return QuestionLanguage.fromStorage(
      rows.first['preference_value']?.toString(),
    );
  }

  @override
  Future<void> save(QuestionLanguage language) async {
    final db = await _open();
    await db.insert(_table, {
      'preference_key': _key,
      'preference_value': language.name,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
