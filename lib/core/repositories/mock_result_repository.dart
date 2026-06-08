import '../models/result_model.dart';
import 'result_repository.dart';

class MockResultRepository implements ResultRepository {
  @override
  Future<Result> getResult(String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      attemptId: attemptId,
      userId: 'user_1',
      examId: 'exam_1',
      score: 125.0,
      maxScore: 150.0,
      accuracy: 88.5,
      correctCount: 35,
      incorrectCount: 5,
      skippedCount: 10,
      rank: 42,
      percentile: 95.8,
      calculatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Result>> getUserResults(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Result(
        id: 'res_1',
        attemptId: 'att_1',
        userId: userId,
        examId: 'exam_1',
        score: 92.0,
        maxScore: 100.0,
        accuracy: 92.0,
        correctCount: 46,
        incorrectCount: 4,
        skippedCount: 0,
        calculatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Result(
        id: 'res_2',
        attemptId: 'att_2',
        userId: userId,
        examId: 'exam_2',
        score: 75.0,
        maxScore: 100.0,
        accuracy: 75.0,
        correctCount: 30,
        incorrectCount: 10,
        skippedCount: 0,
        calculatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
