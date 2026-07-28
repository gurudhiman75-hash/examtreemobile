import 'package:examtree/core/models/exam_model.dart';
import 'package:examtree/features/exams/presentation/exam_catalog_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 7, 28);

  Exam exam({
    required String id,
    required String title,
    required String category,
    required String status,
    required int minutes,
    required int questions,
    required DateTime updatedAt,
    String difficulty = 'Medium',
    List<String> tags = const [],
  }) {
    return Exam(
      id: id,
      title: title,
      description: '$title practice paper',
      durationInSeconds: minutes * 60,
      totalQuestions: questions,
      totalMarks: questions.toDouble(),
      maxAttempts: 99,
      negativeMarking: 0.25,
      difficulty: difficulty,
      status: status,
      category: category,
      tags: tags,
      createdAt: updatedAt.subtract(const Duration(days: 1)),
      updatedAt: updatedAt,
    );
  }

  late List<Exam> exams;

  setUp(() {
    exams = [
      exam(
        id: 'ssc-free',
        title: 'SSC CHSL Full Mock',
        category: 'SSC',
        status: 'published',
        minutes: 60,
        questions: 100,
        updatedAt: now.subtract(const Duration(days: 2)),
        tags: const ['full-length'],
      ),
      exam(
        id: 'punjab-paid',
        title: 'Punjab Patwari Advanced',
        category: 'Punjab Exams',
        status: 'paid',
        minutes: 90,
        questions: 120,
        updatedAt: now,
        difficulty: 'Hard',
      ),
      exam(
        id: 'ssc-speed',
        title: 'SSC Reasoning Sprint',
        category: 'SSC',
        status: 'published',
        minutes: 20,
        questions: 25,
        updatedAt: now.subtract(const Duration(days: 1)),
        difficulty: 'Easy',
        tags: const ['reasoning', 'sectional'],
      ),
    ];
  });

  test('returns unique categories in alphabetical order', () {
    expect(examCategories(exams), ['Punjab Exams', 'SSC']);
  });

  test('searches title, category, difficulty and tags', () {
    expect(
      filterAndSortExams(exams: exams, query: 'reasoning').map((e) => e.id),
      ['ssc-speed'],
    );
    expect(
      filterAndSortExams(exams: exams, query: 'hard').map((e) => e.id),
      ['punjab-paid'],
    );
  });

  test('combines category and access filters', () {
    expect(
      filterAndSortExams(
        exams: exams,
        category: 'SSC',
        access: ExamAccessFilter.free,
      ).map((e) => e.id),
      ['ssc-speed', 'ssc-free'],
    );
    expect(
      filterAndSortExams(
        exams: exams,
        access: ExamAccessFilter.paid,
      ).map((e) => e.id),
      ['punjab-paid'],
    );
  });

  test('sorts by duration and question count deterministically', () {
    expect(
      filterAndSortExams(
        exams: exams,
        sort: ExamSortOption.shortest,
      ).map((e) => e.id),
      ['ssc-speed', 'ssc-free', 'punjab-paid'],
    );
    expect(
      filterAndSortExams(
        exams: exams,
        sort: ExamSortOption.mostQuestions,
      ).map((e) => e.id),
      ['punjab-paid', 'ssc-free', 'ssc-speed'],
    );
  });

  test('recommended order keeps free tests before paid tests', () {
    expect(
      filterAndSortExams(exams: exams).map((e) => e.id),
      ['ssc-speed', 'ssc-free', 'punjab-paid'],
    );
  });
}
