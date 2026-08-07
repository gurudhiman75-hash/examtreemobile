enum QuestionStatus {
  notVisited,
  notAnswered,
  answered,
  markedForReview,
  answeredAndMarkedForReview,
}

class QuestionState {
  QuestionState({
    this.selectedOptionIndex,
    this.status = QuestionStatus.notVisited,
  });

  int? selectedOptionIndex;
  QuestionStatus status;
}

enum PaletteFilter { all, unanswered, marked }

class AttemptSubmissionSummary {
  const AttemptSubmissionSummary({
    required this.notVisited,
    required this.notAnswered,
    required this.answered,
    required this.markedForReview,
    required this.answeredAndMarkedForReview,
  });

  final int notVisited;
  final int notAnswered;
  final int answered;
  final int markedForReview;
  final int answeredAndMarkedForReview;

  int get total =>
      notVisited +
      notAnswered +
      answered +
      markedForReview +
      answeredAndMarkedForReview;

  int get totalAnswered => answered + answeredAndMarkedForReview;

  int get totalUnanswered => notVisited + notAnswered + markedForReview;

  int get totalMarked => markedForReview + answeredAndMarkedForReview;

  bool get hasUnanswered => totalUnanswered > 0;

  factory AttemptSubmissionSummary.fromStates(List<QuestionState> states) {
    var notVisited = 0;
    var notAnswered = 0;
    var answered = 0;
    var markedForReview = 0;
    var answeredAndMarkedForReview = 0;

    for (final state in states) {
      switch (state.status) {
        case QuestionStatus.notVisited:
          notVisited++;
        case QuestionStatus.notAnswered:
          notAnswered++;
        case QuestionStatus.answered:
          answered++;
        case QuestionStatus.markedForReview:
          markedForReview++;
        case QuestionStatus.answeredAndMarkedForReview:
          answeredAndMarkedForReview++;
      }
    }

    return AttemptSubmissionSummary(
      notVisited: notVisited,
      notAnswered: notAnswered,
      answered: answered,
      markedForReview: markedForReview,
      answeredAndMarkedForReview: answeredAndMarkedForReview,
    );
  }
}

bool matchesPaletteFilter(QuestionStatus status, PaletteFilter filter) {
  switch (filter) {
    case PaletteFilter.all:
      return true;
    case PaletteFilter.unanswered:
      return status == QuestionStatus.notVisited ||
          status == QuestionStatus.notAnswered ||
          status == QuestionStatus.markedForReview;
    case PaletteFilter.marked:
      return status == QuestionStatus.markedForReview ||
          status == QuestionStatus.answeredAndMarkedForReview;
  }
}

int? crossedTimerWarningThreshold({
  required int previousSeconds,
  required int currentSeconds,
  Set<int> alreadyShown = const <int>{},
}) {
  for (final threshold in const [600, 300, 60]) {
    if (!alreadyShown.contains(threshold) &&
        previousSeconds > threshold &&
        currentSeconds <= threshold) {
      return threshold;
    }
  }
  return null;
}

int? currentTimerWarningThreshold({
  required int secondsRemaining,
  Set<int> alreadyShown = const <int>{},
}) {
  if (secondsRemaining <= 0) return null;
  for (final threshold in const [60, 300, 600]) {
    if (secondsRemaining <= threshold && !alreadyShown.contains(threshold)) {
      return threshold;
    }
  }
  return null;
}
