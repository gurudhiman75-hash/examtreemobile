import '../../../core/models/question_model.dart';
import '../../../core/models/result_model.dart';

enum QuestionLanguage {
  english('English', 'EN'),
  hindi('हिन्दी', 'HI'),
  punjabi('ਪੰਜਾਬੀ', 'PA');

  const QuestionLanguage(this.label, this.shortLabel);

  final String label;
  final String shortLabel;

  static QuestionLanguage fromStorage(String? value) {
    return QuestionLanguage.values.firstWhere(
      (language) => language.name == value,
      orElse: () => QuestionLanguage.english,
    );
  }
}

Question localizeQuestion(Question question, QuestionLanguage language) {
  final localized = switch (language) {
    QuestionLanguage.english => null,
    QuestionLanguage.hindi => (
        text: _usableText(question.textHi),
        options: _usableOptions(question.optionsHi, question.options.length),
        explanation: _usableText(question.explanationHi),
      ),
    QuestionLanguage.punjabi => (
        text: _usableText(question.textPa),
        options: _usableOptions(question.optionsPa, question.options.length),
        explanation: _usableText(question.explanationPa),
      ),
  };

  if (localized == null) return question;
  return question.copyWith(
    text: localized.text ?? question.text,
    options: localized.options ?? question.options,
    explanation: localized.explanation ?? question.explanation,
  );
}

Result localizeResult(Result result, QuestionLanguage language) {
  if (language == QuestionLanguage.english || result.questionReview.isEmpty) {
    return result;
  }

  return result.copyWith(
    questionReview: result.questionReview
        .map((question) => localizeResultQuestion(question, language))
        .toList(growable: false),
  );
}

ResultQuestionReview localizeResultQuestion(
  ResultQuestionReview question,
  QuestionLanguage language,
) {
  final localized = switch (language) {
    QuestionLanguage.english => null,
    QuestionLanguage.hindi => (
        text: _usableText(question.textHi),
        options: _usableOptions(question.optionsHi, question.options.length),
        explanation: _usableText(question.explanationHi),
      ),
    QuestionLanguage.punjabi => (
        text: _usableText(question.textPa),
        options: _usableOptions(question.optionsPa, question.options.length),
        explanation: _usableText(question.explanationPa),
      ),
  };

  if (localized == null) return question;
  return question.copyWith(
    text: localized.text ?? question.text,
    options: localized.options ?? question.options,
    explanation: localized.explanation ?? question.explanation,
  );
}

String? _usableText(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? null : text;
}

List<String>? _usableOptions(List<String>? value, int expectedLength) {
  if (value == null || value.length != expectedLength || value.isEmpty) {
    return null;
  }
  final normalized = value.map((option) => option.trim()).toList(growable: false);
  return normalized.any((option) => option.isEmpty) ? null : normalized;
}
