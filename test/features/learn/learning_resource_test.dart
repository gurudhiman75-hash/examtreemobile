import 'package:examtree/features/learn/domain/learning_resource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LearningResourceSummary resource({
    required String id,
    required bool isGeneral,
    List<LearningResourceExamTarget> exams = const [],
    DateTime? contentDate,
  }) {
    return LearningResourceSummary(
      id: id,
      publicCode: id.toUpperCase(),
      category: LearningResourceCategory.currentAffairs,
      format: LearningResourceFormat.article,
      title: 'Resource $id',
      summary: 'Summary',
      languageCode: 'en',
      contentDate: contentDate,
      contentUrl: null,
      hasInlineContent: true,
      publishedAt: DateTime.utc(2026, 8, 20),
      expiresAt: null,
      isGeneral: isGeneral,
      exams: exams,
    );
  }

  const ssc = LearningResourceExamTarget(
    id: 'exam-ssc',
    code: 'SSC_CGL',
    name: 'SSC CGL',
    familyId: 'family-ssc',
    familyCode: 'SSC',
    familyName: 'SSC',
  );

  test('targeted resources stay hidden without matching My Exams selection', () {
    final items = relevantLearningResources(
      resources: [
        resource(id: 'general', isGeneral: true),
        resource(id: 'ssc', isGeneral: false, exams: const [ssc]),
      ],
      selectedExamIds: const [],
    );

    expect(items.map((item) => item.id), ['general']);
  });

  test('matching targeted resources appear before general resources', () {
    final items = relevantLearningResources(
      resources: [
        resource(
          id: 'general',
          isGeneral: true,
          contentDate: DateTime.utc(2026, 8, 21),
        ),
        resource(
          id: 'ssc',
          isGeneral: false,
          exams: const [ssc],
          contentDate: DateTime.utc(2026, 8, 20),
        ),
      ],
      selectedExamIds: const ['exam-ssc'],
    );

    expect(items.map((item) => item.id), ['ssc', 'general']);
  });

  test('unsafe document URLs are discarded while valid HTTPS URLs survive', () {
    final unsafe = LearningResourceSummary.fromJson({
      'id': 'one',
      'publicCode': 'RES_ONE',
      'category': 'notes',
      'format': 'pdf',
      'title': 'Unsafe link',
      'summary': '',
      'languageCode': 'en',
      'contentUrl': 'http://example.com/file.pdf',
      'hasInlineContent': false,
      'isGeneral': true,
      'exams': const [],
    });
    final safe = LearningResourceSummary.fromJson({
      'id': 'two',
      'publicCode': 'RES_TWO',
      'category': 'notes',
      'format': 'pdf',
      'title': 'Safe link',
      'summary': '',
      'languageCode': 'en',
      'contentUrl': 'https://example.com/file.pdf',
      'hasInlineContent': false,
      'isGeneral': true,
      'exams': const [],
    });

    expect(unsafe.contentUrl, isNull);
    expect(safe.contentUrl.toString(), 'https://example.com/file.pdf');
  });
}
