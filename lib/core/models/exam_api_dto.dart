import 'exam_model.dart';
import 'question_model.dart';

List<String> _stringList(Object? value) {
  if (value is List) return value.map((item) => item.toString()).toList();
  return const [];
}

List<String>? _nullableStringList(Object? value) {
  if (value == null) return null;
  return _stringList(value);
}

Map<String, dynamic>? _nullableMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _nullableString(Object? value) => value == null ? null : value.toString();
String _string(Object? value, [String fallback = '']) => value == null ? fallback : value.toString();

int _int(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _double(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
}

class CategoryDto {
  const CategoryDto({required this.id, required this.name, required this.description, this.icon, this.color, this.testsCount = 0});
  final String id;
  final String name;
  final String description;
  final String? icon;
  final String? color;
  final int testsCount;

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
        id: _string(json['id']),
        name: _string(json['name']),
        description: _string(json['description']),
        icon: _nullableString(json['icon']),
        color: _nullableString(json['color']),
        testsCount: _int(json['testsCount']),
      );
}

class SubcategoryDto {
  const SubcategoryDto({required this.id, required this.categoryId, required this.categoryName, required this.name, required this.description, this.icon, this.languages = const []});
  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final String? icon;
  final List<String> languages;

  factory SubcategoryDto.fromJson(Map<String, dynamic> json) => SubcategoryDto(
        id: _string(json['id']),
        categoryId: _string(json['categoryId']),
        categoryName: _string(json['categoryName']),
        name: _string(json['name']),
        description: _string(json['description']),
        icon: _nullableString(json['icon']),
        languages: _stringList(json['languages']),
      );
}

class TestSectionDto {
  const TestSectionDto({required this.id, required this.name, required this.questions});
  final String id;
  final String name;
  final List<QuestionDto> questions;

  factory TestSectionDto.fromJson(Map<String, dynamic> json) => TestSectionDto(
        id: _string(json['id']),
        name: _string(json['name'], 'General'),
        questions: _listOfMaps(json['questions']).map(QuestionDto.fromJson).toList(),
      );
}

class QuestionDto {
  const QuestionDto({
    required this.id,
    required this.text,
    required this.options,
    required this.correct,
    required this.section,
    required this.explanation,
    this.difficulty,
    this.topic,
    this.textHi,
    this.optionsHi,
    this.explanationHi,
    this.textPa,
    this.optionsPa,
    this.explanationPa,
    this.seatingDiagram,
    this.seatingExplanationFlow,
    this.imageUrl,
    this.questionType,
    this.diSetId,
    this.diSetTitle,
    this.diSetImageUrl,
    this.diSetDescription,
    this.marks,
  });

  final int id;
  final String? text;
  final List<String> options;
  final int correct;
  final String section;
  final String? explanation;
  final String? difficulty;
  final String? topic;
  final String? textHi;
  final List<String>? optionsHi;
  final String? explanationHi;
  final String? textPa;
  final List<String>? optionsPa;
  final String? explanationPa;
  final Map<String, dynamic>? seatingDiagram;
  final Map<String, dynamic>? seatingExplanationFlow;
  final String? imageUrl;
  final String? questionType;
  final int? diSetId;
  final String? diSetTitle;
  final String? diSetImageUrl;
  final String? diSetDescription;
  final double? marks;

  factory QuestionDto.fromJson(Map<String, dynamic> json) => QuestionDto(
        id: _int(json['id']),
        text: _nullableString(json['text']),
        options: _stringList(json['options']),
        correct: _int(json['correct']),
        section: _string(json['section'], 'General'),
        explanation: _nullableString(json['explanation']),
        difficulty: _nullableString(json['difficulty']),
        topic: _nullableString(json['topic']),
        textHi: _nullableString(json['textHi'] ?? json['text_hi']),
        optionsHi: _nullableStringList(json['optionsHi'] ?? json['options_hi']),
        explanationHi: _nullableString(json['explanationHi'] ?? json['explanation_hi']),
        textPa: _nullableString(json['textPa'] ?? json['text_pa']),
        optionsPa: _nullableStringList(json['optionsPa'] ?? json['options_pa']),
        explanationPa: _nullableString(json['explanationPa'] ?? json['explanation_pa']),
        seatingDiagram: _nullableMap(json['seatingDiagram'] ?? json['seating_diagram']),
        seatingExplanationFlow: _nullableMap(json['seatingExplanationFlow'] ?? json['seating_explanation_flow']),
        imageUrl: _nullableString(json['imageUrl'] ?? json['image_url']),
        questionType: _nullableString(json['questionType'] ?? json['question_type']),
        diSetId: json['diSetId'] != null || json['di_set_id'] != null ? _int(json['diSetId'] ?? json['di_set_id']) : null,
        diSetTitle: _nullableString(json['diSetTitle']),
        diSetImageUrl: _nullableString(json['diSetImageUrl']),
        diSetDescription: _nullableString(json['diSetDescription']),
        marks: json['marks'] == null ? null : _double(json['marks']),
      );

  Question toQuestion({required String examId, required String sectionName, required double defaultMarks}) {
    return Question(
      id: id,
      examId: examId,
      subject: section.isNotEmpty ? section : sectionName,
      topic: topic ?? '',
      difficulty: difficulty ?? '',
      text: text ?? textHi ?? textPa ?? '',
      options: options,
      correctOptionIndexes: [correct],
      explanation: explanation ?? explanationHi ?? explanationPa ?? '',
      points: marks ?? defaultMarks,
      textHi: textHi,
      optionsHi: optionsHi,
      explanationHi: explanationHi,
      textPa: textPa,
      optionsPa: optionsPa,
      explanationPa: explanationPa,
      seatingDiagram: seatingDiagram,
      seatingExplanationFlow: seatingExplanationFlow,
      imageUrl: imageUrl,
      questionType: questionType,
      diSetId: diSetId,
      diSetTitle: diSetTitle,
      diSetImageUrl: diSetImageUrl,
      diSetDescription: diSetDescription,
    );
  }
}

class TestDto {
  const TestDto({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.duration,
    required this.totalQuestions,
    required this.attempts,
    required this.avgScore,
    required this.difficulty,
    required this.sections,
    this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.access,
    this.priceCents,
    this.kind,
    this.topicName,
    this.marksPerQuestion,
    this.negativeMarks,
    this.languages = const [],
    this.maxAttempts = 99,
  });

  final String id;
  final String name;
  final String category;
  final String categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final String? access;
  final int? priceCents;
  final String? kind;
  final String? topicName;
  final int duration;
  final int totalQuestions;
  final int attempts;
  final int avgScore;
  final String difficulty;
  final List<TestSectionDto> sections;
  final double? marksPerQuestion;
  final double? negativeMarks;
  final List<String> languages;
  final int maxAttempts;

  factory TestDto.fromJson(Map<String, dynamic> json) => TestDto(
        id: _string(json['id']),
        name: _string(json['name'], 'Untitled Test'),
        category: _string(json['category']),
        categoryId: _string(json['categoryId']),
        categoryName: _nullableString(json['categoryName']),
        subcategoryId: _nullableString(json['subcategoryId']),
        subcategoryName: _nullableString(json['subcategoryName']),
        access: _nullableString(json['access']),
        priceCents: json['priceCents'] == null ? null : _int(json['priceCents']),
        kind: _nullableString(json['kind']),
        topicName: _nullableString(json['topicName']),
        duration: _int(json['duration']),
        totalQuestions: _int(json['totalQuestions']),
        attempts: _int(json['attempts']),
        avgScore: _int(json['avgScore']),
        difficulty: _string(json['difficulty'], 'Medium'),
        sections: _listOfMaps(json['sections']).map(TestSectionDto.fromJson).toList(),
        marksPerQuestion: json['marksPerQuestion'] == null ? null : _double(json['marksPerQuestion'], 1),
        negativeMarks: json['negativeMarks'] == null ? null : _double(json['negativeMarks']),
        languages: _stringList(json['languages']),
        maxAttempts: _int(json['maxAttempts'], 99),
      );

  Exam toExam({Map<String, CategoryDto> categories = const {}, Map<String, SubcategoryDto> subcategories = const {}}) {
    final categoryDto = categories[categoryId];
    final subcategoryDto = subcategoryId == null ? null : subcategories[subcategoryId];
    final resolvedCategory = categoryName ?? categoryDto?.name ?? category;
    final description = topicName ?? subcategoryName ?? subcategoryDto?.name ?? categoryDto?.description ?? resolvedCategory;
    final perQuestion = marksPerQuestion ?? 1;
    final total = totalQuestions > 0 ? totalQuestions : sections.fold<int>(0, (sum, section) => sum + section.questions.length);

    return Exam(
      id: id,
      title: name,
      description: description,
      durationInSeconds: duration * 60,
      totalQuestions: total,
      totalMarks: total * perQuestion,
      maxAttempts: maxAttempts > 0 ? maxAttempts : 99,
      negativeMarking: negativeMarks ?? 0,
      difficulty: difficulty,
      status: access == 'paid' ? 'paid' : 'published',
      category: resolvedCategory,
      tags: [if (kind != null && kind!.isNotEmpty) kind!, if (access != null && access!.isNotEmpty) access!],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<Question> toQuestions() {
    final defaultMarks = marksPerQuestion ?? 1;
    return sections.expand((section) => section.questions.map((question) => question.toQuestion(examId: id, sectionName: section.name, defaultMarks: defaultMarks))).toList();
  }
}
