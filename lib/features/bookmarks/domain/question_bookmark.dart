import '../../../core/models/result_model.dart';

/// A question the learner saved for revision from the answer review.
///
/// The full question, options, answer and explanations in every available
/// language are copied at save time, so a bookmark opens offline and keeps
/// working even if the attempt is later unavailable.
class QuestionBookmark {
  const QuestionBookmark({
    required this.id,
    required this.question,
    required this.testName,
    required this.attemptId,
    required this.savedAt,
  });

  final String id;
  final ResultQuestionReview question;
  final String testName;
  final String attemptId;
  final DateTime savedAt;

  String get section => question.section;

  /// Stable key for a question, shared across tests that reuse it.
  static String idFor(ResultQuestionReview question) {
    if (question.questionVersionId.trim().isNotEmpty) {
      return 'qv:${question.questionVersionId.trim()}';
    }
    if (question.testQuestionId.trim().isNotEmpty) {
      return 'tq:${question.testQuestionId.trim()}';
    }
    return 'q:${question.questionId}';
  }

  factory QuestionBookmark.fromReview({
    required ResultQuestionReview question,
    required String testName,
    required String attemptId,
    DateTime? savedAt,
  }) {
    return QuestionBookmark(
      id: idFor(question),
      question: question,
      testName: testName,
      attemptId: attemptId,
      savedAt: savedAt ?? DateTime.now(),
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'testName': testName,
    'attemptId': attemptId,
    'savedAt': savedAt.toUtc().toIso8601String(),
    'question': {
      'questionId': question.questionId,
      'questionVersionId': question.questionVersionId,
      'testQuestionId': question.testQuestionId,
      'testSectionId': question.testSectionId,
      'section': question.section,
      'text': question.text,
      'options': question.options,
      'optionKeys': question.optionKeys,
      'selected': question.selected,
      'selectedOptionKey': question.selectedOptionKey,
      'correct': question.correct,
      'correctOptionKey': question.correctOptionKey,
      'timeTakenSeconds': question.timeTakenSeconds,
      'flagged': question.flagged,
      'explanation': question.explanation,
      'textHi': question.textHi,
      'optionsHi': question.optionsHi,
      'explanationHi': question.explanationHi,
      'textPa': question.textPa,
      'optionsPa': question.optionsPa,
      'explanationPa': question.explanationPa,
    },
  };

  static QuestionBookmark? tryFromJson(Object? value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    final rawQuestion = json['question'];
    if (rawQuestion is! Map) return null;
    final question = ResultQuestionReview.fromJson(
      Map<String, dynamic>.from(rawQuestion),
    );
    if (question.text.trim().isEmpty) return null;
    return QuestionBookmark(
      id: (json['id'] as String?)?.trim().isNotEmpty == true
          ? json['id'] as String
          : idFor(question),
      question: question,
      testName: json['testName']?.toString() ?? '',
      attemptId: json['attemptId']?.toString() ?? '',
      savedAt:
          DateTime.tryParse(json['savedAt']?.toString() ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
