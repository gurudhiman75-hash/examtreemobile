import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/exam_model.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/providers/repository_providers.dart';

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
  return repository.getExamQuestions(examId);
});
