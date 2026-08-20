import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/daily_companion.dart';

abstract interface class DailyCompanionStore {
  Future<DailyCompanionSnapshot> loadSnapshot({
    required String userId,
    required DateTime now,
  });

  Future<void> saveSettings({
    required String userId,
    required StudyCompanionSettings settings,
  });

  Future<int> syncCandidates({
    required String userId,
    required List<RevisionItem> candidates,
  });

  Future<void> recordOutcome({
    required String userId,
    required RevisionItem item,
    required bool remembered,
    required DateTime reviewedAt,
  });

  Future<void> deleteAllForUser(String userId);
}

class SqfliteDailyCompanionStore implements DailyCompanionStore {
  static const _databaseName = 'examtree_daily_companion.db';
  static const _settingsTable = 'companion_settings';
  static const _revisionTable = 'revision_items';
  static const _eventTable = 'revision_events';

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
          CREATE TABLE $_settingsTable (
            user_id TEXT PRIMARY KEY,
            daily_question_goal INTEGER NOT NULL,
            reminder_enabled INTEGER NOT NULL,
            reminder_hour INTEGER NOT NULL,
            reminder_minute INTEGER NOT NULL,
            reminder_weekdays TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $_revisionTable (
            user_id TEXT NOT NULL,
            item_id TEXT NOT NULL,
            source_attempt_id TEXT NOT NULL,
            test_id TEXT NOT NULL,
            test_name TEXT NOT NULL,
            section_name TEXT NOT NULL,
            question_text TEXT NOT NULL,
            options_json TEXT NOT NULL,
            selected_index INTEGER,
            correct_index INTEGER NOT NULL,
            explanation TEXT NOT NULL,
            reasons_json TEXT NOT NULL,
            time_taken_seconds INTEGER,
            due_at INTEGER NOT NULL,
            stage INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            last_reviewed_at INTEGER,
            PRIMARY KEY (user_id, item_id)
          )
        ''');
        await db.execute('''
          CREATE INDEX revision_items_due_idx
          ON $_revisionTable (user_id, due_at)
        ''');
        await db.execute('''
          CREATE TABLE $_eventTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            item_id TEXT NOT NULL,
            remembered INTEGER NOT NULL,
            reviewed_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE INDEX revision_events_day_idx
          ON $_eventTable (user_id, reviewed_at)
        ''');
      },
    );
    _database = database;
    return database;
  }

  @override
  Future<DailyCompanionSnapshot> loadSnapshot({
    required String userId,
    required DateTime now,
  }) async {
    final db = await _open();
    final settingsRows = await db.query(
      _settingsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    final settings = settingsRows.isEmpty
        ? const StudyCompanionSettings()
        : _settingsFromRow(settingsRows.first);

    final itemRows = await db.query(
      _revisionTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'due_at ASC, created_at ASC',
    );
    final items = itemRows.map(_itemFromRow).toList(growable: false);

    final localNow = now.toLocal();
    final dayStart = DateTime(localNow.year, localNow.month, localNow.day);
    final nextDay = dayStart.add(const Duration(days: 1));
    final count = Sqflite.firstIntValue(
          await db.rawQuery(
            '''
            SELECT COUNT(*)
            FROM $_eventTable
            WHERE user_id = ? AND reviewed_at >= ? AND reviewed_at < ?
            ''',
            [
              userId,
              dayStart.millisecondsSinceEpoch,
              nextDay.millisecondsSinceEpoch,
            ],
          ),
        ) ??
        0;

    return DailyCompanionSnapshot(
      settings: settings,
      items: items,
      completedToday: count,
    );
  }

  @override
  Future<void> saveSettings({
    required String userId,
    required StudyCompanionSettings settings,
  }) async {
    final db = await _open();
    await db.insert(
      _settingsTable,
      {
        'user_id': userId,
        'daily_question_goal': settings.dailyQuestionGoal.clamp(1, 100),
        'reminder_enabled': settings.reminderEnabled ? 1 : 0,
        'reminder_hour': settings.reminderHour.clamp(0, 23),
        'reminder_minute': settings.reminderMinute.clamp(0, 59),
        'reminder_weekdays': jsonEncode(
          settings.reminderWeekdays
              .where((day) => day >= 1 && day <= 7)
              .toList(growable: false),
        ),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> syncCandidates({
    required String userId,
    required List<RevisionItem> candidates,
  }) async {
    if (candidates.isEmpty) return 0;
    final db = await _open();
    var inserted = 0;

    await db.transaction((txn) async {
      for (final candidate in candidates) {
        final existing = await txn.query(
          _revisionTable,
          columns: ['item_id'],
          where: 'user_id = ? AND item_id = ?',
          whereArgs: [userId, candidate.id],
          limit: 1,
        );
        if (existing.isEmpty) {
          await txn.insert(
            _revisionTable,
            _itemToRow(userId, candidate),
          );
          inserted += 1;
          continue;
        }

        await txn.update(
          _revisionTable,
          {
            'test_id': candidate.testId,
            'test_name': candidate.testName,
            'section_name': candidate.section,
            'question_text': candidate.questionText,
            'options_json': jsonEncode(candidate.options),
            'selected_index': candidate.selectedIndex,
            'correct_index': candidate.correctIndex,
            'explanation': candidate.explanation,
            'reasons_json': jsonEncode(
              candidate.reasons.map((reason) => reason.name).toList(),
            ),
            'time_taken_seconds': candidate.timeTakenSeconds,
          },
          where: 'user_id = ? AND item_id = ?',
          whereArgs: [userId, candidate.id],
        );
      }
    });
    return inserted;
  }

  @override
  Future<void> recordOutcome({
    required String userId,
    required RevisionItem item,
    required bool remembered,
    required DateTime reviewedAt,
  }) async {
    final db = await _open();
    final updated = applyRevisionOutcome(
      item,
      remembered: remembered,
      reviewedAt: reviewedAt,
    );

    await db.transaction((txn) async {
      await txn.update(
        _revisionTable,
        {
          'due_at': updated.dueAt.millisecondsSinceEpoch,
          'stage': updated.stage,
          'last_reviewed_at': reviewedAt.millisecondsSinceEpoch,
        },
        where: 'user_id = ? AND item_id = ?',
        whereArgs: [userId, item.id],
      );
      await txn.insert(
        _eventTable,
        {
          'user_id': userId,
          'item_id': item.id,
          'remembered': remembered ? 1 : 0,
          'reviewed_at': reviewedAt.millisecondsSinceEpoch,
        },
      );
    });
  }

  @override
  Future<void> deleteAllForUser(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return;
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete(
        _eventTable,
        where: 'user_id = ?',
        whereArgs: [normalized],
      );
      await txn.delete(
        _revisionTable,
        where: 'user_id = ?',
        whereArgs: [normalized],
      );
      await txn.delete(
        _settingsTable,
        where: 'user_id = ?',
        whereArgs: [normalized],
      );
    });
  }
}

StudyCompanionSettings _settingsFromRow(Map<String, Object?> row) {
  final rawDays = jsonDecode(row['reminder_weekdays'] as String);
  final days = rawDays is List
      ? rawDays
          .whereType<num>()
          .map((value) => value.toInt())
          .where((value) => value >= 1 && value <= 7)
          .toSet()
      : <int>{};
  return StudyCompanionSettings(
    dailyQuestionGoal: (row['daily_question_goal'] as int).clamp(1, 100),
    reminderEnabled: row['reminder_enabled'] == 1,
    reminderHour: (row['reminder_hour'] as int).clamp(0, 23),
    reminderMinute: (row['reminder_minute'] as int).clamp(0, 59),
    reminderWeekdays: days.isEmpty ? const {1, 2, 3, 4, 5, 6, 7} : days,
  );
}

Map<String, Object?> _itemToRow(String userId, RevisionItem item) {
  return {
    'user_id': userId,
    'item_id': item.id,
    'source_attempt_id': item.sourceAttemptId,
    'test_id': item.testId,
    'test_name': item.testName,
    'section_name': item.section,
    'question_text': item.questionText,
    'options_json': jsonEncode(item.options),
    'selected_index': item.selectedIndex,
    'correct_index': item.correctIndex,
    'explanation': item.explanation,
    'reasons_json': jsonEncode(
      item.reasons.map((reason) => reason.name).toList(growable: false),
    ),
    'time_taken_seconds': item.timeTakenSeconds,
    'due_at': item.dueAt.millisecondsSinceEpoch,
    'stage': item.stage,
    'created_at': item.createdAt.millisecondsSinceEpoch,
    'last_reviewed_at': item.lastReviewedAt?.millisecondsSinceEpoch,
  };
}

RevisionItem _itemFromRow(Map<String, Object?> row) {
  final optionsRaw = jsonDecode(row['options_json'] as String);
  final reasonsRaw = jsonDecode(row['reasons_json'] as String);
  final options = optionsRaw is List
      ? optionsRaw.map((value) => value.toString()).toList(growable: false)
      : const <String>[];
  final reasons = reasonsRaw is List
      ? reasonsRaw
          .map((value) => value.toString())
          .map((name) => RevisionReason.values.where((reason) => reason.name == name))
          .where((matches) => matches.isNotEmpty)
          .map((matches) => matches.first)
          .toSet()
      : <RevisionReason>{};

  return RevisionItem(
    id: row['item_id'] as String,
    sourceAttemptId: row['source_attempt_id'] as String,
    testId: row['test_id'] as String,
    testName: row['test_name'] as String,
    section: row['section_name'] as String,
    questionText: row['question_text'] as String,
    options: options,
    selectedIndex: row['selected_index'] as int?,
    correctIndex: row['correct_index'] as int,
    explanation: row['explanation'] as String,
    reasons: reasons,
    timeTakenSeconds: row['time_taken_seconds'] as int?,
    dueAt: DateTime.fromMillisecondsSinceEpoch(row['due_at'] as int),
    stage: row['stage'] as int,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
    lastReviewedAt: row['last_reviewed_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row['last_reviewed_at'] as int),
  );
}
