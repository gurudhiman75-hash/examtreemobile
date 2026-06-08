import '../models/exam_model.dart';
import '../models/question_model.dart';
import 'exam_repository.dart';

class MockExamRepository implements ExamRepository {
  @override
  Future<List<Exam>> getAvailableExams() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Exam(
        id: 'exam_1',
        title: 'General Science Foundation',
        description: 'A comprehensive science foundation test for competitive exams.',
        durationInSeconds: 3600,
        totalQuestions: 30,
        totalMarks: 30.0,
        maxAttempts: 3,
        negativeMarking: 0.25,
        difficulty: 'Medium',
        status: 'published',
        category: 'Science',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Exam(
        id: 'exam_2',
        title: 'History of the Modern World',
        description: 'Covers major historical events from 1500 to present.',
        durationInSeconds: 5400,
        totalQuestions: 40,
        totalMarks: 40.0,
        maxAttempts: 2,
        negativeMarking: 0.33,
        difficulty: 'Hard',
        status: 'published',
        category: 'History',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<Exam>> getInProgressExams() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Exam(
        id: 'exam_3',
        title: 'Advanced Mathematics Level 2',
        description: 'A comprehensive math test covering calculus and algebra.',
        durationInSeconds: 7200,
        totalQuestions: 50,
        totalMarks: 100.0,
        maxAttempts: 3,
        negativeMarking: 0.25,
        difficulty: 'Advanced',
        status: 'published',
        category: 'Mathematics',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<Exam> getExamDetails(String examId) async {
    final available = await getAvailableExams();
    final inProgress = await getInProgressExams();
    final allExams = [...available, ...inProgress];
    
    return allExams.firstWhere(
      (e) => e.id == examId, 
      orElse: () => allExams.first,
    );
  }

  @override
  Future<List<Question>> getExamQuestions(String examId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(
      50,
      (index) => Question(
        id: 'q_$index',
        examId: examId,
        subject: 'Mathematics',
        topic: 'Calculus',
        difficulty: 'Advanced',
        text: 'This is a sample question text for Question ${index + 1}. Which of the following options is correct?',
        options: ['Option A: 42', 'Option B: 3.14', 'Option C: Infinity', 'Option D: Zero'],
        correctOptionIndexes: [0],
        explanation: 'According to the underlying mathematical principles, option A represents the precise output of the integral function.',
        points: 2.0,
      ),
    );
  }
}
