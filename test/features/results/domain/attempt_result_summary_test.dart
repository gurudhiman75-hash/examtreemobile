import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/results/domain/attempt_result_summary.dart';
import 'package:flutter_test/flutter_test.dart';

ResultQuestionReview question({
  required String section,
  required int? selected,
  int correct = 1,
  int? seconds,
}) {
  return ResultQuestionReview(
    questionId: 1,
    questionVersionId: 'qv',
    testQuestionId: 'tq',
    testSectionId: section,
    section: section,
    text: 'Question',
    options: const ['A', 'B', 'C', 'D'],
    optionKeys: const ['A', 'B', 'C', 'D'],
    selected: selected,
    selectedOptionKey: selected == null ? null : 'ABCD'[selected],
    correct: correct,
    correctOptionKey: 'ABCD'[correct],
    timeTakenSeconds: seconds,
    flagged: false,
    explanation: '',
  );
}

Result result({
  String attemptId = 'current',
  DateTime? at,
  double percentage = 60,
  List<ResultQuestionReview> review = const [],
  List<ResultSectionStats> stats = const [],
  int? rank,
  double? percentile,
}) {
  return Result(
    id: attemptId,
    attemptId: attemptId,
    userId: 'u',
    examId: 'exam',
    score: percentage,
    maxScore: 100,
    accuracy: 0,
    correctCount: 0,
    incorrectCount: 0,
    skippedCount: 0,
    calculatedAt: at ?? DateTime.utc(2026, 11, 22),
    percentageScore: percentage,
    rawScore: percentage,
    rank: rank,
    percentile: percentile,
    questionReview: review,
    sectionStats: stats,
  );
}

void main() {
  group('question-level summary', () {
    final review = [
      // Reasoning: 2 correct, 1 wrong, 1 skipped
      question(section: 'Reasoning', selected: 1, seconds: 30),
      question(section: 'Reasoning', selected: 1, seconds: 60),
      question(section: 'Reasoning', selected: 0, seconds: 90),
      question(section: 'Reasoning', selected: null, seconds: 0),
      // Quant: 1 correct, 3 skipped
      question(section: 'Quant', selected: 1, seconds: 120),
      question(section: 'Quant', selected: null, seconds: 0),
      question(section: 'Quant', selected: null, seconds: 0),
      question(section: 'Quant', selected: null, seconds: 0),
    ];
    final summary = AttemptResultSummary.fromResult(result(review: review));

    test('counts outcomes from the review when result counts are zero', () {
      expect(summary.correct, 3);
      expect(summary.wrong, 1);
      expect(summary.skipped, 4);
      expect(summary.total, 8);
      expect(summary.accuracy, 75);
    });

    test('keeps sections in paper order with their own accuracy', () {
      expect(summary.sections.map((s) => s.name), ['Reasoning', 'Quant']);
      expect(summary.sections.first.accuracy, closeTo(66.67, 0.01));
      expect(summary.sections.last.accuracy, 100);
    });

    test('derives time totals and shares from measured seconds', () {
      expect(summary.totalSeconds, 300);
      expect(summary.sections.first.seconds, 180);
      expect(summary.sections.first.timeShare(300), closeTo(60, 0.01));
      expect(summary.largestTimeSection?.name, 'Reasoning');
      expect(summary.slowestQuestion?.section, 'Quant');
      expect(summary.slowestQuestion?.number, 1);
      expect(summary.slowestQuestion?.seconds, 120);
    });

    test('names the most skipped section only when it is unique', () {
      expect(summary.mostSkippedSection?.name, 'Quant');

      final tied = AttemptResultSummary.fromResult(
        result(
          review: [
            question(section: 'A', selected: null),
            question(section: 'B', selected: null),
          ],
        ),
      );
      expect(tied.mostSkippedSection, isNull);
    });

    test('weakest section needs at least two answered sections', () {
      expect(summary.weakestSection?.name, 'Reasoning');

      final single = AttemptResultSummary.fromResult(
        result(review: [question(section: 'A', selected: 1)]),
      );
      expect(single.weakestSection, isNull);
    });
  });

  group('missing data stays missing', () {
    test('no timing means no total, share or slowest question', () {
      final summary = AttemptResultSummary.fromResult(
        result(review: [question(section: 'A', selected: 1)]),
      );
      expect(summary.totalSeconds, isNull);
      expect(summary.hasTiming, isFalse);
      expect(summary.sections.single.seconds, isNull);
      expect(summary.sections.single.timeShare(null), isNull);
      expect(summary.slowestQuestion, isNull);
    });

    test('aggregate section stats work without question review', () {
      final summary = AttemptResultSummary.fromResult(
        result(
          stats: const [
            ResultSectionStats(
              name: 'Reasoning',
              correct: 10,
              wrong: 5,
              unanswered: 10,
              totalQuestions: 25,
              accuracy: 66.7,
            ),
          ],
        ),
      );
      expect(summary.sections.single.correct, 10);
      expect(summary.sections.single.questions, isEmpty);
      expect(summary.hasQuestionDetail, isFalse);
      expect(summary.hasTiming, isFalse);
    });

    test('a section with nothing answered has no accuracy', () {
      final summary = AttemptResultSummary.fromResult(
        result(review: [question(section: 'A', selected: null)]),
      );
      expect(summary.sections.single.accuracy, isNull);
    });
  });

  group('trend', () {
    Result attempt(String id, int day, double percentage) => result(
          attemptId: id,
          at: DateTime.utc(2026, 11, day),
          percentage: percentage,
        );

    test('is empty without an earlier attempt', () {
      final summary = AttemptResultSummary.fromResult(
        result(at: DateTime.utc(2026, 11, 22)),
        history: [attempt('later', 25, 80)],
      );
      expect(summary.trend, isEmpty);
      expect(summary.deltaVsPrevious, isNull);
    });

    test('keeps the latest six points oldest first and ends on this attempt', () {
      final history = [
        for (var day = 1; day <= 8; day++) attempt('a$day', day, day * 5.0),
        attempt('current', 22, 56.75),
      ];
      final summary = AttemptResultSummary.fromResult(
        history.last,
        history: history,
      );
      expect(summary.trend.length, 6);
      expect(summary.trend.first.attemptId, 'a4');
      expect(summary.trend.last.attemptId, 'current');
      expect(summary.trend.last.isCurrent, isTrue);
      expect(summary.deltaVsPrevious, closeTo(56.75 - 40, 0.001));
    });

    test('clamps percentages into 0-100', () {
      final summary = AttemptResultSummary.fromResult(
        result(percentage: 140),
        history: [attempt('old', 1, -5)],
      );
      expect(summary.trend.first.percentage, 0);
      expect(summary.trend.last.percentage, 100);
    });
  });
}
