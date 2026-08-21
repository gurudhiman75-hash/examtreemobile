import 'package:dio/dio.dart';

import '../models/exam_api_dto.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import 'exam_repository.dart';

class ExamRepositoryException implements Exception {
  const ExamRepositoryException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class ExamLoginRequiredException extends ExamRepositoryException {
  const ExamLoginRequiredException()
      : super('Sign in required to open this test', statusCode: 401, code: 'LOGIN_REQUIRED');
}

class ExamPaymentRequiredException extends ExamRepositoryException {
  const ExamPaymentRequiredException({required this.testId, this.priceCents})
      : super('Purchase required to access this test', statusCode: 403, code: 'PAYMENT_REQUIRED');

  final String testId;
  final int? priceCents;
}

class ApiExamRepository implements ExamRepository {
  ApiExamRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Exam>> getAvailableExams() async {
    return _request(() async {
      final responses = await Future.wait([
        _dio.get<List<dynamic>>('/categories'),
        _dio.get<List<dynamic>>('/subcategories'),
        _dio.get<List<dynamic>>('/tests'),
      ]);
      final categories = _categoryMap(responses[0].data);
      final subcategories = _subcategoryMap(responses[1].data);
      return _testList(responses[2].data)
          .map(
            (test) => _toExam(
              test,
              categories: categories,
              subcategories: subcategories,
            ),
          )
          .toList();
    });
  }

  @override
  Future<List<Exam>> getInProgressExams() async {
    // Draft sync owns resumable attempts; this repository only loads exam catalog/detail data.
    return const [];
  }

  @override
  Future<Exam> getExamDetails(String examId) async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>('/tests/$examId');
      return _toExam(TestDto.fromJson(response.data ?? {}));
    });
  }

  @override
  Future<List<Question>> getExamQuestions(String examId) async {
    return _request(() async {
      final response = await _dio.get<Map<String, dynamic>>('/tests/$examId');
      return TestDto.fromJson(response.data ?? {}).toQuestions();
    });
  }

  Exam _toExam(
    TestDto test, {
    Map<String, CategoryDto> categories = const {},
    Map<String, SubcategoryDto> subcategories = const {},
  }) {
    final exam = test.toExam(
      categories: categories,
      subcategories: subcategories,
    );
    final canonicalExamCode = test.subcategoryId?.trim();
    if (canonicalExamCode == null || canonicalExamCode.isEmpty) return exam;
    final identityTag = 'exam-code:$canonicalExamCode';
    if (exam.tags.contains(identityTag)) return exam;
    return exam.copyWith(tags: [...exam.tags, identityTag]);
  }

  Future<T> _request<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (error) {
      throw ExamRepositoryException('Failed to load exam data: $error');
    }
  }

  Exception _mapDioError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final body = data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{};
    final code = body['code']?.toString();

    if (status == 401 && code == 'LOGIN_REQUIRED') {
      return const ExamLoginRequiredException();
    }

    if (status == 403 && code == 'PAYMENT_REQUIRED') {
      return ExamPaymentRequiredException(
        testId: body['testId']?.toString() ?? '',
        priceCents: body['priceCents'] is num ? (body['priceCents'] as num).toInt() : null,
      );
    }

    final message = body['error']?.toString() ?? error.message ?? 'Failed to load exam data';
    return ExamRepositoryException(message, statusCode: status, code: code);
  }

  List<TestDto> _testList(Object? data) {
    if (data is! List) return const [];
    return data.whereType<Map>().map((item) => TestDto.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  Map<String, CategoryDto> _categoryMap(Object? data) {
    if (data is! List) return const {};
    return {
      for (final item in data.whereType<Map>())
        CategoryDto.fromJson(Map<String, dynamic>.from(item)).id: CategoryDto.fromJson(Map<String, dynamic>.from(item)),
    };
  }

  Map<String, SubcategoryDto> _subcategoryMap(Object? data) {
    if (data is! List) return const {};
    return {
      for (final item in data.whereType<Map>())
        SubcategoryDto.fromJson(Map<String, dynamic>.from(item)).id: SubcategoryDto.fromJson(Map<String, dynamic>.from(item)),
    };
  }
}
