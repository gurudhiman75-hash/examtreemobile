import '../../../core/models/exam_model.dart';
import '../../../core/models/result_model.dart';

enum HomePrimaryActionKind { resumeTest, reviewResult, startTest, browseTests }

class HomePrimaryAction {
  const HomePrimaryAction({
    required this.kind,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actionLabel,
    this.exam,
    this.result,
  });

  final HomePrimaryActionKind kind;
  final String eyebrow;
  final String title;
  final String description;
  final String actionLabel;
  final Exam? exam;
  final Result? result;
}

HomePrimaryAction resolveHomePrimaryAction({
  required Iterable<Exam> activeTests,
  required Iterable<Result> results,
  required Iterable<Exam> availableTests,
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
      eyebrow: 'Recommended next',
      title: available.first.title,
      description:
          'Start with a focused paper selected from the tests currently available to you.',
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
