class LearnPracticeQuestion {
  const LearnPracticeQuestion({
    required this.id,
    required this.topicId,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });

  final String id;
  final String topicId;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  factory LearnPracticeQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions.map((item) => item.toString()).toList(growable: false)
        : const <String>[];
    return LearnPracticeQuestion(
      id: json['id']?.toString() ?? '',
      topicId: json['topicId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      options: options,
      correctOptionIndex:
          (json['correctOptionIndex'] as num?)?.toInt() ?? 0,
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}

abstract interface class LearnPracticeQuestionRepository {
  Future<List<LearnPracticeQuestion>> loadQuestions({
    required String topicId,
    required int limit,
    required String language,
    bool fresh = false,
  });
}
