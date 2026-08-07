import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/profile/domain/performance_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PerformanceAnalytics', () {
    test('aggregates overview, timing, trends and section outcomes', () {
      final analytics = PerformanceAnalytics.fromResults('student-1', [
        _result(
          id: 'attempt-1',
          testName: 'Reasoning Mock 1',
          percentageScore: 60,
          correct: 1,
          incorrect: 1,
          skipped: 1,
          calculatedAt: DateTime.utc(2026, 8, 1),
          reviews: [
            _review(
              id: 1,
              section: 'Reasoning',
              selected: 0,
              correct: 0,
              seconds: 10,
            ),
            _review(
              id: 2,
              section: 'Quantitative Aptitude',
              selected: 1,
              correct: 2,
              seconds: 20,
            ),
            _review(
              id: 3,
              section: 'Reasoning',
              selected: null,
              correct: 3,
              seconds: null,
            ),
          ],
        ),
        _result(
          id: 'attempt-2',
          testName: 'Reasoning Mock 2',
          percentageScore: 80,
          correct: 2,
          incorrect: 0,
          skipped: 0,
          calculatedAt: DateTime.utc(2026, 8, 2),
          reviews: [
            _review(
              id: 4,
              section: 'Reasoning',
              selected: 2,
              correct: 2,
              seconds: 30,
            ),
            _review(
              id: 5,
              section: 'Quantitative Aptitude',
              selected: 1,
              correct: 1,
              seconds: 40,
            ),
          ],
        ),
      ]);

      expect(analytics.totalTestsAttempted, 2);
      expect(analytics.averageScore, 70);
      expect(analytics.averageAccuracy, 75);
      expect(analytics.totalCorrect, 3);
      expect(analytics.totalIncorrect, 1);
      expect(analytics.totalUnanswered, 1);
      expect(analytics.totalQuestions, 5);
      expect(analytics.averageTimePerQuestion, 25);
      expect(analytics.latestAttemptId, 'attempt-2');
      expect(analytics.latestTestName, 'Reasoning Mock 2');
      expect(analytics.scoreTrend.map((point) => point.attemptId), [
        'attempt-1',
        'attempt-2',
      ]);
      expect(analytics.latestScoreChange, 20);

      final reasoning = analytics.sectionPerformance.singleWhere(
        (section) => section.name == 'Reasoning',
      );
      expect(reasoning.correct, 2);
      expect(reasoning.incorrect, 0);
      expect(reasoning.unanswered, 1);
      expect(reasoning.accuracy, 100);
      expect(reasoning.averageTimePerQuestion, 20);

      final quant = analytics.sectionPerformance.singleWhere(
        (section) => section.name == 'Quantitative Aptitude',
      );
      expect(quant.correct, 1);
      expect(quant.incorrect, 1);
      expect(quant.unanswered, 0);
      expect(quant.accuracy, 50);
      expect(quant.averageTimePerQuestion, 30);

      expect(analytics.strongestSection?.name, 'Reasoning');
      expect(analytics.weakestSection?.name, 'Quantitative Aptitude');
      expect(analytics.updatedAt, DateTime.utc(2026, 8, 2));
    });

    test('keeps only the eight most recent trend points', () {
      final results = List<Result>.generate(
        10,
        (index) => _result(
          id: 'attempt-${index + 1}',
          testName: 'Mock ${index + 1}',
          percentageScore: (index + 1) * 5,
          correct: 1,
          incorrect: 0,
          skipped: 0,
          calculatedAt: DateTime.utc(2026, 7, index + 1),
          reviews: [
            _review(
              id: index,
              section: 'Reasoning',
              selected: 0,
              correct: 0,
              seconds: 10,
            ),
          ],
        ),
      );

      final analytics = PerformanceAnalytics.fromResults('student-1', results);

      expect(analytics.scoreTrend, hasLength(8));
      expect(analytics.scoreTrend.first.attemptId, 'attempt-3');
      expect(analytics.scoreTrend.last.attemptId, 'attempt-10');
      expect(analytics.latestScoreChange, 5);
    });

    test('returns a truthful empty state', () {
      final analytics = PerformanceAnalytics.fromResults(
        'student-2',
        const [],
      );

      expect(analytics.totalTestsAttempted, 0);
      expect(analytics.totalQuestions, 0);
      expect(analytics.averageScore, 0);
      expect(analytics.averageAccuracy, 0);
      expect(analytics.scoreTrend, isEmpty);
      expect(analytics.sectionPerformance, isEmpty);
      expect(analytics.latestAttemptId, isNull);
      expect(analytics.strongestSection, isNull);
      expect(analytics.weakestSection, isNull);
      expect(analytics.updatedAt.millisecondsSinceEpoch, 0);
    });

    test('does not invent timing when snapshots omit it', () {
      final analytics = PerformanceAnalytics.fromResults('student-1', [
        _result(
          id: 'attempt-1',
          testName: 'Untimed test',
          percentageScore: 50,
          correct: 1,
          incorrect: 1,
          skipped: 0,
          calculatedAt: DateTime.utc(2026, 8, 3),
          reviews: [
            _review(
              id: 1,
              section: 'General',
              selected: 0,
              correct: 0,
              seconds: null,
            ),
            _review(
              id: 2,
              section: 'General',
              selected: 0,
              correct: 1,
              seconds: null,
            ),
          ],
        ),
      ]);

      expect(analytics.averageTimePerQuestion, 0);
      expect(analytics.hasTimingData, isFalse);
      expect(
        analytics.sectionPerformance.single.averageTimePerQuestion,
        0,
      );
    });
  });
}

Result _result({
  required String id,
  required String testName,
  required double percentageScore,
  required int correct,
  required int incorrect,
  required int skipped,
  required DateTime calculatedAt,
  required List<ResultQuestionReview> reviews,
}) {
  final answered = correct + incorrect;
  return Result(
    id: id,
    attemptId: id,
    userId: 'student-1',
    examId: 'test-$id',
    score: percentageScore,
    rawScore: percentageScore,
    maxScore: 100,
    percentageScore: percentageScore,
    accuracy: answered == 0 ? 0 : (correct / answered) * 100,
    totalQuestions: correct + incorrect + skipped,
    correctCount: correct,
    incorrectCount: incorrect,
    skippedCount: skipped,
    testName: testName,
    calculatedAt: calculatedAt,
    questionReview: reviews,
  );
}

ResultQuestionReview _review({
  required int id,
  required String section,
  required int? selected,
  required int correct,
  required int? seconds,
}) {
  return ResultQuestionReview(
    questionId: id,
    questionVersionId: 'version-$id',
    testQuestionId: 'test-question-$id',
    testSectionId: section,
    section: section,
    text: 'Question $id',
    options: const ['A', 'B', 'C', 'D'],
    optionKeys: const ['A', 'B', 'C', 'D'],
    selected: selected,
    selectedOptionKey: selected == null
        ? null
        : String.fromCharCode(65 + selected),
    correct: correct,
    correctOptionKey: String.fromCharCode(65 + correct),
    timeTakenSeconds: seconds,
    flagged: false,
    explanation: 'Explanation',
  );
}
