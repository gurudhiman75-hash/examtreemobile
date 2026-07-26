class AttemptSessionState {
  const AttemptSessionState({
    required this.testId,
    required this.testName,
    required this.category,
    required this.currentQuestionIndex,
    required this.currentSectionIndex,
    required this.answers,
    required this.flags,
    required this.timeLeft,
    required this.sectionTimeLeftByName,
    required this.updatedAt,
    required this.attemptType,
    required this.lockedSections,
    this.originalAttemptId,
    this.sectionCompletionTimes,
    this.visitedQuestionIds,
  });

  final String testId;
  final String testName;
  final String category;
  final int currentQuestionIndex;
  final int currentSectionIndex;
  final Map<String, int?> answers;
  final Map<String, bool> flags;
  final int timeLeft;
  final Map<String, int> sectionTimeLeftByName;
  final int updatedAt;
  final String attemptType;
  final List<int> lockedSections;
  final String? originalAttemptId;
  final Map<String, int>? sectionCompletionTimes;
  final List<int>? visitedQuestionIds;

  factory AttemptSessionState.fromJson(Map<String, dynamic> json) {
    return AttemptSessionState(
      testId: json['testId']?.toString() ?? '',
      testName: json['testName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      currentQuestionIndex: _asInt(json['currentQuestionIndex']),
      currentSectionIndex: _asInt(json['currentSectionIndex']),
      answers: _nullableIntMap(json['answers']),
      flags: _boolMap(json['flags']),
      timeLeft: _asInt(json['timeLeft']),
      sectionTimeLeftByName: _intMap(json['sectionTimeLeftByName']),
      updatedAt: _asInt(json['updatedAt']),
      attemptType: json['attemptType']?.toString() == 'PRACTICE'
          ? 'PRACTICE'
          : 'REAL',
      lockedSections: _intList(json['lockedSections']),
      originalAttemptId: json['originalAttemptId']?.toString(),
      sectionCompletionTimes: json['sectionCompletionTimes'] is Map
          ? _intMap(json['sectionCompletionTimes'])
          : null,
      visitedQuestionIds: json['visitedQuestionIds'] is List
          ? _intList(json['visitedQuestionIds'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testName': testName,
      'category': category,
      'currentQuestionIndex': currentQuestionIndex,
      'currentSectionIndex': currentSectionIndex,
      'answers': answers,
      'flags': flags,
      'timeLeft': timeLeft,
      'sectionTimeLeftByName': sectionTimeLeftByName,
      'updatedAt': updatedAt,
      'attemptType': attemptType,
      'lockedSections': lockedSections,
      if (originalAttemptId != null) 'originalAttemptId': originalAttemptId,
      if (sectionCompletionTimes != null)
        'sectionCompletionTimes': sectionCompletionTimes,
      if (visitedQuestionIds != null)
        'visitedQuestionIds': visitedQuestionIds,
    };
  }
}

class AttemptSession {
  const AttemptSession({
    required this.id,
    required this.testId,
    required this.testVersionId,
    required this.publicationId,
    required this.attemptNumber,
    required this.status,
    required this.revision,
    required this.startedAt,
    required this.updatedAt,
    required this.savedAt,
    this.seriesId,
    this.state,
  });

  final String id;
  final String testId;
  final String testVersionId;
  final String publicationId;
  final int attemptNumber;
  final String status;
  final int revision;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime savedAt;
  final String? seriesId;
  final AttemptSessionState? state;

  factory AttemptSession.fromJson(Map<String, dynamic> json) {
    final rawState = json['state'];
    return AttemptSession(
      id: json['id']?.toString() ?? '',
      testId: json['testId']?.toString() ?? '',
      testVersionId: json['testVersionId']?.toString() ?? '',
      publicationId: json['publicationId']?.toString() ?? '',
      attemptNumber: _asInt(json['attemptNumber'], fallback: 1),
      status: json['status']?.toString() ?? 'in_progress',
      revision: _asInt(json['revision']),
      startedAt: _asDate(json['startedAt']),
      updatedAt: _asDate(json['updatedAt']),
      savedAt: _asDate(json['savedAt']),
      seriesId: json['seriesId']?.toString(),
      state: rawState is Map
          ? AttemptSessionState.fromJson(Map<String, dynamic>.from(rawState))
          : null,
    );
  }
}

class AttemptResponsePayload {
  const AttemptResponsePayload({
    required this.questionId,
    required this.selectedOption,
    this.timeTaken = 0,
  });

  final int questionId;
  final int? selectedOption;
  final int timeTaken;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedOption': selectedOption,
        'timeTaken': timeTaken,
      };
}

class AttemptSubmitResponse {
  const AttemptSubmitResponse({required this.attemptId});

  final String attemptId;

  factory AttemptSubmitResponse.fromJson(Map<String, dynamic> json) {
    return AttemptSubmitResponse(attemptId: json['id']?.toString() ?? '');
  }
}

class AttemptSessionConflict implements Exception {
  const AttemptSessionConflict(this.latestSession);

  final AttemptSession latestSession;

  @override
  String toString() => 'This attempt was updated on another device.';
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime _asDate(Object? value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}

Map<String, int?> _nullableIntMap(Object? value) {
  if (value is! Map) return <String, int?>{};
  return {
    for (final entry in value.entries)
      entry.key.toString(): entry.value == null ? null : _asInt(entry.value),
  };
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return <String, int>{};
  return {
    for (final entry in value.entries)
      entry.key.toString(): _asInt(entry.value),
  };
}

Map<String, bool> _boolMap(Object? value) {
  if (value is! Map) return <String, bool>{};
  return {
    for (final entry in value.entries)
      entry.key.toString(): entry.value == true,
  };
}

List<int> _intList(Object? value) {
  if (value is! List) return <int>[];
  return value.map(_asInt).toList();
}
