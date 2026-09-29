class LearnLesson {
  const LearnLesson({
    required this.id,
    required this.subjectCode,
    required this.title,
    required this.summary,
    required this.estimatedMinutes,
    required this.sections,
    required this.quickRevision,
    required this.examFocus,
    this.practiceTags = const <String>[],
  });

  final String id;
  final String subjectCode;
  final String title;
  final String summary;
  final int estimatedMinutes;
  final List<LearnLessonSection> sections;
  final List<String> quickRevision;
  final List<String> examFocus;
  final List<String> practiceTags;

  bool get isReady => sections.isNotEmpty;
}

class LearnLessonSection {
  const LearnLessonSection({
    required this.heading,
    required this.paragraphs,
    this.points = const <String>[],
    this.table,
  });

  final String heading;
  final List<String> paragraphs;
  final List<String> points;
  final LearnLessonTable? table;
}

class LearnLessonTable {
  const LearnLessonTable({
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<List<String>> rows;
}

class LearnSubject {
  const LearnSubject({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.lessons,
  });

  final String code;
  final String title;
  final String subtitle;
  final String iconName;
  final List<LearnLesson> lessons;

  int get readyLessonCount => lessons.where((lesson) => lesson.isReady).length;
}
