import 'dart:math' as math;

import '../../../core/models/result_model.dart';

enum RevisionReason {
  incorrect,
  unanswered,
  flagged,
  slow;

  String get label => switch (this) {
        RevisionReason.incorrect => 'Incorrect',
        RevisionReason.unanswered => 'Unanswered',
        RevisionReason.flagged => 'Flagged',
        RevisionReason.slow => 'Slow',
      };
}

class StudyCompanionSettings {
  const StudyCompanionSettings({
    this.dailyQuestionGoal = 10,
    this.reminderEnabled = false,
    this.reminderHour = 19,
    this.reminderMinute = 0,
    this.reminderWeekdays = const {1, 2, 3, 4, 5, 6, 7},
  });

  final int dailyQuestionGoal;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final Set<int> reminderWeekdays;

  StudyCompanionSettings copyWith({
    int? dailyQuestionGoal,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    Set<int>? reminderWeekdays,
  }) {
    return StudyCompanionSettings(
      dailyQuestionGoal: dailyQuestionGoal ?? this.dailyQuestionGoal,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      reminderWeekdays: reminderWeekdays ?? this.reminderWeekdays,
    );
  }
}

class RevisionItem {
  const RevisionItem({
    required this.id,
    required this.sourceAttemptId,
    required this.testId,
    required this.testName,
    required this.section,
    required this.questionText,
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    required this.explanation,
    required this.reasons,
    required this.timeTakenSeconds,
    required this.dueAt,
    required this.stage,
    required this.createdAt,
    this.lastReviewedAt,
  });

  final String id;
  final String sourceAttemptId;
  final String testId;
  final String testName;
  final String section;
  final String questionText;
  final List<String> options;
  final int? selectedIndex;
  final int correctIndex;
  final String explanation;
  final Set<RevisionReason> reasons;
  final int? timeTakenSeconds;
  final DateTime dueAt;
  final int stage;
  final DateTime createdAt;
  final DateTime? lastReviewedAt;

  bool isDue(DateTime now) => !dueAt.isAfter(now);

  RevisionItem copyWith({
    String? testName,
    String? section,
    String? questionText,
    List<String>? options,
    int? selectedIndex,
    bool clearSelectedIndex = false,
    int? correctIndex,
    String? explanation,
    Set<RevisionReason>? reasons,
    int? timeTakenSeconds,
    bool clearTimeTakenSeconds = false,
    DateTime? dueAt,
    int? stage,
    DateTime? lastReviewedAt,
  }) {
    return RevisionItem(
      id: id,
      sourceAttemptId: sourceAttemptId,
      testId: testId,
      testName: testName ?? this.testName,
      section: section ?? this.section,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      selectedIndex:
          clearSelectedIndex ? null : selectedIndex ?? this.selectedIndex,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      reasons: reasons ?? this.reasons,
      timeTakenSeconds: clearTimeTakenSeconds
          ? null
          : timeTakenSeconds ?? this.timeTakenSeconds,
      dueAt: dueAt ?? this.dueAt,
      stage: stage ?? this.stage,
      createdAt: createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }
}

class DailyCompanionSnapshot {
  const DailyCompanionSnapshot({
    required this.settings,
    required this.items,
    required this.completedToday,
  });

  final StudyCompanionSettings settings;
  final List<RevisionItem> items;
  final int completedToday;

  List<RevisionItem> dueItems(DateTime now) {
    final due = items.where((item) => item.isDue(now)).toList(growable: false);
    return [...due]
      ..sort((left, right) {
        final dueOrder = left.dueAt.compareTo(right.dueAt);
        if (dueOrder != 0) return dueOrder;
        return left.createdAt.compareTo(right.createdAt);
      });
  }

  int remainingGoal(DateTime now) =>
      math.max(0, settings.dailyQuestionGoal - completedToday);
}

List<RevisionItem> deriveRevisionCandidates(
  List<Result> results, {
  required DateTime now,
}) {
  final candidates = <RevisionItem>[];
  for (final result in results) {
    final positiveTimes = result.questionReview
        .map((question) => question.timeTakenSeconds)
        .whereType<int>()
        .where((seconds) => seconds > 0)
        .toList(growable: false);
    final averageSeconds = positiveTimes.isEmpty
        ? 0.0
        : positiveTimes.reduce((a, b) => a + b) / positiveTimes.length;
    final slowThreshold = math.max(60.0, averageSeconds * 1.5);

    for (final question in result.questionReview) {
      if (question.questionId < 0 || question.text.trim().isEmpty) continue;
      if (question.correct < 0 || question.correct >= question.options.length) {
        continue;
      }

      final reasons = <RevisionReason>{};
      if (!question.isAnswered) {
        reasons.add(RevisionReason.unanswered);
      } else if (!question.isCorrect) {
        reasons.add(RevisionReason.incorrect);
      }
      if (question.flagged) reasons.add(RevisionReason.flagged);
      final time = question.timeTakenSeconds;
      if (time != null && time > slowThreshold) {
        reasons.add(RevisionReason.slow);
      }
      if (reasons.isEmpty) continue;

      candidates.add(
        RevisionItem(
          id: '${result.attemptId}:${question.questionId}',
          sourceAttemptId: result.attemptId,
          testId: result.examId,
          testName: result.testName,
          section: question.section,
          questionText: question.text,
          options: question.options,
          selectedIndex: question.selected,
          correctIndex: question.correct,
          explanation: question.explanation,
          reasons: reasons,
          timeTakenSeconds: question.timeTakenSeconds,
          dueAt: now,
          stage: 0,
          createdAt: now,
        ),
      );
    }
  }
  return candidates;
}

RevisionItem mergeRevisionCandidate({
  required RevisionItem existing,
  required RevisionItem candidate,
}) {
  return RevisionItem(
    id: existing.id,
    sourceAttemptId: existing.sourceAttemptId,
    testId: candidate.testId,
    testName: candidate.testName,
    section: candidate.section,
    questionText: candidate.questionText,
    options: candidate.options,
    selectedIndex: candidate.selectedIndex,
    correctIndex: candidate.correctIndex,
    explanation: candidate.explanation,
    reasons: candidate.reasons,
    timeTakenSeconds: candidate.timeTakenSeconds,
    dueAt: existing.dueAt,
    stage: existing.stage,
    createdAt: existing.createdAt,
    lastReviewedAt: existing.lastReviewedAt,
  );
}

RevisionItem applyRevisionOutcome(
  RevisionItem item, {
  required bool remembered,
  required DateTime reviewedAt,
}) {
  if (!remembered) {
    return RevisionItem(
      id: item.id,
      sourceAttemptId: item.sourceAttemptId,
      testId: item.testId,
      testName: item.testName,
      section: item.section,
      questionText: item.questionText,
      options: item.options,
      selectedIndex: item.selectedIndex,
      correctIndex: item.correctIndex,
      explanation: item.explanation,
      reasons: item.reasons,
      timeTakenSeconds: item.timeTakenSeconds,
      dueAt: reviewedAt.add(const Duration(days: 1)),
      stage: 0,
      createdAt: item.createdAt,
      lastReviewedAt: reviewedAt,
    );
  }

  const intervals = [1, 3, 7, 14, 30, 60];
  final nextStage = math.min(item.stage + 1, intervals.length);
  final intervalIndex = math.min(item.stage, intervals.length - 1);
  return RevisionItem(
    id: item.id,
    sourceAttemptId: item.sourceAttemptId,
    testId: item.testId,
    testName: item.testName,
    section: item.section,
    questionText: item.questionText,
    options: item.options,
    selectedIndex: item.selectedIndex,
    correctIndex: item.correctIndex,
    explanation: item.explanation,
    reasons: item.reasons,
    timeTakenSeconds: item.timeTakenSeconds,
    dueAt: reviewedAt.add(Duration(days: intervals[intervalIndex])),
    stage: nextStage,
    createdAt: item.createdAt,
    lastReviewedAt: reviewedAt,
  );
}

List<RevisionItem> selectQuickRevisionItems(
  List<RevisionItem> items, {
  required int minutes,
  required DateTime now,
}) {
  final due = items.where((item) => item.isDue(now)).toList(growable: false)
    ..sort((left, right) {
      final stageOrder = left.stage.compareTo(right.stage);
      if (stageOrder != 0) return stageOrder;
      return left.dueAt.compareTo(right.dueAt);
    });
  final limit = minutes.clamp(1, 30);
  return due.take(limit).toList(growable: false);
}
