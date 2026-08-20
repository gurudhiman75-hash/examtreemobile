import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/models/attempt_session_model.dart';

class LocalAttemptDraft {
  const LocalAttemptDraft({
    required this.userId,
    required this.testId,
    required this.attemptId,
    required this.revision,
    required this.state,
    required this.localSavedAt,
  });

  final String userId;
  final String testId;
  final String attemptId;
  final int revision;
  final AttemptSessionState state;
  final DateTime localSavedAt;

  bool isNewerThan(AttemptSessionState? remoteState) {
    if (remoteState == null) return true;
    return state.updatedAt > remoteState.updatedAt;
  }
}

abstract interface class AttemptDraftStore {
  Future<LocalAttemptDraft?> read({
    required String userId,
    required String testId,
  });

  Future<void> write(LocalAttemptDraft draft);

  Future<void> delete({
    required String userId,
    required String testId,
  });

  Future<void> deleteAllForUser(String userId);
}

class SqfliteAttemptDraftStore implements AttemptDraftStore {
  static const _databaseName = 'examtree_attempt_drafts.db';
  static const _tableName = 'attempt_drafts';

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
          CREATE TABLE $_tableName (
            user_id TEXT NOT NULL,
            test_id TEXT NOT NULL,
            attempt_id TEXT NOT NULL,
            revision INTEGER NOT NULL,
            state_json TEXT NOT NULL,
            local_saved_at INTEGER NOT NULL,
            PRIMARY KEY (user_id, test_id)
          )
        ''');
      },
    );
    _database = database;
    return database;
  }

  @override
  Future<LocalAttemptDraft?> read({
    required String userId,
    required String testId,
  }) async {
    final db = await _open();
    final rows = await db.query(
      _tableName,
      where: 'user_id = ? AND test_id = ?',
      whereArgs: [userId, testId],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final rawState = jsonDecode(row['state_json'] as String);
    if (rawState is! Map) return null;

    return LocalAttemptDraft(
      userId: row['user_id'] as String,
      testId: row['test_id'] as String,
      attemptId: row['attempt_id'] as String,
      revision: row['revision'] as int,
      state: AttemptSessionState.fromJson(
        Map<String, dynamic>.from(rawState),
      ),
      localSavedAt: DateTime.fromMillisecondsSinceEpoch(
        row['local_saved_at'] as int,
      ),
    );
  }

  @override
  Future<void> write(LocalAttemptDraft draft) async {
    final db = await _open();
    await db.insert(
      _tableName,
      {
        'user_id': draft.userId,
        'test_id': draft.testId,
        'attempt_id': draft.attemptId,
        'revision': draft.revision,
        'state_json': jsonEncode(draft.state.toJson()),
        'local_saved_at': draft.localSavedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete({
    required String userId,
    required String testId,
  }) async {
    final db = await _open();
    await db.delete(
      _tableName,
      where: 'user_id = ? AND test_id = ?',
      whereArgs: [userId, testId],
    );
  }

  @override
  Future<void> deleteAllForUser(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return;
    final db = await _open();
    await db.delete(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [normalized],
    );
  }
}

LocalAttemptDraft? recoverableLocalDraft({
  required LocalAttemptDraft? local,
  required String activeAttemptId,
  required AttemptSessionState? remoteState,
}) {
  if (local == null || local.attemptId != activeAttemptId) return null;
  return local.isNewerThan(remoteState) ? local : null;
}
