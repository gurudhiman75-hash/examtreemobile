import '../../../core/models/exam_model.dart';

const canonicalExamCodeTagPrefix = 'exam-code:';
const homeSelectedExamTag = 'home-selected-exam';

String? canonicalExamCodeFor(Exam exam) {
  for (final tag in exam.tags) {
    if (tag.startsWith(canonicalExamCodeTagPrefix)) {
      final code = tag.substring(canonicalExamCodeTagPrefix.length).trim();
      if (code.isNotEmpty) return code;
    }
  }
  return null;
}

bool isHomeSelectedExam(Exam exam) => exam.tags.contains(homeSelectedExamTag);

List<Exam> prioritizeHomeExams({
  required Iterable<Exam> exams,
  required Iterable<String> selectedExamCodes,
}) {
  final source = exams.toList(growable: false);
  final selected = selectedExamCodes
      .map((code) => code.trim().toLowerCase())
      .where((code) => code.isNotEmpty)
      .toList(growable: false);
  if (source.isEmpty || selected.isEmpty) return source;

  final rank = <String, int>{};
  for (var index = 0; index < selected.length; index++) {
    rank.putIfAbsent(selected[index], () => index);
  }

  final decorated = <({Exam exam, int sourceIndex, int? rank})>[];
  for (var index = 0; index < source.length; index++) {
    final exam = source[index];
    final code = canonicalExamCodeFor(exam)?.toLowerCase();
    final selectedRank = code == null ? null : rank[code];
    final marked = selectedRank == null || isHomeSelectedExam(exam)
        ? exam
        : exam.copyWith(tags: [...exam.tags, homeSelectedExamTag]);
    decorated.add((exam: marked, sourceIndex: index, rank: selectedRank));
  }

  decorated.sort((left, right) {
    final leftRank = left.rank;
    final rightRank = right.rank;
    if (leftRank == null && rightRank == null) {
      return left.sourceIndex.compareTo(right.sourceIndex);
    }
    if (leftRank == null) return 1;
    if (rightRank == null) return -1;
    final bySelection = leftRank.compareTo(rightRank);
    if (bySelection != 0) return bySelection;
    return left.sourceIndex.compareTo(right.sourceIndex);
  });

  return decorated.map((item) => item.exam).toList(growable: false);
}
