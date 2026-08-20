import '../../../core/models/exam_model.dart';
import '../../../core/models/result_model.dart';

enum HomePrimaryActionKind {
  resumeTest,
  reviewResult,
  reviseDue,
  startTest,
  browseTests,
}

class HomePrimaryAction {
  const HomePrimaryAction({
    required this.kind,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actionLabel,
    this.exam,
    this.result,
    this.dueRevisionCount = 0,
  });

  final HomePrimaryActionKind kind;
  final String eyebrow;
  final String title;
  final String description;
  final String actionLabel;
  final Exam? exam;
  final Result? result;
  final int dueRevisionCount;
}

HomePrimaryAction resolveHomePrimaryAction({
  required Iterable<Exam> activeTests,
  required Iterable<Result> results,
  required Iterable<Exam> availableTests,
  int dueRevisionCount = 0,
  DateTime? now,
  Duration reviewWindow = const Duration(hours: 24),
}) {
  final active = activeTests.toList(growable: false);
  if (active.isNotEmpty) {
    return HomePrimaryAction(
      kind: HomePrimaryActionKind.resumeTest,
      eyebrow: 'Continue now',
      title: active.first.title,
      description:
          'Your active attempt is saved. Resume from the point where you stopped.',
      actionLabel: 'Resume test',
      exam: active.first,
    );
  }

  final sortedResults = results.toList()
    ..sort((left, right) => right.calculatedAt.compareTo(left.calculatedAt));
  if (sortedResults.isNotEmpty) {
    final latest = sortedResults.first;
    final referenceTime = now ?? DateTime.now();
    final age = referenceTime.difference(latest.calculatedAt.toLocal());
    final isRecent = latest.calculatedAt.millisecondsSinceEpoch > 0 &&
        !age.isNegative &&
        age <= reviewWindow;
    if (isRecent) {
      return HomePrimaryAction(
        kind: HomePrimaryActionKind.reviewResult,
        eyebrow: 'Review while it is fresh',
        title: latest.testName.trim().isEmpty
            ? 'Your latest result'
            : latest.testName,
        description:
            'Inspect incorrect and unanswered questions, then turn them into the next practice plan.',
        actionLabel: 'Review result',
        result: latest,
      );
    }
  }

  final normalizedDueCount = dueRevisionCount < 0 ? 0 : dueRevisionCount;
  if (normalizedDueCount > 0) {
    return HomePrimaryAction(
      kind: HomePrimaryActionKind.reviseDue,
      eyebrow: 'Due for revision',
      title: '$normalizedDueCount ${normalizedDueCount == 1 ? 'question' : 'questions'} to revisit',
      description:
          'Strengthen mistakes you have already found before adding another test.',
      actionLabel: 'Start revision',
      dueRevisionCount: normalizedDueCount,
    );
  }

  final available = availableTests.toList()
    ..sort((left, right) {
      final leftPaid = left.status.trim().toLowerCase() == 'paid' ? 1 : 0;
      final rightPaid = right.status.trim().toLowerCase() == 'paid' ? 1 : 0;
      if (leftPaid != rightPaid) return leftPaid.compareTo(rightPaid);
      final updated = right.updatedAt.compareTo(left.updatedAt);
      if (updated != 0) return updated;
      return left.title.toLowerCase().compareTo(right.title.toLowerCase());
    });

  if (available.isNotEmpty) {
    return HomePrimaryAction(
      kind: HomePrimaryActionKind.startTest,
      eyebrow: 'Next test',
      title: available.first.title,
      description:
          'Open a focused paper from the tests currently available to you.',
      actionLabel: 'View test',
      exam: available.first,
    );
  }

  return const HomePrimaryAction(
    kind: HomePrimaryActionKind.browseTests,
    eyebrow: 'Build your next session',
    title: 'Choose your next test',
    description:
        'Explore the catalogue for live mocks, sectional tests and practice papers.',
    actionLabel: 'Browse tests',
  );
}
