class Question {
  const Question({
    required this.id,
    required this.examId,
    required this.subject,
    required this.topic,
    required this.difficulty,
    required this.text,
    required this.options,
    required this.correctOptionIndexes,
    required this.explanation,
    required this.points,
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
  });

  final int id;
  final String examId;
  final String subject;
  final String topic;
  final String difficulty;
  final String text;
  final List<String> options;
  final List<int> correctOptionIndexes;
  final String explanation;
  final double points;
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

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: _asInt(json['id']),
      examId: json['examId']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      options: _stringList(json['options']),
      correctOptionIndexes: _intList(json['correctOptionIndexes']),
      explanation: json['explanation']?.toString() ?? '',
      points: _asDouble(json['points']),
      textHi: json['textHi']?.toString(),
      optionsHi: json['optionsHi'] is List
          ? _stringList(json['optionsHi'])
          : null,
      explanationHi: json['explanationHi']?.toString(),
      textPa: json['textPa']?.toString(),
      optionsPa: json['optionsPa'] is List
          ? _stringList(json['optionsPa'])
          : null,
      explanationPa: json['explanationPa']?.toString(),
      seatingDiagram: _map(json['seatingDiagram']),
      seatingExplanationFlow: _map(json['seatingExplanationFlow']),
      imageUrl: json['imageUrl']?.toString(),
      questionType: json['questionType']?.toString(),
      diSetId: json['diSetId'] == null ? null : _asInt(json['diSetId']),
      diSetTitle: json['diSetTitle']?.toString(),
      diSetImageUrl: json['diSetImageUrl']?.toString(),
      diSetDescription: json['diSetDescription']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examId': examId,
      'subject': subject,
      'topic': topic,
      'difficulty': difficulty,
      'text': text,
      'options': options,
      'correctOptionIndexes': correctOptionIndexes,
      'explanation': explanation,
      'points': points,
      'textHi': textHi,
      'optionsHi': optionsHi,
      'explanationHi': explanationHi,
      'textPa': textPa,
      'optionsPa': optionsPa,
      'explanationPa': explanationPa,
      'seatingDiagram': seatingDiagram,
      'seatingExplanationFlow': seatingExplanationFlow,
      'imageUrl': imageUrl,
      'questionType': questionType,
      'diSetId': diSetId,
      'diSetTitle': diSetTitle,
      'diSetImageUrl': diSetImageUrl,
      'diSetDescription': diSetDescription,
    };
  }

  Question copyWith({
    int? id,
    String? examId,
    String? subject,
    String? topic,
    String? difficulty,
    String? text,
    List<String>? options,
    List<int>? correctOptionIndexes,
    String? explanation,
    double? points,
    String? textHi,
    List<String>? optionsHi,
    String? explanationHi,
    String? textPa,
    List<String>? optionsPa,
    String? explanationPa,
    Map<String, dynamic>? seatingDiagram,
    Map<String, dynamic>? seatingExplanationFlow,
    String? imageUrl,
    String? questionType,
    int? diSetId,
    String? diSetTitle,
    String? diSetImageUrl,
    String? diSetDescription,
  }) {
    return Question(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      text: text ?? this.text,
      options: options ?? this.options,
      correctOptionIndexes:
          correctOptionIndexes ?? this.correctOptionIndexes,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
      textHi: textHi ?? this.textHi,
      optionsHi: optionsHi ?? this.optionsHi,
      explanationHi: explanationHi ?? this.explanationHi,
      textPa: textPa ?? this.textPa,
      optionsPa: optionsPa ?? this.optionsPa,
      explanationPa: explanationPa ?? this.explanationPa,
      seatingDiagram: seatingDiagram ?? this.seatingDiagram,
      seatingExplanationFlow:
          seatingExplanationFlow ?? this.seatingExplanationFlow,
      imageUrl: imageUrl ?? this.imageUrl,
      questionType: questionType ?? this.questionType,
      diSetId: diSetId ?? this.diSetId,
      diSetTitle: diSetTitle ?? this.diSetTitle,
      diSetImageUrl: diSetImageUrl ?? this.diSetImageUrl,
      diSetDescription: diSetDescription ?? this.diSetDescription,
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.map((item) => item.toString()).toList();
}

List<int> _intList(Object? value) {
  if (value is! List) return const <int>[];
  return value.map(_asInt).toList();
}

Map<String, dynamic>? _map(Object? value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}
