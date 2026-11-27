import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/question_bookmark.dart';

abstract interface class QuestionBookmarkStore {
  /// Newest first.
  Future<List<QuestionBookmark>> loadAll();
  Future<void> save(QuestionBookmark bookmark);
  Future<void> remove(String id);
}

/// Keeps bookmarks on this device. They are not synced to the account yet.
class SqfliteQuestionBookmarkStore implements QuestionBookmarkStore {
  static const _databaseName = 'examtree_bookmarks.db';
  static const _table = 'question_bookmarks';

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
            bookmark_id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            saved_at INTEGER NOT NULL
          )
        ''');
      },
    );
    _database = database;
    return database;
  }

  @override
  Future<List<QuestionBookmark>> loadAll() async {
    final db = await _open();
    final rows = await db.query(_table, orderBy: 'saved_at DESC');
    final bookmarks = <QuestionBookmark>[];
    for (final row in rows) {
      try {
        final bookmark = QuestionBookmark.tryFromJson(
          jsonDecode(row['payload']?.toString() ?? ''),
        );
        if (bookmark != null) bookmarks.add(bookmark);
      } on FormatException {
        // Skip a damaged row instead of hiding every bookmark.
      }
    }
    return bookmarks;
  }

  @override
  Future<void> save(QuestionBookmark bookmark) async {
    final db = await _open();
    await db.insert(_table, {
      'bookmark_id': bookmark.id,
      'payload': jsonEncode(bookmark.toJson()),
      'saved_at': bookmark.savedAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> remove(String id) async {
    final db = await _open();
    await db.delete(_table, where: 'bookmark_id = ?', whereArgs: [id]);
  }
}

/// For tests and as a fallback when the device database cannot open.
class InMemoryQuestionBookmarkStore implements QuestionBookmarkStore {
  final Map<String, QuestionBookmark> _items = {};

  @override
  Future<List<QuestionBookmark>> loadAll() async {
    final list = _items.values.toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return list;
  }

  @override
  Future<void> save(QuestionBookmark bookmark) async {
    _items[bookmark.id] = bookmark;
  }

  @override
  Future<void> remove(String id) async {
    _items.remove(id);
  }
}
