import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/companion/domain/daily_companion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 13, 19);

  test('builds revision queue only from useful review evidence', () {
    final result = _result([
      _question(1, selected: 1, correct: 0, seconds: 30),
      _question(2, selected: null, correct: 0, seconds: 20),
      _question(3, selected: 0, correct: 0, seconds: 25, flagged: true),
      _question(4, selected: 0, correct: 0, seconds: 180),
      _question(5, selected: 0, correct: 0, seconds: 30),
    ]);

    final items = deriveRevisionCandidates([result], now: now);

    expect(items, hasLength(4));
    expect(items.map((item) => item.id), isNot(contains('attempt-1:5')));
    expect(items.first.reasons, contains(RevisionReason.incorrect));
    expect(items[1].reasons, contains(RevisionReason.unanswered));
    expect(items[2].reasons, contains(RevisionReason.flagged));
    expect(items[3].reasons, contains(RevisionReason.slow));
  });

  test('clean correct questions do not enter the local revision queue', () {
    final result = _result([
      _question(1, selected: 0, correct: 0),
    ]);

    expect(deriveRevisionCandidates([result], now: now), isEmpty);
  });

  test('remembered reviews use widening intervals', () {
    var item = _item(now);
    for (final days in [1, 3, 7, 14, 30, 60]) {
      final reviewedAt = item.dueAt;
      item = applyRevisionOutcome(
        item,
        remembered: true,
        reviewedAt: reviewedAt,
      );
      expect(item.dueAt, reviewedAt.add(Duration(days: days)));
    }
  });

  test('review again resets the item for tomorrow', () {
    final updated = applyRevisionOutcome(
      _item(now).copyWith(stage: 4),
      remembered: false,
      reviewedAt: now,
    );
    expect(updated.stage, 0);
    expect(updated.dueAt, now.add(const Duration(days: 1)));
  });

  test('quick revision uses due questions and session cap', () {
    final items = List.generate(
      12,
      (index) => _item(
        now,
        id: 'item-$index',
        dueAt: index < 8 ? now : now.add(const Duration(days: 1)),
      ),
    );
    final selected = selectQuickRevisionItems(items, minutes: 5, now: now);
    expect(selected, hasLength(5));
    expect(selected.every((item) => item.isDue(now)), isTrue);
  });

  test('daily goal remaining never becomes negative', () {
    final snapshot = DailyCompanionSnapshot(
      settings: const StudyCompanionSettings(dailyQuestionGoal: 5),
      items: const [],
      completedToday: 8,
    );

    expect(snapshot.remainingGoal(now), 0);
  });
}

Result _result(List<ResultQuestionReview> questions) => Result(
      id: 'attempt-1',
      attemptId: 'attempt-1',
      userId: 'user-1',
      examId: 'test-1',
      score: 0,
      maxScore: 5,
      accuracy: 0,
      correctCount: 0,
      incorrectCount: 0,
      skippedCount: 0,
      calculatedAt: DateTime(2026, 8, 13),
      testName: 'SSC Mock',
      questionReview: questions,
    );

ResultQuestionReview _question(
  int id, {
  required int? selected,
  required int correct,
  int? seconds,
  bool flagged = false,
}) =>
    ResultQuestionReview(
      questionId: id,
      questionVersionId: 'qv-$id',
      testQuestionId: 'tq-$id',
      testSectionId: 'section-1',
      section: 'Quant',
      text: 'Question $id',
      options: const ['A', 'B', 'C', 'D'],
      optionKeys: const ['A', 'B', 'C', 'D'],
      selected: selected,
      selectedOptionKey: null,
      correct: correct,
      correctOptionKey: String.fromCharCode(65 + correct),
      timeTakenSeconds: seconds,
      flagged: flagged,
      explanation: 'Explanation $id',
    );

RevisionItem _item(
  DateTime now, {
  String id = 'item',
  DateTime? dueAt,
}) =>
    RevisionItem(
      id: id,
      sourceAttemptId: 'attempt-1',
      testId: 'test-1',
      testName: 'SSC Mock',
      section: 'Quant',
      questionText: 'Question',
      options: const ['A', 'B', 'C', 'D'],
      selectedIndex: 1,
      correctIndex: 0,
      explanation: 'Explanation',
      reasons: const {RevisionReason.incorrect},
      timeTakenSeconds: 45,
      dueAt: dueAt ?? now,
      stage: 0,
      createdAt: now,
    );
