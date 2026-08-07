import 'package:examtree/features/test_attempt/domain/test_attempt_experience.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttemptSubmissionSummary', () {
    test('counts every exam status without overlap', () {
      final states = [
        QuestionState(status: QuestionStatus.notVisited),
        QuestionState(status: QuestionStatus.notAnswered),
        QuestionState(
          selectedOptionIndex: 1,
          status: QuestionStatus.answered,
        ),
        QuestionState(status: QuestionStatus.markedForReview),
        QuestionState(
          selectedOptionIndex: 2,
          status: QuestionStatus.answeredAndMarkedForReview,
        ),
      ];

      final summary = AttemptSubmissionSummary.fromStates(states);

      expect(summary.total, 5);
      expect(summary.totalAnswered, 2);
      expect(summary.totalUnanswered, 3);
      expect(summary.totalMarked, 2);
      expect(summary.answeredAndMarkedForReview, 1);
      expect(summary.hasUnanswered, isTrue);
    });

    test('reports no unanswered questions for a complete attempt', () {
      final summary = AttemptSubmissionSummary.fromStates([
        QuestionState(status: QuestionStatus.answered),
        QuestionState(status: QuestionStatus.answeredAndMarkedForReview),
      ]);

      expect(summary.totalAnswered, 2);
      expect(summary.totalUnanswered, 0);
      expect(summary.hasUnanswered, isFalse);
    });
  });

  group('palette filters', () {
    test('unanswered includes marked without an answer', () {
      expect(
        matchesPaletteFilter(
          QuestionStatus.markedForReview,
          PaletteFilter.unanswered,
        ),
        isTrue,
      );
      expect(
        matchesPaletteFilter(
          QuestionStatus.answeredAndMarkedForReview,
          PaletteFilter.unanswered,
        ),
        isFalse,
      );
    });

    test('marked includes both marked states', () {
      expect(
        matchesPaletteFilter(
          QuestionStatus.markedForReview,
          PaletteFilter.marked,
        ),
        isTrue,
      );
      expect(
        matchesPaletteFilter(
          QuestionStatus.answeredAndMarkedForReview,
          PaletteFilter.marked,
        ),
        isTrue,
      );
      expect(
        matchesPaletteFilter(
          QuestionStatus.answered,
          PaletteFilter.marked,
        ),
        isFalse,
      );
    });
  });

  group('timer warnings', () {
    test('detects each threshold only when crossed', () {
      expect(
        crossedTimerWarningThreshold(
          previousSeconds: 601,
          currentSeconds: 600,
        ),
        600,
      );
      expect(
        crossedTimerWarningThreshold(
          previousSeconds: 301,
          currentSeconds: 300,
        ),
        300,
      );
      expect(
        crossedTimerWarningThreshold(
          previousSeconds: 61,
          currentSeconds: 60,
        ),
        60,
      );
      expect(
        crossedTimerWarningThreshold(
          previousSeconds: 59,
          currentSeconds: 58,
        ),
        isNull,
      );
    });

    test('does not repeat a warning already shown', () {
      expect(
        crossedTimerWarningThreshold(
          previousSeconds: 601,
          currentSeconds: 600,
          alreadyShown: const {600},
        ),
        isNull,
      );
    });

    test('selects the most urgent warning when resuming', () {
      expect(
        currentTimerWarningThreshold(secondsRemaining: 540),
        600,
      );
      expect(
        currentTimerWarningThreshold(secondsRemaining: 240),
        300,
      );
      expect(
        currentTimerWarningThreshold(secondsRemaining: 45),
        60,
      );
      expect(
        currentTimerWarningThreshold(
          secondsRemaining: 45,
          alreadyShown: const {60},
        ),
        isNull,
      );
      expect(currentTimerWarningThreshold(secondsRemaining: 0), isNull);
    });
  });
}
