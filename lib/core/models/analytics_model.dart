import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_model.freezed.dart';
part 'analytics_model.g.dart';

@freezed
abstract class Analytics with _$Analytics {
  const factory Analytics({
    required String id,
    required String userId,
    required int totalTestsAttempted,
    required double averageScore,
    required double averageAccuracy,
    @Default({}) Map<String, double> topicPerformance,
    @Default([]) List<String> strongestTopics,
    @Default([]) List<String> weakestTopics,
    required int averageTimePerQuestion,
    required DateTime updatedAt,
  }) = _Analytics;

  factory Analytics.fromJson(Map<String, dynamic> json) => _$AnalyticsFromJson(json);
}
