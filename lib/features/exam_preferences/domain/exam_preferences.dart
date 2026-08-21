class ExamFamilyTarget {
  const ExamFamilyTarget({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.examCount,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final int examCount;

  factory ExamFamilyTarget.fromJson(Map<String, dynamic> json) =>
      ExamFamilyTarget(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        examCount: (json['examCount'] as num?)?.toInt() ?? 0,
      );
}

class ExamTargetLanguage {
  const ExamTargetLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isPrimary,
  });

  final String code;
  final String name;
  final String nativeName;
  final bool isPrimary;

  factory ExamTargetLanguage.fromJson(Map<String, dynamic> json) =>
      ExamTargetLanguage(
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        nativeName: json['nativeName']?.toString() ?? '',
        isPrimary: json['isPrimary'] == true,
      );
}

class SelectableExamTarget {
  const SelectableExamTarget({
    required this.id,
    required this.familyId,
    required this.code,
    required this.name,
    required this.description,
    required this.currentVersionId,
    required this.languages,
    required this.liveTestCount,
  });

  final String id;
  final String familyId;
  final String code;
  final String name;
  final String description;
  final String currentVersionId;
  final List<ExamTargetLanguage> languages;
  final int liveTestCount;

  bool get hasLiveTests => liveTestCount > 0;

  factory SelectableExamTarget.fromJson(Map<String, dynamic> json) {
    final rawLanguages = json['languages'];
    final languages = rawLanguages is List
        ? rawLanguages
            .whereType<Map>()
            .map((item) => ExamTargetLanguage.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList(growable: false)
        : const <ExamTargetLanguage>[];

    return SelectableExamTarget(
      id: json['id']?.toString() ?? '',
      familyId: json['familyId']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      currentVersionId: json['currentVersionId']?.toString() ?? '',
      languages: languages,
      liveTestCount: (json['liveTestCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ExamTargetCatalogue {
  const ExamTargetCatalogue({
    required this.families,
    required this.exams,
    required this.maxSelectedExams,
  });

  final List<ExamFamilyTarget> families;
  final List<SelectableExamTarget> exams;
  final int maxSelectedExams;

  factory ExamTargetCatalogue.fromJson(Map<String, dynamic> json) {
    final rawFamilies = json['families'];
    final rawExams = json['exams'];
    return ExamTargetCatalogue(
      families: rawFamilies is List
          ? rawFamilies
              .whereType<Map>()
              .map((item) => ExamFamilyTarget.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .where((family) => family.id.isNotEmpty && family.name.isNotEmpty)
              .toList(growable: false)
          : const <ExamFamilyTarget>[],
      exams: rawExams is List
          ? rawExams
              .whereType<Map>()
              .map((item) => SelectableExamTarget.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .where((exam) =>
                  exam.id.isNotEmpty &&
                  exam.familyId.isNotEmpty &&
                  exam.name.isNotEmpty)
              .toList(growable: false)
          : const <SelectableExamTarget>[],
      maxSelectedExams: (json['maxSelectedExams'] as num?)?.toInt() ?? 12,
    );
  }
}

class LearnerExamPreferences {
  const LearnerExamPreferences({
    required this.selectedExamIds,
    required this.maxSelectedExams,
  });

  final List<String> selectedExamIds;
  final int maxSelectedExams;

  factory LearnerExamPreferences.fromJson(Map<String, dynamic> json) {
    final rawIds = json['selectedExamIds'];
    return LearnerExamPreferences(
      selectedExamIds: rawIds is List
          ? rawIds.map((id) => id.toString()).where((id) => id.isNotEmpty).toList()
          : const <String>[],
      maxSelectedExams: (json['maxSelectedExams'] as num?)?.toInt() ?? 12,
    );
  }
}

class ExamPreferenceSnapshot {
  const ExamPreferenceSnapshot({
    required this.catalogue,
    required this.preferences,
  });

  final ExamTargetCatalogue catalogue;
  final LearnerExamPreferences preferences;

  List<SelectableExamTarget> get selectedExams {
    final byId = {for (final exam in catalogue.exams) exam.id: exam};
    return preferences.selectedExamIds
        .map((id) => byId[id])
        .whereType<SelectableExamTarget>()
        .toList(growable: false);
  }
}
