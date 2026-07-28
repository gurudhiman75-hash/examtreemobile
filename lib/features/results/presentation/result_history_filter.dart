import '../../../core/models/result_model.dart';

enum ResultSortOption { newest, highestScore, highestAccuracy }

extension ResultSortOptionLabel on ResultSortOption {
  String get label => switch (this) {
        ResultSortOption.newest => 'Newest',
        ResultSortOption.highestScore => 'Highest score',
        ResultSortOption.highestAccuracy => 'Highest accuracy',
      };
}

class ResultHistorySummary {
  const ResultHistorySummary({
    required this.totalAttempts,
    required this.averageScore,
    required this.bestScore,
    required this.averageAccuracy,
  });

  final int totalAttempts;
  final double averageScore;
  final double bestScore;
  final double averageAccuracy;

  factory ResultHistorySummary.fromResults(Iterable<Result> results) {
    final list = results.toList(growable: false);
    if (list.isEmpty) {
      return const ResultHistorySummary(
        totalAttempts: 0,
        averageScore: 0,
        bestScore: 0,
        averageAccuracy: 0,
      );
    }

    final totalScore = list.fold<double>(
      0,
      (sum, result) => sum + result.percentageScore,
    );
    final totalAccuracy = list.fold<double>(
      0,
      (sum, result) => sum + result.accuracy,
    );
    final bestScore = list
        .map((result) => result.percentageScore)
        .reduce((left, right) => left > right ? left : right);

    return ResultHistorySummary(
      totalAttempts: list.length,
      averageScore: totalScore / list.length,
      bestScore: bestScore,
      averageAccuracy: totalAccuracy / list.length,
    );
  }
}

List<String> resultCategories(Iterable<Result> results) {
  final categories = results
      .map((result) => result.category.trim())
      .where((category) => category.isNotEmpty)
      .toSet()
      .toList()
    ..sort((left, right) => left.toLowerCase().compareTo(right.toLowerCase()));
  return categories;
}

List<Result> filterAndSortResults({
  required Iterable<Result> results,
  String query = '',
  String? category,
  ResultSortOption sort = ResultSortOption.newest,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final normalizedCategory = category?.trim().toLowerCase();

  final filtered = results.where((result) {
    if (normalizedCategory != null &&
        normalizedCategory.isNotEmpty &&
        result.category.trim().toLowerCase() != normalizedCategory) {
      return false;
    }

    if (normalizedQuery.isEmpty) return true;
    final searchable = <String>[
      result.testName,
      result.category,
      result.attemptType,
    ].join(' ').toLowerCase();
    return searchable.contains(normalizedQuery);
  }).toList();

  int compareNewest(Result left, Result right) {
    final date = right.calculatedAt.compareTo(left.calculatedAt);
    if (date != 0) return date;
    return left.testName.toLowerCase().compareTo(right.testName.toLowerCase());
  }

  filtered.sort(
    switch (sort) {
      ResultSortOption.newest => compareNewest,
      ResultSortOption.highestScore => (left, right) {
          final score = right.percentageScore.compareTo(left.percentageScore);
          return score != 0 ? score : compareNewest(left, right);
        },
      ResultSortOption.highestAccuracy => (left, right) {
          final accuracy = right.accuracy.compareTo(left.accuracy);
          return accuracy != 0 ? accuracy : compareNewest(left, right);
        },
    },
  );

  return filtered;
}
