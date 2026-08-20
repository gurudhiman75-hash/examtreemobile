class ResultQuestionReview {
  const ResultQuestionReview({
    required this.questionId,
    required this.questionVersionId,
    required this.testQuestionId,
    required this.testSectionId,
    required this.section,
    required this.text,
    required this.options,
    required this.optionKeys,
    required this.selected,
    required this.selectedOptionKey,
    required this.correct,
    required this.correctOptionKey,
    required this.timeTakenSeconds,
    required this.flagged,
    required this.explanation,
    this.textHi,
    this.optionsHi,
    this.explanationHi,
    this.textPa,
    this.optionsPa,
    this.explanationPa,
  });

  final int questionId;
  final String questionVersionId;
  final String testQuestionId;
  final String testSectionId;
  final String section;
  final String text;
  final List<String> options;
  final List<String> optionKeys;
  final int? selected;
  final String? selectedOptionKey;
  final int correct;
  final String correctOptionKey;
  final int? timeTakenSeconds;
  final bool flagged;
  final String explanation;
  final String? textHi;
  final List<String>? optionsHi;
  final String? explanationHi;
  final String? textPa;
  final List<String>? optionsPa;
  final String? explanationPa;

  bool get isAnswered => selected != null;
  bool get isCorrect => selected != null && selected == correct;

  factory ResultQuestionReview.fromJson(Map<String, dynamic> json) {
    final options = _stringList(json['options']);
    final optionKeys = _stringList(json['optionKeys']);
    final rawSelected = json['selected'];

    return ResultQuestionReview(
      questionId: _asInt(json['questionId']),
      questionVersionId: _asString(json['questionVersionId']),
      testQuestionId: _asString(json['testQuestionId']),
      testSectionId: _asString(json['testSectionId']),
      section: _asString(json['section'], fallback: 'General'),
      text: _asString(json['text']),
      options: options,
      optionKeys: optionKeys.length == options.length
          ? optionKeys
          : List<String>.generate(
              options.length,
              (index) => String.fromCharCode(65 + index),
            ),
      selected: rawSelected == null ? null : _asInt(rawSelected),
      selectedOptionKey: json['selectedOptionKey']?.toString(),
      correct: _asInt(json['correct'], fallback: -1),
      correctOptionKey: _asString(json['correctOptionKey']),
      timeTakenSeconds: json['timeTakenSeconds'] == null
          ? null
          : _asInt(json['timeTakenSeconds']),
      flagged: json['flagged'] == true,
      explanation: _asString(json['explanation']),
      textHi: _nullableString(json['textHi']),
      optionsHi: json['optionsHi'] is List
          ? _stringList(json['optionsHi'])
          : null,
      explanationHi: _nullableString(json['explanationHi']),
      textPa: _nullableString(json['textPa']),
      optionsPa: json['optionsPa'] is List
          ? _stringList(json['optionsPa'])
          : null,
      explanationPa: _nullableString(json['explanationPa']),
    );
  }

  ResultQuestionReview copyWith({
    String? text,
    List<String>? options,
    String? explanation,
  }) {
    return ResultQuestionReview(
      questionId: questionId,
      questionVersionId: questionVersionId,
      testQuestionId: testQuestionId,
      testSectionId: testSectionId,
      section: section,
      text: text ?? this.text,
      options: options ?? this.options,
      optionKeys: optionKeys,
      selected: selected,
      selectedOptionKey: selectedOptionKey,
      correct: correct,
      correctOptionKey: correctOptionKey,
      timeTakenSeconds: timeTakenSeconds,
      flagged: flagged,
      explanation: explanation ?? this.explanation,
      textHi: textHi,
      optionsHi: optionsHi,
      explanationHi: explanationHi,
      textPa: textPa,
      optionsPa: optionsPa,
      explanationPa: explanationPa,
    );
  }
}

class ResultSectionStats {
  const ResultSectionStats({
    required this.name,
    required this.correct,
    required this.wrong,
    required this.unanswered,
    required this.totalQuestions,
    required this.accuracy,
  });

  final String name;
  final int correct;
  final int wrong;
  final int unanswered;
  final int totalQuestions;
  final double accuracy;

  factory ResultSectionStats.fromJson(Map<String, dynamic> json) {
    return ResultSectionStats(
      name: _asString(json['name'], fallback: 'General'),
      correct: _asInt(json['correct']),
      wrong: _asInt(json['wrong']),
      unanswered: _asInt(json['unanswered']),
      totalQuestions: _asInt(json['totalQuestions']),
      accuracy: _asDouble(json['accuracy']),
    );
  }
}

class Result {
  const Result({
    required this.id,
    required this.attemptId,
    required this.userId,
    required this.examId,
    required this.score,
    required this.maxScore,
    required this.accuracy,
    required this.correctCount,
    required this.incorrectCount,
    required this.skippedCount,
    required this.calculatedAt,
    this.testName = '',
    this.category = '',
    this.percentageScore = 0,
    this.rawScore = 0,
    this.totalQuestions = 0,
    this.attemptType = 'REAL',
    this.rank,
    this.percentile,
    this.questionReview = const [],
    this.sectionStats = const [],
  });

  final String id;
  final String attemptId;
  final String userId;
  final String examId;

  /// Kept for compatibility with existing screens. This is the raw score.
  final double score;
  final double maxScore;
  final double percentageScore;
  final double rawScore;
  final double accuracy;
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;
  final int skippedCount;
  final String testName;
  final String category;
  final String attemptType;
  final int? rank;
  final double? percentile;
  final DateTime calculatedAt;
  final List<ResultQuestionReview> questionReview;
  final List<ResultSectionStats> sectionStats;

  factory Result.fromJson(Map<String, dynamic> json) {
    final correct = _asInt(json['correct'] ?? json['correctCount']);
    final incorrect = _asInt(
      json['wrong'] ?? json['incorrect'] ?? json['incorrectCount'],
    );
    final skipped = _asInt(
      json['unanswered'] ?? json['skipped'] ?? json['skippedCount'],
    );
    final totalQuestions = _asInt(
      json['totalQuestions'],
      fallback: correct + incorrect + skipped,
    );
    final answered = correct + incorrect;
    final rawScore = _asDouble(json['actualScore'] ?? json['rawScore']);
    final maxScore = _asDouble(
      json['maxScore'],
      fallback: totalQuestions.toDouble(),
    );
    final percentageScore = _asDouble(
      json['score'] ?? json['percentageScore'],
      fallback: maxScore > 0 ? (rawScore / maxScore) * 100 : 0,
    );
    final questionReview = _mapList(json['questionReview'])
        .map(ResultQuestionReview.fromJson)
        .toList(growable: false);
    final sectionStats = _mapList(json['sectionStats'])
        .map(ResultSectionStats.fromJson)
        .toList(growable: false);
    final attemptId = _asString(json['id'] ?? json['attemptId']);

    return Result(
      id: attemptId,
      attemptId: attemptId,
      userId: _asString(json['userId']),
      examId: _asString(json['testId'] ?? json['examId']),
      score: rawScore,
      rawScore: rawScore,
      maxScore: maxScore,
      percentageScore: percentageScore,
      accuracy: _asDouble(
        json['accuracy'],
        fallback: answered == 0 ? 0 : (correct / answered) * 100,
      ),
      totalQuestions: totalQuestions,
      correctCount: correct,
      incorrectCount: incorrect,
      skippedCount: skipped,
      testName: _asString(json['testName'], fallback: 'Test result'),
      category: _asString(json['category']),
      attemptType: _asString(json['attemptType'], fallback: 'REAL'),
      rank: json['rank'] == null ? null : _asInt(json['rank']),
      percentile: json['percentile'] == null
          ? null
          : _asDouble(json['percentile']),
      calculatedAt: DateTime.tryParse(
            _asString(json['submittedAt'] ?? json['calculatedAt']),
          ) ??
          DateTime.tryParse(_asString(json['createdAt'])) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      questionReview: questionReview,
      sectionStats: sectionStats,
    );
  }

  Result copyWith({List<ResultQuestionReview>? questionReview}) {
    return Result(
      id: id,
      attemptId: attemptId,
      userId: userId,
      examId: examId,
      score: score,
      maxScore: maxScore,
      accuracy: accuracy,
      correctCount: correctCount,
      incorrectCount: incorrectCount,
      skippedCount: skippedCount,
      calculatedAt: calculatedAt,
      testName: testName,
      category: category,
      percentageScore: percentageScore,
      rawScore: rawScore,
      totalQuestions: totalQuestions,
      attemptType: attemptType,
      rank: rank,
      percentile: percentile,
      questionReview: questionReview ?? this.questionReview,
      sectionStats: sectionStats,
    );
  }
}

String _asString(Object? value, {String fallback = ''}) {
  final text = value?.toString();
  return text == null || text.isEmpty ? fallback : text;
}

String? _nullableString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList(growable: false);
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
