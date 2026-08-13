import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../results/presentation/providers/result_providers.dart';
import '../../data/local_daily_companion_store.dart';
import '../../domain/daily_companion.dart';
import '../../services/study_reminder_service.dart';

final dailyCompanionStoreProvider = Provider<DailyCompanionStore>((ref) {
  return SqfliteDailyCompanionStore();
});

final studyReminderServiceProvider = Provider<StudyReminderService>((ref) {
  return LocalStudyReminderService();
});

final dailyCompanionClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final dailyCompanionControllerProvider = Provider<DailyCompanionController>((ref) {
  return DailyCompanionController(
    store: ref.watch(dailyCompanionStoreProvider),
    reminderService: ref.watch(studyReminderServiceProvider),
  );
});

final dailyCompanionSnapshotProvider = FutureProvider<DailyCompanionSnapshot>((
  ref,
) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw StateError('Authentication is required to load Daily Companion.');
  }

  final now = ref.watch(dailyCompanionClockProvider)();
  final store = ref.watch(dailyCompanionStoreProvider);
  final resultsAsync = ref.watch(userResultsProvider);

  // Canonical results enrich the local queue whenever they are available.
  // Offline or failed result refreshes never block access to already-cached
  // revision material.
  final results = resultsAsync.value;
  if (results != null) {
    final candidates = deriveRevisionCandidates(results, now: now);
    await store.syncCandidates(userId: user.uid, candidates: candidates);
  }

  return store.loadSnapshot(userId: user.uid, now: now);
});

class DailyCompanionController {
  const DailyCompanionController({
    required DailyCompanionStore store,
    required StudyReminderService reminderService,
  })  : _store = store,
        _reminderService = reminderService;

  final DailyCompanionStore _store;
  final StudyReminderService _reminderService;

  Future<bool> saveSettings({
    required String userId,
    required StudyCompanionSettings settings,
  }) async {
    final reminderReady = await _reminderService.schedule(settings);
    final effectiveSettings = reminderReady
        ? settings
        : settings.copyWith(reminderEnabled: false);
    await _store.saveSettings(userId: userId, settings: effectiveSettings);
    return reminderReady;
  }

  Future<void> recordOutcome({
    required String userId,
    required RevisionItem item,
    required bool remembered,
    required DateTime reviewedAt,
  }) {
    return _store.recordOutcome(
      userId: userId,
      item: item,
      remembered: remembered,
      reviewedAt: reviewedAt,
    );
  }

  Future<int> syncFromCanonicalResults({
    required String userId,
    required List<dynamic> results,
    required DateTime now,
  }) {
    return _store.syncCandidates(
      userId: userId,
      candidates: deriveRevisionCandidates(
        results.cast(),
        now: now,
      ),
    );
  }
}
