import '../../../core/models/result_model.dart';

enum QuestionOutcome { correct, wrong, skipped }

/// One question in paper order, reduced to what the result charts need.
class PacedQuestion {
  const PacedQuestion({
    required this.number,
    required this.outcome,
    required this.seconds,
  });

  /// 1-based position inside its section.
  final int number;
  final QuestionOutcome outcome;

  /// Null when the attempt snapshot has no timing for this question.
  final int? seconds;
}

class SectionSummary {
  const SectionSummary({
    required this.name,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.questions,
    required this.seconds,
  });

  final String name;
  final int correct;
  final int wrong;
  final int skipped;

  /// Question-level detail. Empty when only aggregate section stats exist.
  final List<PacedQuestion> questions;

  /// Sum of measured question times. Null when no question has timing.
  final int? seconds;

  int get total => correct + wrong + skipped;
  int get answered => correct + wrong;

  /// Percentage of answered questions that were correct, or null when nothing
  /// in the section was answered (zero is never shown as a measured accuracy).
  double? get accuracy => answered == 0 ? null : correct / answered * 100;

  /// This section's share (0-100) of the attempt's measured time, or null.
  double? timeShare(int? totalSeconds) {
    if (seconds == null || totalSeconds == null || totalSeconds == 0) {
      return null;
    }
    return seconds! / totalSeconds * 100;
  }
}

class TrendPoint {
  const TrendPoint({
    required this.attemptId,
    required this.date,
    required this.percentage,
    required this.isCurrent,
  });

  final String attemptId;
  final DateTime date;
  final double percentage;
  final bool isCurrent;
}

class SlowestQuestion {
  const SlowestQuestion({
    required this.section,
    required this.number,
    required this.seconds,
  });

  final String section;
  final int number;
  final int seconds;
}

/// Pure view-model for the single-attempt result screen.
///
/// Everything here is derived from the immutable [Result] snapshot (and the
/// learner's own history for the trend). Rank and percentile are passed
/// through only when the API supplied them; nothing is estimated.
class AttemptResultSummary {
  const AttemptResultSummary({
    required this.result,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.sections,
    required this.totalSeconds,
    required this.trend,
  });

  static const int maxTrendPoints = 6;

  final Result result;
  final int correct;
  final int wrong;
  final int skipped;
  final List<SectionSummary> sections;

  /// Sum of measured question times, or null when the snapshot has none.
  final int? totalSeconds;

  /// Oldest first, current attempt last. Empty unless at least two points.
  final List<TrendPoint> trend;

  int get total => correct + wrong + skipped;
  int get answered => correct + wrong;

  double get accuracy =>
      answered == 0 ? 0 : correct / answered * 100;

  bool get hasQuestionDetail =>
      sections.any((section) => section.questions.isNotEmpty);

  bool get hasTiming => totalSeconds != null;

  /// Change in score percentage against the attempt just before this one.
  double? get deltaVsPrevious {
    if (trend.length < 2) return null;
    return trend.last.percentage - trend[trend.length - 2].percentage;
  }

  /// The section with the most skipped questions, only when it is unique.
  SectionSummary? get mostSkippedSection {
    SectionSummary? best;
    var tie = false;
    for (final section in sections) {
      if (section.skipped == 0) continue;
      if (best == null || section.skipped > best.skipped) {
        best = section;
        tie = false;
      } else if (section.skipped == best.skipped) {
        tie = true;
      }
    }
    return tie ? null : best;
  }

  /// The answered section with the lowest accuracy (needs two or more).
  SectionSummary? get weakestSection {
    final candidates =
        sections.where((section) => section.accuracy != null).toList();
    if (candidates.length < 2) return null;
    candidates.sort((a, b) => a.accuracy!.compareTo(b.accuracy!));
    return candidates.first;
  }

  SectionSummary? get largestTimeSection {
    final candidates =
        sections.where((section) => section.seconds != null).toList();
    if (candidates.length < 2) return null;
    candidates.sort((a, b) => b.seconds!.compareTo(a.seconds!));
    return candidates.first;
  }

  SlowestQuestion? get slowestQuestion {
    SlowestQuestion? slowest;
    for (final section in sections) {
      for (final question in section.questions) {
        final seconds = question.seconds;
        if (seconds == null || seconds <= 0) continue;
        if (slowest == null || seconds > slowest.seconds) {
          slowest = SlowestQuestion(
            section: section.name,
            number: question.number,
            seconds: seconds,
          );
        }
      }
    }
    return slowest;
  }

  factory AttemptResultSummary.fromResult(
    Result result, {
    Iterable<Result> history = const [],
  }) {
    final sections = _buildSections(result);
    final totalSeconds = _totalSeconds(result);

    var correct = result.correctCount;
    var wrong = result.incorrectCount;
    var skipped = result.skippedCount;
    if (correct + wrong + skipped == 0 && result.questionReview.isNotEmpty) {
      correct = result.questionReview.where((q) => q.isCorrect).length;
      wrong = result.questionReview
          .where((q) => q.isAnswered && !q.isCorrect)
          .length;
      skipped = result.questionReview.where((q) => !q.isAnswered).length;
    }

    return AttemptResultSummary(
      result: result,
      correct: correct,
      wrong: wrong,
      skipped: skipped,
      sections: sections,
      totalSeconds: totalSeconds,
      trend: _buildTrend(result, history),
    );
  }

  static int? _totalSeconds(Result result) {
    var seen = false;
    var sum = 0;
    for (final question in result.questionReview) {
      final seconds = question.timeTakenSeconds;
      if (seconds == null) continue;
      seen = true;
      sum += seconds;
    }
    return seen ? sum : null;
  }

  static List<SectionSummary> _buildSections(Result result) {
    final grouped = <String, List<ResultQuestionReview>>{};
    for (final question in result.questionReview) {
      grouped.putIfAbsent(question.section, () => []).add(question);
    }

    final statsByName = {
      for (final stats in result.sectionStats) stats.name: stats,
    };
    final names = <String>[
      ...result.sectionStats.map((stats) => stats.name),
      ...grouped.keys.where((name) => !statsByName.containsKey(name)),
    ];

    return names.map((name) {
      final reviews = grouped[name] ?? const <ResultQuestionReview>[];
      final stats = statsByName[name];

      final questions = <PacedQuestion>[
        for (var i = 0; i < reviews.length; i++)
          PacedQuestion(
            number: i + 1,
            outcome: !reviews[i].isAnswered
                ? QuestionOutcome.skipped
                : reviews[i].isCorrect
                    ? QuestionOutcome.correct
                    : QuestionOutcome.wrong,
            seconds: reviews[i].timeTakenSeconds,
          ),
      ];

      int? seconds;
      for (final question in questions) {
        if (question.seconds == null) continue;
        seconds = (seconds ?? 0) + question.seconds!;
      }

      return SectionSummary(
        name: name,
        correct: stats?.correct ??
            questions
                .where((q) => q.outcome == QuestionOutcome.correct)
                .length,
        wrong: stats?.wrong ??
            questions.where((q) => q.outcome == QuestionOutcome.wrong).length,
        skipped: stats?.unanswered ??
            questions
                .where((q) => q.outcome == QuestionOutcome.skipped)
                .length,
        questions: questions,
        seconds: seconds,
      );
    }).toList(growable: false);
  }

  static List<TrendPoint> _buildTrend(
    Result current,
    Iterable<Result> history,
  ) {
    final earlier = history
        .where(
          (item) =>
              item.attemptId != current.attemptId &&
              item.calculatedAt.isBefore(current.calculatedAt),
        )
        .toList()
      ..sort((a, b) => a.calculatedAt.compareTo(b.calculatedAt));

    final recent = earlier.length > maxTrendPoints - 1
        ? earlier.sublist(earlier.length - (maxTrendPoints - 1))
        : earlier;
    if (recent.isEmpty) return const [];

    return [
      for (final item in recent)
        TrendPoint(
          attemptId: item.attemptId,
          date: item.calculatedAt,
          percentage: item.percentageScore.clamp(0, 100).toDouble(),
          isCurrent: false,
        ),
      TrendPoint(
        attemptId: current.attemptId,
        date: current.calculatedAt,
        percentage: current.percentageScore.clamp(0, 100).toDouble(),
        isCurrent: true,
      ),
    ];
  }
}
