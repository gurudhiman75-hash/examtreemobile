import '../models/analytics_model.dart';
import '../models/result_model.dart';
import 'analytics_repository.dart';
import 'result_repository.dart';

class CanonicalAnalyticsRepository implements AnalyticsRepository {
  const CanonicalAnalyticsRepository(this._resultRepository);

  final ResultRepository _resultRepository;

  @override
  Future<Analytics> getUserAnalytics(String userId) async {
    final results = await _resultRepository.getUserResults(userId);
    if (results.isEmpty) return _emptyAnalytics(userId);

    final averageScore = results
            .map((result) => result.percentageScore)
            .fold<double>(0, (sum, score) => sum + score) /
        results.length;

    var totalCorrect = 0;
    var totalIncorrect = 0;
    var totalQuestionSeconds = 0;
    var timedQuestions = 0;
    final sections = <String, _SectionAggregate>{};

    for (final result in results) {
      totalCorrect += result.correctCount;
      totalIncorrect += result.incorrectCount;

      for (final review in result.questionReview) {
        final timing = review.timeTakenSeconds;
        if (timing != null && timing >= 0) {
          totalQuestionSeconds += timing;
          timedQuestions++;
        }

        final sectionName = review.section.trim().isEmpty
            ? 'General'
            : review.section.trim();
        final aggregate = sections.putIfAbsent(
          sectionName,
          _SectionAggregate.new,
        );
        if (review.isAnswered) {
          aggregate.answered++;
          if (review.isCorrect) aggregate.correct++;
        }
      }
    }

    final answered = totalCorrect + totalIncorrect;
    final averageAccuracy = answered == 0
        ? 0.0
        : (totalCorrect / answered) * 100;

    final topicPerformance = <String, double>{
      for (final entry in sections.entries)
        if (entry.value.answered > 0)
          entry.key: (entry.value.correct / entry.value.answered) * 100,
    };
    final rankedSections = topicPerformance.entries.toList()
      ..sort((a, b) {
        final accuracyComparison = b.value.compareTo(a.value);
        if (accuracyComparison != 0) return accuracyComparison;
        return a.key.compareTo(b.key);
      });

    final strongestTopics = rankedSections
        .take(3)
        .map((entry) => entry.key)
        .toList(growable: false);
    final weakestTopics = rankedSections.reversed
        .take(3)
        .map((entry) => entry.key)
        .toList(growable: false);

    final latestUpdate = results
        .map((result) => result.calculatedAt)
        .reduce((latest, value) => value.isAfter(latest) ? value : latest);

    return Analytics(
      id: 'canonical-results:$userId',
      userId: userId,
      totalTestsAttempted: results.length,
      averageScore: averageScore,
      averageAccuracy: averageAccuracy,
      topicPerformance: topicPerformance,
      strongestTopics: strongestTopics,
      weakestTopics: weakestTopics,
      averageTimePerQuestion: timedQuestions == 0
          ? 0
          : (totalQuestionSeconds / timedQuestions).round(),
      updatedAt: latestUpdate,
    );
  }

  Analytics _emptyAnalytics(String userId) {
    return Analytics(
      id: 'canonical-results:$userId',
      userId: userId,
      totalTestsAttempted: 0,
      averageScore: 0,
      averageAccuracy: 0,
      averageTimePerQuestion: 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

class _SectionAggregate {
  int correct = 0;
  int answered = 0;
}
