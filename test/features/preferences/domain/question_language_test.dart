import 'package:examtree/core/models/question_model.dart';
import 'package:examtree/core/models/result_model.dart';
import 'package:examtree/features/preferences/domain/question_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Question question({List<String>? hindiOptions}) {
    return Question(
      id: 1,
      examId: 'exam-1',
      subject: 'Math',
      topic: 'Percentage',
      difficulty: 'Medium',
      text: 'What is 25% of 80?',
      options: const ['10', '20', '25', '40'],
      correctOptionIndexes: const [1],
      explanation: '25% of 80 is 20.',
      points: 1,
      textHi: '80 का 25% कितना है?',
      optionsHi: hindiOptions ?? const ['10', '20', '25', '40'],
      explanationHi: '80 का 25% 20 है।',
      textPa: '80 ਦਾ 25% ਕਿੰਨਾ ਹੈ?',
      optionsPa: const ['10', '20', '25', '40'],
      explanationPa: '80 ਦਾ 25% 20 ਹੈ।',
    );
  }

  Result result() {
    return Result(
      id: 'attempt-1',
      attemptId: 'attempt-1',
      userId: 'student-1',
      examId: 'exam-1',
      score: 1,
      maxScore: 1,
      accuracy: 100,
      correctCount: 1,
      incorrectCount: 0,
      skippedCount: 0,
      calculatedAt: DateTime.utc(2026, 8, 20),
      questionReview: const [
        ResultQuestionReview(
          questionId: 1,
          questionVersionId: 'qv-1',
          testQuestionId: 'tq-1',
          testSectionId: 'section-1',
          section: 'Math',
          text: 'What is 25% of 80?',
          options: ['10', '20', '25', '40'],
          optionKeys: ['A', 'B', 'C', 'D'],
          selected: 1,
          selectedOptionKey: 'B',
          correct: 1,
          correctOptionKey: 'B',
          timeTakenSeconds: 18,
          flagged: true,
          explanation: '25% of 80 is 20.',
          textHi: '80 का 25% कितना है?',
          optionsHi: ['10', '20', '25', '40'],
          explanationHi: '80 का 25% 20 है।',
          textPa: '80 ਦਾ 25% ਕਿੰਨਾ ਹੈ?',
          optionsPa: ['10', '20', '25', '40'],
          explanationPa: '80 ਦਾ 25% 20 ਹੈ।',
        ),
      ],
    );
  }

  test('Hindi localizes question text, options and explanation', () {
    final localized = localizeQuestion(question(), QuestionLanguage.hindi);

    expect(localized.text, '80 का 25% कितना है?');
    expect(localized.options, const ['10', '20', '25', '40']);
    expect(localized.explanation, '80 का 25% 20 है।');
    expect(localized.correctOptionIndexes, const [1]);
  });

  test('Punjabi localizes answer review without changing answer state', () {
    final localized = localizeResult(result(), QuestionLanguage.punjabi);
    final review = localized.questionReview.single;

    expect(review.text, '80 ਦਾ 25% ਕਿੰਨਾ ਹੈ?');
    expect(review.explanation, '80 ਦਾ 25% 20 ਹੈ।');
    expect(review.selected, 1);
    expect(review.correct, 1);
    expect(review.flagged, isTrue);
  });

  test('incomplete localized options fall back to complete English question', () {
    final localized = localizeQuestion(
      question(hindiOptions: const ['10', '20']),
      QuestionLanguage.hindi,
    );

    expect(localized.text, '80 का 25% कितना है?');
    expect(localized.options, const ['10', '20', '25', '40']);
    expect(localized.correctOptionIndexes, const [1]);
  });

  test('unknown persisted language falls back to English', () {
    expect(
      QuestionLanguage.fromStorage('unsupported'),
      QuestionLanguage.english,
    );
  });
}
