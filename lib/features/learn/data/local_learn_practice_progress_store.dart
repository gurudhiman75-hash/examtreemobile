import 'package:sqflite/sqflite.dart';

import '../domain/learn_practice_models.dart';

abstract interface class LearnPracticeProgressStore {
  Future<LearnPracticeProgress?> read(String topicId);
  Future<List<LearnPracticeProgress>> readAll();
  Future<void> write(LearnPracticeProgress progress);
  Future<void> clear(String topicId);
}

class SqfliteLearnPracticeProgressStore implements LearnPracticeProgressStore {
  static const _databaseName = 'examtree_learn_practice.db';
  static const _table = 'learn_practice_progress';

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
            topic_id TEXT PRIMARY KEY,
            status TEXT NOT NULL,
            current_question INTEGER NOT NULL,
            total_questions INTEGER NOT NULL,
            correct_answers INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
    _database = database;
    return database;
  }

  @override
  Future<LearnPracticeProgress?> read(String topicId) async {
    final db = await _open();
    final rows = await db.query(
      _table,
      where: 'topic_id = ?',
      whereArgs: [topicId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<LearnPracticeProgress>> readAll() async {
    final db = await _open();
    final rows = await db.query(_table, orderBy: 'updated_at DESC');
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<void> write(LearnPracticeProgress progress) async {
    final db = await _open();
    await db.insert(
      _table,
      {
        'topic_id': progress.topicId,
        'status': progress.status.name,
        'current_question': progress.currentQuestion,
        'total_questions': progress.totalQuestions,
        'correct_answers': progress.correctAnswers,
        'updated_at': progress.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> clear(String topicId) async {
    final db = await _open();
    await db.delete(_table, where: 'topic_id = ?', whereArgs: [topicId]);
  }

  LearnPracticeProgress _fromRow(Map<String, Object?> row) {
    final rawStatus = row['status']?.toString() ?? '';
    final status = LearnPracticeStatus.values.firstWhere(
      (value) => value.name == rawStatus,
      orElse: () => LearnPracticeStatus.notStarted,
    );
    return LearnPracticeProgress(
      topicId: row['topic_id']?.toString() ?? '',
      status: status,
      currentQuestion: (row['current_question'] as num?)?.toInt() ?? 0,
      totalQuestions: (row['total_questions'] as num?)?.toInt() ?? 0,
      correctAnswers: (row['correct_answers'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (row['updated_at'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
