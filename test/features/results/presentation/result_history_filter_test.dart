import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/results/presentation/result_history_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Result result({
    required String id,
    required String testName,
    required String category,
    required double score,
    required double accuracy,
    required DateTime calculatedAt,
    String attemptType = 'REAL',
  }) {
    return Result(
      id: id,
      attemptId: id,
      userId: 'student-1',
      examId: 'exam-$id',
      score: score,
      rawScore: score,
      maxScore: 100,
      percentageScore: score,
      accuracy: accuracy,
      totalQuestions: 100,
      correctCount: accuracy.round(),
      incorrectCount: 100 - accuracy.round(),
      skippedCount: 0,
      testName: testName,
      category: category,
      attemptType: attemptType,
      calculatedAt: calculatedAt,
    );
  }

  final now = DateTime.utc(2026, 7, 28);
  late List<Result> results;

  setUp(() {
    results = [
      result(
        id: 'ssc-new',
        testName: 'SSC CHSL Mock 2',
        category: 'SSC',
        score: 68,
        accuracy: 72,
        calculatedAt: now,
      ),
      result(
        id: 'punjab-best',
        testName: 'Punjab Patwari Mock',
        category: 'Punjab Exams',
        score: 86,
        accuracy: 90,
        calculatedAt: now.subtract(const Duration(days: 2)),
      ),
      result(
        id: 'ssc-old',
        testName: 'SSC Reasoning Sprint',
        category: 'SSC',
        score: 74,
        accuracy: 80,
        calculatedAt: now.subtract(const Duration(days: 1)),
        attemptType: 'PRACTICE',
      ),
    ];
  });

  test('returns unique categories alphabetically', () {
    expect(resultCategories(results), ['Punjab Exams', 'SSC']);
  });

  test('searches test name, category and attempt type', () {
    expect(
      filterAndSortResults(results: results, query: 'reasoning')
          .map((item) => item.id),
      ['ssc-old'],
    );
    expect(
      filterAndSortResults(results: results, query: 'practice')
          .map((item) => item.id),
      ['ssc-old'],
    );
  });

  test('combines category filtering with newest ordering', () {
    expect(
      filterAndSortResults(results: results, category: 'SSC')
          .map((item) => item.id),
      ['ssc-new', 'ssc-old'],
    );
  });

  test('supports score and accuracy sorting', () {
    expect(
      filterAndSortResults(
        results: results,
        sort: ResultSortOption.highestScore,
      ).map((item) => item.id),
      ['punjab-best', 'ssc-old', 'ssc-new'],
    );
    expect(
      filterAndSortResults(
        results: results,
        sort: ResultSortOption.highestAccuracy,
      ).map((item) => item.id),
      ['punjab-best', 'ssc-old', 'ssc-new'],
    );
  });

  test('builds canonical aggregate summary', () {
    final summary = ResultHistorySummary.fromResults(results);
    expect(summary.totalAttempts, 3);
    expect(summary.averageScore, closeTo(76, 0.001));
    expect(summary.bestScore, 86);
    expect(summary.averageAccuracy, closeTo(80.6667, 0.001));
  });

  test('returns zero summary for empty history', () {
    final summary = ResultHistorySummary.fromResults(const []);
    expect(summary.totalAttempts, 0);
    expect(summary.averageScore, 0);
    expect(summary.bestScore, 0);
    expect(summary.averageAccuracy, 0);
  });
}
