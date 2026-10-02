import 'package:sqflite/sqflite.dart';

import '../domain/promotion_campaign.dart';

class LocalPromotionExposureStore {
  static const _databaseName = 'examtree_promotions.db';
  static const _table = 'promotion_exposure';

  Future<Database> _open() async {
    final basePath = await getDatabasesPath();
    return openDatabase(
      '$basePath/$_databaseName',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            campaign_id TEXT PRIMARY KEY,
            dismissed INTEGER NOT NULL DEFAULT 0,
            impression_day TEXT,
            impression_count INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  String _dayKey(DateTime now) {
    final local = now.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }

  Future<bool> isEligible(
    PromotionCampaign campaign, {
    DateTime? now,
  }) async {
    try {
      final db = await _open();
      final rows = await db.query(
        _table,
        where: 'campaign_id = ?',
        whereArgs: [campaign.id],
        limit: 1,
      );
      if (rows.isEmpty) return true;
      final row = rows.first;
      final today = _dayKey(now ?? DateTime.now());
      final storedDay = row['impression_day']?.toString();
      if ((row['dismissed'] as int? ?? 0) == 1 && storedDay == today) {
        return false;
      }

      final cap = campaign.frequencyCapPerDay;
      if (cap == null) return true;
      final count = row['impression_count'] as int? ?? 0;
      return storedDay != today || count < cap;
    } catch (_) {
      // Local exposure controls must never make the app unusable.
      return true;
    }
  }

  Future<void> recordImpression(
    PromotionCampaign campaign, {
    DateTime? now,
  }) async {
    try {
      final db = await _open();
      final today = _dayKey(now ?? DateTime.now());
      final rows = await db.query(
        _table,
        where: 'campaign_id = ?',
        whereArgs: [campaign.id],
        limit: 1,
      );
      final current = rows.isEmpty ? null : rows.first;
      final sameDay = current?['impression_day']?.toString() == today;
      final nextCount =
          sameDay ? (current?['impression_count'] as int? ?? 0) + 1 : 1;
      await db.insert(
        _table,
        {
          'campaign_id': campaign.id,
          'dismissed': current?['dismissed'] as int? ?? 0,
          'impression_day': today,
          'impression_count': nextCount,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Best-effort local frequency tracking.
    }
  }

  Future<void> dismiss(String campaignId) async {
    try {
      final db = await _open();
      final rows = await db.query(
        _table,
        where: 'campaign_id = ?',
        whereArgs: [campaignId],
        limit: 1,
      );
      final current = rows.isEmpty ? null : rows.first;
      await db.insert(
        _table,
        {
          'campaign_id': campaignId,
          'dismissed': 1,
          'impression_day': current?['impression_day'],
          'impression_count': current?['impression_count'] as int? ?? 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Best-effort local dismissal persistence.
    }
  }
}
