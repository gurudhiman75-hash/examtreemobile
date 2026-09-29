import 'package:dio/dio.dart';

import '../domain/learn_practice_question.dart';

class ApiLearnPracticeQuestionRepository
    implements LearnPracticeQuestionRepository {
  ApiLearnPracticeQuestionRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<LearnPracticeQuestion>> loadQuestions({
    required String topicId,
    required int limit,
    required String language,
    bool fresh = false,
  }) async {
    final response = await _dio.get<Object?>(
      '/learn/practice/questions',
      queryParameters: {
        'topicId': topicId,
        'limit': limit,
        'language': language,
        if (fresh) 'fresh': '1',
      },
    );
    final data = response.data;
    final raw = data is Map
        ? data['questions']
        : data;
    if (raw is! List) return const <LearnPracticeQuestion>[];
    return raw
        .whereType<Map>()
        .map(
          (item) => LearnPracticeQuestion.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (question) =>
              question.id.isNotEmpty &&
              question.text.isNotEmpty &&
              question.options.length >= 2,
        )
        .toList(growable: false);
  }
}
