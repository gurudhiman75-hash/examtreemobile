import 'package:examtree/core/models/attempt_session_model.dart';
import 'package:examtree/features/test_attempt/data/local_attempt_draft_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('attempt resilience', () {
    test('newer local draft is recovered for the same active attempt', () {
      final remote = _state(updatedAt: 1000, answer: 1);
      final local = LocalAttemptDraft(
        userId: 'user-1',
        testId: 'test-1',
        attemptId: 'attempt-1',
        revision: 2,
        state: _state(updatedAt: 2000, answer: 3),
        localSavedAt: DateTime(2026, 8, 10),
      );

      final recovered = recoverableLocalDraft(
        local: local,
        activeAttemptId: 'attempt-1',
        remoteState: remote,
      );

      expect(recovered, same(local));
      expect(recovered!.state.answers['101'], 3);
    });

    test('stale local draft does not replace newer server progress', () {
      final local = LocalAttemptDraft(
        userId: 'user-1',
        testId: 'test-1',
        attemptId: 'attempt-1',
        revision: 1,
        state: _state(updatedAt: 1000, answer: 1),
        localSavedAt: DateTime(2026, 8, 10),
      );

      expect(
        recoverableLocalDraft(
          local: local,
          activeAttemptId: 'attempt-1',
          remoteState: _state(updatedAt: 2000, answer: 2),
        ),
        isNull,
      );
    });

    test('local draft from an old attempt is ignored', () {
      final local = LocalAttemptDraft(
        userId: 'user-1',
        testId: 'test-1',
        attemptId: 'attempt-old',
        revision: 4,
        state: _state(updatedAt: 5000, answer: 2),
        localSavedAt: DateTime(2026, 8, 10),
      );

      expect(
        recoverableLocalDraft(
          local: local,
          activeAttemptId: 'attempt-new',
          remoteState: _state(updatedAt: 2000, answer: 1),
        ),
        isNull,
      );
    });

    test('question timing survives draft serialization', () {
      final state = _state(updatedAt: 3000, answer: 2);
      final restored = AttemptSessionState.fromJson(state.toJson());

      expect(restored.questionTimeSecondsById, {'101': 37, '102': 9});
      expect(restored.timeLeft, 1200);
    });
  });
}

AttemptSessionState _state({required int updatedAt, required int answer}) {
  return AttemptSessionState(
    testId: 'test-1',
    testName: 'Mock test',
    category: 'SSC',
    currentQuestionIndex: 0,
    currentSectionIndex: 0,
    answers: {'101': answer, '102': null},
    flags: const {'101': false, '102': true},
    timeLeft: 1200,
    sectionTimeLeftByName: const {},
    updatedAt: updatedAt,
    attemptType: 'REAL',
    lockedSections: const [],
    visitedQuestionIds: const [101, 102],
    questionTimeSecondsById: const {'101': 37, '102': 9},
  );
}
