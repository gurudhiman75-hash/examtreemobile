import '../models/exam_model.dart';
import '../models/question_model.dart';

abstract class ExamRepository {
  Future<List<Exam>> getAvailableExams();
  Future<List<Exam>> getInProgressExams();
  Future<Exam> getExamDetails(String examId, {String? seriesId});
  Future<List<Question>> getExamQuestions(String examId, {String? seriesId});
}
