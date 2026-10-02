class ExamCatalogCategory {
  const ExamCatalogCategory({
    required this.code,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.colorHex,
    required this.testCount,
  });

  final String code;
  final String name;
  final String description;
  final String iconUrl;
  final String colorHex;
  final int testCount;
}

class ExamCatalogExam {
  const ExamCatalogExam({
    required this.code,
    required this.familyCode,
    required this.familyName,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.languages,
    required this.seriesCount,
    required this.testCount,
    required this.primarySeriesId,
  });

  final String code;
  final String familyCode;
  final String familyName;
  final String name;
  final String description;
  final String iconUrl;
  final List<String> languages;
  final int seriesCount;
  final int testCount;
  final String? primarySeriesId;
}

class ExamSeriesSummary {
  const ExamSeriesSummary({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.examCode,
    required this.examName,
    required this.examFamilyCode,
    required this.examFamilyName,
    required this.testCount,
    required this.liveTestCount,
    required this.fullLengthTestCount,
    required this.durationSeconds,
    required this.questionCount,
    required this.attemptCount,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final String examCode;
  final String examName;
  final String examFamilyCode;
  final String examFamilyName;
  final int testCount;
  final int liveTestCount;
  final int fullLengthTestCount;
  final int durationSeconds;
  final int questionCount;
  final int attemptCount;

  factory ExamSeriesSummary.fromJson(Map<String, dynamic> json) {
    int number(Object? value) =>
        value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

    return ExamSeriesSummary(
      id: json['id']?.toString().trim() ?? '',
      code: json['code']?.toString().trim() ?? '',
      name: json['name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      examCode: json['examCode']?.toString().trim() ?? '',
      examName: json['examName']?.toString().trim() ?? '',
      examFamilyCode: json['examFamilyCode']?.toString().trim() ?? '',
      examFamilyName: json['examFamilyName']?.toString().trim() ?? '',
      testCount: number(json['testCount']),
      liveTestCount: number(json['liveTestCount']),
      fullLengthTestCount: number(json['fullLengthTestCount']),
      durationSeconds: number(json['durationSeconds']),
      questionCount: number(json['questionCount']),
      attemptCount: number(json['attemptCount']),
    );
  }
}

class ExamCatalogSnapshot {
  const ExamCatalogSnapshot({
    required this.categories,
    required this.exams,
    required this.series,
  });

  final List<ExamCatalogCategory> categories;
  final List<ExamCatalogExam> exams;
  final List<ExamSeriesSummary> series;

  ExamCatalogCategory? findCategory(String identifier) {
    final normalized = identifier.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final category in categories) {
      if (category.code.toLowerCase() == normalized ||
          category.name.toLowerCase() == normalized) {
        return category;
      }
    }
    return null;
  }

  ExamCatalogExam? findExam(String identifier) {
    final normalized = identifier.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final exam in exams) {
      if (exam.code.toLowerCase() == normalized ||
          exam.name.toLowerCase() == normalized) {
        return exam;
      }
    }
    return null;
  }

  List<ExamCatalogExam> examsForCategory(String categoryCode) {
    final normalized = categoryCode.trim().toLowerCase();
    return exams
        .where((exam) => exam.familyCode.toLowerCase() == normalized)
        .toList(growable: false);
  }

  List<ExamSeriesSummary> seriesForExam(String examCode) {
    final normalized = examCode.trim().toLowerCase();
    return series
        .where((item) => item.examCode.toLowerCase() == normalized)
        .toList(growable: false);
  }
}
