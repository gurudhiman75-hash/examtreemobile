import '../models/analytics_model.dart';
import 'analytics_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<Analytics> getUserAnalytics(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Analytics(
      id: 'analytics_1',
      userId: userId,
      totalTestsAttempted: 14,
      averageScore: 82.5,
      averageAccuracy: 88.5,
      topicPerformance: const {
        'Algebra': 90.0,
        'Geometry': 75.0,
        'Calculus': 95.0,
      },
      strongestTopics: const ['Calculus', 'Algebra'],
      weakestTopics: const ['Geometry'],
      averageTimePerQuestion: 45,
      updatedAt: DateTime.now(),
    );
  }
}
