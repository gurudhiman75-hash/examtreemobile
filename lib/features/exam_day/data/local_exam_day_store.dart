import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/exam_day_mode.dart';

abstract interface class ExamDayStore {
  Future<ExamDayTarget?> loadTarget(String userId);
  Future<void> saveTarget({required String userId, required ExamDayTarget target});
  Future<void> deleteTarget(String userId);
}

class SqfliteExamDayStore implements ExamDayStore {
  static const _databaseName = 'examtree_exam_day.db';
  static const _table = 'exam_day_targets';

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
            user_id TEXT PRIMARY KEY,
            exam_name TEXT NOT NULL,
            exam_at INTEGER NOT NULL,
            reporting_at INTEGER,
            venue TEXT NOT NULL,
            reminders_enabled INTEGER NOT NULL,
            checklist_json TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
    _database = database;
    return database;
  }

  @override
  Future<ExamDayTarget?> loadTarget(String userId) async {
    final db = await _open();
    final rows = await db.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<void> saveTarget({
    required String userId,
    required ExamDayTarget target,
  }) async {
    final db = await _open();
    await db.insert(
      _table,
      {
        'user_id': userId,
        'exam_name': target.examName.trim(),
        'exam_at': target.examAt.millisecondsSinceEpoch,
        'reporting_at': target.reportingAt?.millisecondsSinceEpoch,
        'venue': target.venue.trim(),
        'reminders_enabled': target.remindersEnabled ? 1 : 0,
        'checklist_json': jsonEncode(
          target.checklist
              .map(
                (item) => {
                  'id': item.id,
                  'label': item.label,
                  'completed': item.completed,
                  'isCustom': item.isCustom,
                },
              )
              .toList(growable: false),
        ),
        'updated_at': target.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTarget(String userId) async {
    final db = await _open();
    await db.delete(_table, where: 'user_id = ?', whereArgs: [userId]);
  }
}

ExamDayTarget _fromRow(Map<String, Object?> row) {
  final rawChecklist = jsonDecode(row['checklist_json'] as String);
  final storedChecklist = rawChecklist is List
      ? rawChecklist
          .whereType<Map>()
          .map(
            (raw) => ExamDayChecklistItem(
              id: raw['id']?.toString() ?? '',
              label: raw['label']?.toString() ?? '',
              completed: raw['completed'] == true,
              isCustom: raw['isCustom'] == true,
            ),
          )
          .where((item) => item.id.isNotEmpty && item.label.trim().isNotEmpty)
          .toList(growable: false)
      : const <ExamDayChecklistItem>[];

  return ExamDayTarget(
    examName: row['exam_name'] as String,
    examAt: DateTime.fromMillisecondsSinceEpoch(row['exam_at'] as int),
    reportingAt: row['reporting_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row['reporting_at'] as int),
    venue: row['venue'] as String,
    remindersEnabled: row['reminders_enabled'] == 1,
    checklist: mergeExamDayChecklist(storedChecklist),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
  );
}
