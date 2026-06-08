import '../models/result_model.dart';

abstract class ResultRepository {
  Future<Result> getResult(String attemptId);
  Future<List<Result>> getUserResults(String userId);
}
