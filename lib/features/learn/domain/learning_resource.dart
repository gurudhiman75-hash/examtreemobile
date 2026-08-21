enum LearningResourceCategory {
  currentAffairs('current_affairs', 'Current affairs'),
  notes('notes', 'Notes'),
  formulaSheet('formula_sheet', 'Formula sheets');

  const LearningResourceCategory(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static LearningResourceCategory? tryParse(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    for (final category in values) {
      if (category.apiValue == normalized) return category;
    }
    return null;
  }
}

enum LearningResourceFormat {
  article('article'),
  pdf('pdf');

  const LearningResourceFormat(this.apiValue);

  final String apiValue;

  static LearningResourceFormat? tryParse(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    for (final format in values) {
      if (format.apiValue == normalized) return format;
    }
    return null;
  }
}

class LearningResourceExamTarget {
  const LearningResourceExamTarget({
    required this.id,
    required this.code,
    required this.name,
    required this.familyId,
    required this.familyCode,
    required this.familyName,
  });

  final String id;
  final String code;
  final String name;
  final String familyId;
  final String familyCode;
  final String familyName;

  factory LearningResourceExamTarget.fromJson(Map<String, dynamic> json) {
    return LearningResourceExamTarget(
      id: _text(json['id']),
      code: _text(json['code']),
      name: _text(json['name']),
      familyId: _text(json['familyId']),
      familyCode: _text(json['familyCode']),
      familyName: _text(json['familyName']),
    );
  }
}

class LearningResourceSummary {
  const LearningResourceSummary({
    required this.id,
    required this.publicCode,
    required this.category,
    required this.format,
    required this.title,
    required this.summary,
    required this.languageCode,
    required this.contentDate,
    required this.contentUrl,
    required this.hasInlineContent,
    required this.publishedAt,
    required this.expiresAt,
    required this.isGeneral,
    required this.exams,
  });

  final String id;
  final String publicCode;
  final LearningResourceCategory category;
  final LearningResourceFormat format;
  final String title;
  final String summary;
  final String languageCode;
  final DateTime? contentDate;
  final Uri? contentUrl;
  final bool hasInlineContent;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final bool isGeneral;
  final List<LearningResourceExamTarget> exams;

  bool targetsAny(Set<String> selectedExamIds) {
    if (isGeneral) return true;
    if (selectedExamIds.isEmpty) return false;
    return exams.any((exam) => selectedExamIds.contains(exam.id));
  }

  factory LearningResourceSummary.fromJson(Map<String, dynamic> json) {
    final category = LearningResourceCategory.tryParse(json['category']);
    final format = LearningResourceFormat.tryParse(json['format']);
    if (category == null || format == null) {
      throw const FormatException('Unsupported learning resource type');
    }
    final id = _text(json['id']);
    final publicCode = _text(json['publicCode']);
    final title = _text(json['title']);
    if (id.isEmpty || publicCode.isEmpty || title.isEmpty) {
      throw const FormatException('Incomplete learning resource');
    }

    return LearningResourceSummary(
      id: id,
      publicCode: publicCode,
      category: category,
      format: format,
      title: title,
      summary: _text(json['summary']),
      languageCode: _text(json['languageCode'], fallback: 'en').toLowerCase(),
      contentDate: _date(json['contentDate']),
      contentUrl: _httpsUri(json['contentUrl']),
      hasInlineContent: json['hasInlineContent'] == true,
      publishedAt: _date(json['publishedAt']),
      expiresAt: _date(json['expiresAt']),
      isGeneral: json['isGeneral'] == true,
      exams: _mapList(json['exams'])
          .map(LearningResourceExamTarget.fromJson)
          .where((exam) => exam.id.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class LearningResourceDetail {
  const LearningResourceDetail({
    required this.summary,
    required this.bodyMarkdown,
  });

  final LearningResourceSummary summary;
  final String bodyMarkdown;

  factory LearningResourceDetail.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    normalized['hasInlineContent'] = _text(json['bodyMarkdown']).isNotEmpty;
    return LearningResourceDetail(
      summary: LearningResourceSummary.fromJson(normalized),
      bodyMarkdown: _text(json['bodyMarkdown']),
    );
  }
}

List<LearningResourceSummary> relevantLearningResources({
  required Iterable<LearningResourceSummary> resources,
  required Iterable<String> selectedExamIds,
}) {
  final selected = selectedExamIds
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toSet();
  final filtered = resources.where((resource) => resource.targetsAny(selected)).toList();
  filtered.sort((left, right) {
    final leftTargeted = left.isGeneral ? 1 : 0;
    final rightTargeted = right.isGeneral ? 1 : 0;
    if (selected.isNotEmpty && leftTargeted != rightTargeted) {
      return leftTargeted.compareTo(rightTargeted);
    }
    final leftDate = left.contentDate ?? left.publishedAt;
    final rightDate = right.contentDate ?? right.publishedAt;
    if (leftDate != null && rightDate != null) {
      final byDate = rightDate.compareTo(leftDate);
      if (byDate != 0) return byDate;
    } else if (leftDate == null && rightDate != null) {
      return 1;
    } else if (leftDate != null && rightDate == null) {
      return -1;
    }
    return left.title.toLowerCase().compareTo(right.title.toLowerCase());
  });
  return filtered;
}

String _text(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

Uri? _httpsUri(Object? value) {
  final raw = _text(value);
  if (raw.isEmpty) return null;
  final uri = Uri.tryParse(raw);
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty ? uri : null;
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
