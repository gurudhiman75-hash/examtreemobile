import '../../../core/models/exam_model.dart';

enum ExamAccessFilter { all, free, paid }

enum ExamSortOption { recommended, newest, shortest, mostQuestions }

extension ExamAccessFilterLabel on ExamAccessFilter {
  String get label => switch (this) {
        ExamAccessFilter.all => 'All access',
        ExamAccessFilter.free => 'Free',
        ExamAccessFilter.paid => 'Paid',
      };
}

extension ExamSortOptionLabel on ExamSortOption {
  String get label => switch (this) {
        ExamSortOption.recommended => 'Recommended',
        ExamSortOption.newest => 'Newest',
        ExamSortOption.shortest => 'Shortest',
        ExamSortOption.mostQuestions => 'Most questions',
      };
}

List<String> examCategories(Iterable<Exam> exams) {
  final categories = exams
      .map((exam) => exam.category.trim())
      .where((category) => category.isNotEmpty)
      .toSet()
      .toList()
    ..sort((left, right) => left.toLowerCase().compareTo(right.toLowerCase()));
  return categories;
}

List<Exam> filterAndSortExams({
  required Iterable<Exam> exams,
  String query = '',
  String? category,
  ExamAccessFilter access = ExamAccessFilter.all,
  ExamSortOption sort = ExamSortOption.recommended,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final normalizedCategory = category?.trim().toLowerCase();

  final filtered = exams.where((exam) {
    if (normalizedCategory != null &&
        normalizedCategory.isNotEmpty &&
        exam.category.trim().toLowerCase() != normalizedCategory) {
      return false;
    }

    final isPaid = exam.status.trim().toLowerCase() == 'paid';
    if (access == ExamAccessFilter.free && isPaid) return false;
    if (access == ExamAccessFilter.paid && !isPaid) return false;

    if (normalizedQuery.isEmpty) return true;
    final searchable = <String>[
      exam.title,
      exam.description,
      exam.category,
      exam.difficulty,
      ...exam.tags,
    ].join(' ').toLowerCase();
    return searchable.contains(normalizedQuery);
  }).toList();

  int compareRecommended(Exam left, Exam right) {
    final leftPaid = left.status.trim().toLowerCase() == 'paid' ? 1 : 0;
    final rightPaid = right.status.trim().toLowerCase() == 'paid' ? 1 : 0;
    if (leftPaid != rightPaid) return leftPaid.compareTo(rightPaid);

    final updated = right.updatedAt.compareTo(left.updatedAt);
    if (updated != 0) return updated;
    return left.title.toLowerCase().compareTo(right.title.toLowerCase());
  }

  filtered.sort(
    switch (sort) {
      ExamSortOption.recommended => compareRecommended,
      ExamSortOption.newest => (left, right) {
          final updated = right.updatedAt.compareTo(left.updatedAt);
          return updated != 0
              ? updated
              : left.title.toLowerCase().compareTo(right.title.toLowerCase());
        },
      ExamSortOption.shortest => (left, right) {
          final duration = left.durationInSeconds.compareTo(right.durationInSeconds);
          return duration != 0
              ? duration
              : left.title.toLowerCase().compareTo(right.title.toLowerCase());
        },
      ExamSortOption.mostQuestions => (left, right) {
          final questions = right.totalQuestions.compareTo(left.totalQuestions);
          return questions != 0
              ? questions
              : left.title.toLowerCase().compareTo(right.title.toLowerCase());
        },
    },
  );

  return filtered;
}
