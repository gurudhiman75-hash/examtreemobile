import '../../../core/models/result_model.dart';

enum ReviewQuestionFilter { all, incorrect, unanswered, flagged }

extension ReviewQuestionFilterLabel on ReviewQuestionFilter {
  String get label => switch (this) {
        ReviewQuestionFilter.all => 'All',
        ReviewQuestionFilter.incorrect => 'Incorrect',
        ReviewQuestionFilter.unanswered => 'Unanswered',
        ReviewQuestionFilter.flagged => 'Flagged',
      };
}

List<int> reviewQuestionIndexes(
  List<ResultQuestionReview> questions,
  ReviewQuestionFilter filter,
) {
  final indexes = <int>[];
  for (var index = 0; index < questions.length; index += 1) {
    final question = questions[index];
    final include = switch (filter) {
      ReviewQuestionFilter.all => true,
      ReviewQuestionFilter.incorrect =>
        question.isAnswered && !question.isCorrect,
      ReviewQuestionFilter.unanswered => !question.isAnswered,
      ReviewQuestionFilter.flagged => question.flagged,
    };
    if (include) indexes.add(index);
  }
  return indexes;
}

int reviewQuestionCount(
  List<ResultQuestionReview> questions,
  ReviewQuestionFilter filter,
) {
  return reviewQuestionIndexes(questions, filter).length;
}
