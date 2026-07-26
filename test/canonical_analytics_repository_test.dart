import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/core/repositories/canonical_analytics_repository.dart';
import 'package:examtree/core/repositories/result_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CanonicalAnalyticsRepository', () {
    test('aggregates canonical result snapshots', () async {
      final repository = CanonicalAnalyticsRepository(
        _FakeResultRepository([
          _result(
            id: 'attempt-1',
            percentageScore: 60,
            correct: 1,
            incorrect: 1,
            calculatedAt: DateTime.utc(2026, 7, 25),
            reviews: [
              _review(
                id: 1,
                section: 'Quantitative Aptitude',
                selected: 1,
                correct: 1,
                seconds: 10,
              ),
              _review(
                id: 2,
                section: 'Reasoning',
                selected: 0,
                correct: 1,
                seconds: 20,
              ),
            ],
          ),
          _result(
            id: 'attempt-2',
            percentageScore: 80,
            correct: 2,
            incorrect: 0,
            calculatedAt: DateTime.utc(2026, 7, 26),
            reviews: [
              _review(
                id: 3,
                section: 'Quantitative Aptitude',
                selected: 2,
                correct: 2,
                seconds: 30,
              ),
              _review(
                id: 4,
                section: 'Reasoning',
                selected: 3,
                correct: 3,
                seconds: 40,
              ),
            ],
          ),
        ]),
      );

      final analytics = await repository.getUserAnalytics('student-1');

      expect(analytics.totalTestsAttempted, 2);
      expect(analytics.averageScore, 70);
      expect(analytics.averageAccuracy, 75);
      expect(analytics.averageTimePerQuestion, 25);
      expect(
        analytics.topicPerformance['Quantitative Aptitude'],
        100,
      );
      expect(analytics.topicPerformance['Reasoning'], 50);
      expect(analytics.strongestTopics.first, 'Quantitative Aptitude');
      expect(analytics.weakestTopics.first, 'Reasoning');
      expect(analytics.updatedAt, DateTime.utc(2026, 7, 26));
    });

    test('returns an empty profile when no results exist', () async {
      final repository = CanonicalAnalyticsRepository(
        _FakeResultRepository(const []),
      );

      final analytics = await repository.getUserAnalytics('student-2');

      expect(analytics.totalTestsAttempted, 0);
      expect(analytics.averageScore, 0);
      expect(analytics.averageAccuracy, 0);
      expect(analytics.topicPerformance, isEmpty);
      expect(analytics.strongestTopics, isEmpty);
      expect(analytics.weakestTopics, isEmpty);
      expect(analytics.updatedAt.millisecondsSinceEpoch, 0);
    });
  });
}

Result _result({
  required String id,
  required double percentageScore,
  required int correct,
  required int incorrect,
  required DateTime calculatedAt,
  required List<ResultQuestionReview> reviews,
}) {
  return Result(
    id: id,
    attemptId: id,
    userId: 'student-1',
    examId: 'test-1',
    score: percentageScore,
    rawScore: percentageScore,
    maxScore: 100,
    percentageScore: percentageScore,
    accuracy: correct + incorrect == 0
        ? 0
        : (correct / (correct + incorrect)) * 100,
    totalQuestions: correct + incorrect,
    correctCount: correct,
    incorrectCount: incorrect,
    skippedCount: 0,
    calculatedAt: calculatedAt,
    questionReview: reviews,
  );
}

ResultQuestionReview _review({
  required int id,
  required String section,
  required int? selected,
  required int correct,
  required int seconds,
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

class _FakeResultRepository implements ResultRepository {
  const _FakeResultRepository(this.results);

  final List<Result> results;

  @override
  Future<Result> getResult(String attemptId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Result>> getUserResults(String userId) async => results;
}
