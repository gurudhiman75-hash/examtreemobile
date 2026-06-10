import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/attempt_draft_model.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/repositories/attempt_draft_repository.dart';

final activeDraftProvider = FutureProvider.family<AttemptDraft?, String>((
  ref,
  testId,
) async {
  final repository = ref.watch(attemptDraftRepositoryProvider);
  return repository.getDraft(testId);
});

final draftListProvider = FutureProvider<List<AttemptDraft>>((ref) async {
  final repository = ref.watch(attemptDraftRepositoryProvider);
  return repository.listDrafts();
});

final draftSaveProvider = Provider<DraftSaveController>((ref) {
  return DraftSaveController(ref.watch(attemptDraftRepositoryProvider));
});

class DraftSaveController {
  const DraftSaveController(this._repository);

  final AttemptDraftRepository _repository;

  Future<SaveAttemptDraftResult> save({
    required String testId,
    required String testName,
    required String category,
    required AttemptDraftState state,
    int? expectedVersion,
    AttemptDraftStatus status = AttemptDraftStatus.inProgress,
  }) {
    return _repository.saveDraft(
      testId: testId,
      testName: testName,
      category: category,
      state: state,
      expectedVersion: expectedVersion,
      status: status,
      lastDevice: 'android',
    );
  }
}
