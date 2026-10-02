import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/exam_model.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../preferences/domain/question_language.dart';
import '../../../preferences/presentation/providers/question_language_providers.dart';

final availableExamsProvider = FutureProvider<List<Exam>>((ref) async {
  final repository = ref.watch(examRepositoryProvider);
  return repository.getAvailableExams();
});

final inProgressExamsProvider = FutureProvider<List<Exam>>((ref) async {
  final repository = ref.watch(examRepositoryProvider);
  return repository.getInProgressExams();
});

final examDetailsProvider = FutureProvider.family<Exam, String>((ref, examId) async {
  final repository = ref.watch(examRepositoryProvider);
  return repository.getExamDetails(examId);
});

final examQuestionsProvider = FutureProvider.family<List<Question>, String>((ref, examId) async {
  final repository = ref.watch(examRepositoryProvider);
  final language = await ref.watch(questionLanguageProvider.future);
  final questions = await repository.getExamQuestions(examId);
  return questions
      .map((question) => localizeQuestion(question, language))
      .toList(growable: false);
});

typedef ExamAccessKey = ({String examId, String? seriesId});

final contextualExamDetailsProvider =
    FutureProvider.family<Exam, ExamAccessKey>((ref, key) async {
  final repository = ref.watch(examRepositoryProvider);
  return repository.getExamDetails(key.examId, seriesId: key.seriesId);
});

final contextualExamQuestionsProvider =
    FutureProvider.family<List<Question>, ExamAccessKey>((ref, key) async {
  final repository = ref.watch(examRepositoryProvider);
  final language = await ref.watch(questionLanguageProvider.future);
  final questions =
      await repository.getExamQuestions(key.examId, seriesId: key.seriesId);
  return questions
      .map((question) => localizeQuestion(question, language))
      .toList(growable: false);
});
