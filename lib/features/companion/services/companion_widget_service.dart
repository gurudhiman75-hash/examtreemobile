import 'package:flutter/services.dart';

import '../domain/daily_companion.dart';

abstract interface class CompanionWidgetService {
  Future<void> publish(
    DailyCompanionSnapshot snapshot, {
    required DateTime now,
  });

  Future<void> clear();
}

class AndroidCompanionWidgetService implements CompanionWidgetService {
  const AndroidCompanionWidgetService();

  static const MethodChannel _channel = MethodChannel(
    'com.examtree.examtree/companion_widget',
  );

  @override
  Future<void> publish(
    DailyCompanionSnapshot snapshot, {
    required DateTime now,
  }) async {
    final dueCount = snapshot.dueItems(now).length;
    final dailyGoal = snapshot.settings.dailyQuestionGoal;
    final completedToday = snapshot.completedToday;

    try {
      await _channel.invokeMethod<void>('publish', <String, Object>{
        'dueCount': dueCount,
        'dailyGoal': dailyGoal,
        'completedToday': completedToday,
        'remainingGoal': snapshot.remainingGoal(now),
        'savedCount': snapshot.items.length,
        'updatedAtMillis': now.millisecondsSinceEpoch,
      });
    } on MissingPluginException {
      // Android home-screen widgets are an optional platform surface.
    } on PlatformException {
      // Widget publication must never block the canonical learning flow.
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _channel.invokeMethod<void>('clear');
    } on MissingPluginException {
      // No native widget bridge exists on this platform.
    } on PlatformException {
      // Sign-out must succeed even if the launcher cannot refresh a widget.
    }
  }
}
