import '../models/analytics_model.dart';

abstract class AnalyticsRepository {
  Future<Analytics> getUserAnalytics(String userId);
}
