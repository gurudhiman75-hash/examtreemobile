import '../../../core/models/result_model.dart';

class PerformanceTrendPoint {
  const PerformanceTrendPoint({
    required this.attemptId,
    required this.testName,
    required this.percentageScore,
    required this.accuracy,
    required this.completedAt,
  });

  final String attemptId;
  final String testName;
  final double percentageScore;
  final double accuracy;
  final DateTime completedAt;
}

class SectionPerformance {
  const SectionPerformance({
    required this.name,
    required this.correct,
    required this.incorrect,
    required this.unanswered,
    required this.timedQuestions,
    required this.totalTimeSeconds,
  });

  final String name;
  final int correct;
  final int incorrect;
  final int unanswered;
  final int timedQuestions;
  final int totalTimeSeconds;

  int get totalQuestions => correct + incorrect + unanswered;
  int get answered => correct + incorrect;

  double get accuracy => answered == 0 ? 0 : (correct / answered) * 100;

  int get averageTimePerQuestion => timedQuestions == 0
      ? 0
      : (totalTimeSeconds / timedQuestions).round();
}

class PerformanceAnalytics {
  const PerformanceAnalytics({
    required this.userId,
    required this.totalTestsAttempted,
    required this.averageScore,
    required this.averageAccuracy,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.totalUnanswered,
    required this.averageTimePerQuestion,
    required this.scoreTrend,
    required this.sectionPerformance,
    required this.updatedAt,
    this.latestAttemptId,
    this.latestTestName,
  });

  final String userId;
  final int totalTestsAttempted;
  final double averageScore;
  final double averageAccuracy;
  final int totalCorrect;
  final int totalIncorrect;
  final int totalUnanswered;
  final int averageTimePerQuestion;
  final List<PerformanceTrendPoint> scoreTrend;
  final List<SectionPerformance> sectionPerformance;
  final DateTime updatedAt;
  final String? latestAttemptId;
  final String? latestTestName;

  int get totalQuestions => totalCorrect + totalIncorrect + totalUnanswered;
  int get totalAnswered => totalCorrect + totalIncorrect;
  bool get hasTimingData => averageTimePerQuestion > 0;

  SectionPerformance? get strongestSection {
    final ranked = _rankedAnsweredSections();
    return ranked.isEmpty ? null : ranked.first;
  }

  SectionPerformance? get weakestSection {
    final ranked = _rankedAnsweredSections();
    return ranked.isEmpty ? null : ranked.last;
  }

  double? get latestScoreChange {
    if (scoreTrend.length < 2) return null;
    return scoreTrend.last.percentageScore -
        scoreTrend[scoreTrend.length - 2].percentageScore;
  }

  factory PerformanceAnalytics.fromResults(
    String userId,
    List<Result> results,
  ) {
    if (results.isEmpty) return PerformanceAnalytics.empty(userId);

    final orderedResults = List<Result>.of(results)
      ..sort((a, b) => a.calculatedAt.compareTo(b.calculatedAt));

    var totalCorrect = 0;
    var totalIncorrect = 0;
    var totalUnanswered = 0;
    var totalQuestionSeconds = 0;
    var timedQuestions = 0;
    var scoreTotal = 0.0;
    final sections = <String, _MutableSectionPerformance>{};

    for (final result in orderedResults) {
      scoreTotal += result.percentageScore;
      totalCorrect += result.correctCount;
      totalIncorrect += result.incorrectCount;
      totalUnanswered += result.skippedCount;

      for (final review in result.questionReview) {
        final sectionName = review.section.trim().isEmpty
            ? 'General'
            : review.section.trim();
        final section = sections.putIfAbsent(
          sectionName,
          () => _MutableSectionPerformance(sectionName),
        );

        if (!review.isAnswered) {
          section.unanswered++;
        } else if (review.isCorrect) {
          section.correct++;
        } else {
          section.incorrect++;
        }

        final seconds = review.timeTakenSeconds;
        if (seconds != null && seconds >= 0) {
          totalQuestionSeconds += seconds;
          timedQuestions++;
          section.totalTimeSeconds += seconds;
          section.timedQuestions++;
        }
      }
    }

    final answered = totalCorrect + totalIncorrect;
    final sectionPerformance = sections.values
        .map((section) => section.freeze())
        .toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
    final recentResults = orderedResults.length <= 8
        ? orderedResults
        : orderedResults.sublist(orderedResults.length - 8);
    final latest = orderedResults.last;

    return PerformanceAnalytics(
      userId: userId,
      totalTestsAttempted: orderedResults.length,
      averageScore: scoreTotal / orderedResults.length,
      averageAccuracy: answered == 0 ? 0 : (totalCorrect / answered) * 100,
      totalCorrect: totalCorrect,
      totalIncorrect: totalIncorrect,
      totalUnanswered: totalUnanswered,
      averageTimePerQuestion: timedQuestions == 0
          ? 0
          : (totalQuestionSeconds / timedQuestions).round(),
      scoreTrend: recentResults
          .map(
            (result) => PerformanceTrendPoint(
              attemptId: result.attemptId,
              testName: result.testName.trim().isEmpty
                  ? 'Test result'
                  : result.testName.trim(),
              percentageScore: result.percentageScore,
              accuracy: result.accuracy,
              completedAt: result.calculatedAt,
            ),
          )
          .toList(growable: false),
      sectionPerformance: sectionPerformance,
      latestAttemptId: latest.attemptId,
      latestTestName: latest.testName.trim().isEmpty
          ? 'Latest result'
          : latest.testName.trim(),
      updatedAt: latest.calculatedAt,
    );
  }

  factory PerformanceAnalytics.empty(String userId) {
    return PerformanceAnalytics(
      userId: userId,
      totalTestsAttempted: 0,
      averageScore: 0,
      averageAccuracy: 0,
      totalCorrect: 0,
      totalIncorrect: 0,
      totalUnanswered: 0,
      averageTimePerQuestion: 0,
      scoreTrend: const [],
      sectionPerformance: const [],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  List<SectionPerformance> _rankedAnsweredSections() {
    final ranked = sectionPerformance
        .where((section) => section.answered > 0)
        .toList(growable: false)
      ..sort((a, b) {
        final accuracyComparison = b.accuracy.compareTo(a.accuracy);
        if (accuracyComparison != 0) return accuracyComparison;
        final volumeComparison = b.answered.compareTo(a.answered);
        if (volumeComparison != 0) return volumeComparison;
        return a.name.compareTo(b.name);
      });
    return ranked;
  }
}

class _MutableSectionPerformance {
  _MutableSectionPerformance(this.name);

  final String name;
  int correct = 0;
  int incorrect = 0;
  int unanswered = 0;
  int timedQuestions = 0;
  int totalTimeSeconds = 0;

  SectionPerformance freeze() {
    return SectionPerformance(
      name: name,
      correct: correct,
      incorrect: incorrect,
      unanswered: unanswered,
      timedQuestions: timedQuestions,
      totalTimeSeconds: totalTimeSeconds,
    );
  }
}
