// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Question {
  int get id;
  String get examId;
  String get subject;
  String get topic;
  String get difficulty;
  String get text;
  List<String> get options;
  List<int> get correctOptionIndexes;
  String get explanation;
  double get points;
  String? get textHi;
  List<String>? get optionsHi;
  String? get explanationHi;
  String? get textPa;
  List<String>? get optionsPa;
  String? get explanationPa;
  Map<String, dynamic>? get seatingDiagram;
  Map<String, dynamic>? get seatingExplanationFlow;
  String? get imageUrl;
  String? get questionType;
  int? get diSetId;
  String? get diSetTitle;
  String? get diSetImageUrl;
  String? get diSetDescription;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuestionCopyWith<Question> get copyWith =>
      _$QuestionCopyWithImpl<Question>(this as Question, _$identity);

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson();
}

/// @nodoc
abstract mixin class $QuestionCopyWith<$Res> {
  factory $QuestionCopyWith(Question value, $Res Function(Question) _then) =
      _$QuestionCopyWithImpl;

  @useResult
  $Res call({
    int id,
    String examId,
    String subject,
    String topic,
    String difficulty,
    String text,
    List<String> options,
    List<int> correctOptionIndexes,
    String explanation,
    double points,
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
  });
}

/// @nodoc
class _$QuestionCopyWithImpl<$Res> implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._self, this._then);

  final Question _self;
  final $Res Function(Question) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examId = null,
    Object? subject = null,
    Object? topic = null,
    Object? difficulty = null,
    Object? text = null,
    Object? options = null,
    Object? correctOptionIndexes = null,
    Object? explanation = null,
    Object? points = null,
    Object? textHi = freezed,
    Object? optionsHi = freezed,
    Object? explanationHi = freezed,
    Object? textPa = freezed,
    Object? optionsPa = freezed,
    Object? explanationPa = freezed,
    Object? seatingDiagram = freezed,
    Object? seatingExplanationFlow = freezed,
    Object? imageUrl = freezed,
    Object? questionType = freezed,
    Object? diSetId = freezed,
    Object? diSetTitle = freezed,
    Object? diSetImageUrl = freezed,
    Object? diSetDescription = freezed,
  }) {
    return _then(
      _Question(
        id: null == id ? _self.id : id as int,
        examId: null == examId ? _self.examId : examId as String,
        subject: null == subject ? _self.subject : subject as String,
        topic: null == topic ? _self.topic : topic as String,
        difficulty: null == difficulty ? _self.difficulty : difficulty as String,
        text: null == text ? _self.text : text as String,
        options: null == options ? _self.options : options as List<String>,
        correctOptionIndexes: null == correctOptionIndexes
            ? _self.correctOptionIndexes
            : correctOptionIndexes as List<int>,
        explanation: null == explanation
            ? _self.explanation
            : explanation as String,
        points: null == points ? _self.points : points as double,
        textHi: freezed == textHi ? _self.textHi : textHi as String?,
        optionsHi:
            freezed == optionsHi ? _self.optionsHi : optionsHi as List<String>?,
        explanationHi: freezed == explanationHi
            ? _self.explanationHi
            : explanationHi as String?,
        textPa: freezed == textPa ? _self.textPa : textPa as String?,
        optionsPa:
            freezed == optionsPa ? _self.optionsPa : optionsPa as List<String>?,
        explanationPa: freezed == explanationPa
            ? _self.explanationPa
            : explanationPa as String?,
        seatingDiagram: freezed == seatingDiagram
            ? _self.seatingDiagram
            : seatingDiagram as Map<String, dynamic>?,
        seatingExplanationFlow: freezed == seatingExplanationFlow
            ? _self.seatingExplanationFlow
            : seatingExplanationFlow as Map<String, dynamic>?,
        imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl as String?,
        questionType:
            freezed == questionType ? _self.questionType : questionType as String?,
        diSetId: freezed == diSetId ? _self.diSetId : diSetId as int?,
        diSetTitle:
            freezed == diSetTitle ? _self.diSetTitle : diSetTitle as String?,
        diSetImageUrl: freezed == diSetImageUrl
            ? _self.diSetImageUrl
            : diSetImageUrl as String?,
        diSetDescription: freezed == diSetDescription
            ? _self.diSetDescription
            : diSetDescription as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _Question implements Question {
  const _Question({
    required this.id,
    required this.examId,
    required this.subject,
    required this.topic,
    required this.difficulty,
    required this.text,
    required final List<String> options,
    required final List<int> correctOptionIndexes,
    required this.explanation,
    required this.points,
    this.textHi,
    final List<String>? optionsHi,
    this.explanationHi,
    this.textPa,
    final List<String>? optionsPa,
    this.explanationPa,
    final Map<String, dynamic>? seatingDiagram,
    final Map<String, dynamic>? seatingExplanationFlow,
    this.imageUrl,
    this.questionType,
    this.diSetId,
    this.diSetTitle,
    this.diSetImageUrl,
    this.diSetDescription,
  })  : _options = options,
        _correctOptionIndexes = correctOptionIndexes,
        _optionsHi = optionsHi,
        _optionsPa = optionsPa,
        _seatingDiagram = seatingDiagram,
        _seatingExplanationFlow = seatingExplanationFlow;

  factory _Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  @override
  final int id;
  @override
  final String examId;
  @override
  final String subject;
  @override
  final String topic;
  @override
  final String difficulty;
  @override
  final String text;

  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    return EqualUnmodifiableListView(_options);
  }

  final List<int> _correctOptionIndexes;
  @override
  List<int> get correctOptionIndexes {
    if (_correctOptionIndexes is EqualUnmodifiableListView) {
      return _correctOptionIndexes;
    }
    return EqualUnmodifiableListView(_correctOptionIndexes);
  }

  @override
  final String explanation;
  @override
  final double points;
  @override
  final String? textHi;

  final List<String>? _optionsHi;
  @override
  List<String>? get optionsHi {
    final value = _optionsHi;
    if (value == null) return null;
    if (value is EqualUnmodifiableListView) return value;
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? explanationHi;
  @override
  final String? textPa;

  final List<String>? _optionsPa;
  @override
  List<String>? get optionsPa {
    final value = _optionsPa;
    if (value == null) return null;
    if (value is EqualUnmodifiableListView) return value;
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? explanationPa;

  final Map<String, dynamic>? _seatingDiagram;
  @override
  Map<String, dynamic>? get seatingDiagram {
    final value = _seatingDiagram;
    if (value == null) return null;
    if (value is EqualUnmodifiableMapView) return value;
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _seatingExplanationFlow;
  @override
  Map<String, dynamic>? get seatingExplanationFlow {
    final value = _seatingExplanationFlow;
    if (value == null) return null;
    if (value is EqualUnmodifiableMapView) return value;
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? imageUrl;
  @override
  final String? questionType;
  @override
  final int? diSetId;
  @override
  final String? diSetTitle;
  @override
  final String? diSetImageUrl;
  @override
  final String? diSetDescription;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuestionCopyWith<_Question> get copyWith =>
      _$QuestionCopyWithImpl<_Question>(this, _$identity);

  @override
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Question &&
            other.id == id &&
            other.examId == examId &&
            other.subject == subject &&
            other.topic == topic &&
            other.difficulty == difficulty &&
            other.text == text &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            const DeepCollectionEquality()
                .equals(other._correctOptionIndexes, _correctOptionIndexes) &&
            other.explanation == explanation &&
            other.points == points &&
            other.textHi == textHi &&
            const DeepCollectionEquality().equals(other._optionsHi, _optionsHi) &&
            other.explanationHi == explanationHi &&
            other.textPa == textPa &&
            const DeepCollectionEquality().equals(other._optionsPa, _optionsPa) &&
            other.explanationPa == explanationPa &&
            const DeepCollectionEquality()
                .equals(other._seatingDiagram, _seatingDiagram) &&
            const DeepCollectionEquality().equals(
              other._seatingExplanationFlow,
              _seatingExplanationFlow,
            ) &&
            other.imageUrl == imageUrl &&
            other.questionType == questionType &&
            other.diSetId == diSetId &&
            other.diSetTitle == diSetTitle &&
            other.diSetImageUrl == diSetImageUrl &&
            other.diSetDescription == diSetDescription);
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        examId,
        subject,
        topic,
        difficulty,
        text,
        const DeepCollectionEquality().hash(_options),
        const DeepCollectionEquality().hash(_correctOptionIndexes),
        explanation,
        points,
        textHi,
        const DeepCollectionEquality().hash(_optionsHi),
        explanationHi,
        textPa,
        const DeepCollectionEquality().hash(_optionsPa),
        explanationPa,
        const DeepCollectionEquality().hash(_seatingDiagram),
        const DeepCollectionEquality().hash(_seatingExplanationFlow),
        imageUrl,
        questionType,
        diSetId,
        diSetTitle,
        diSetImageUrl,
        diSetDescription,
      ]);

  @override
  String toString() {
    return 'Question(id: $id, examId: $examId, subject: $subject, topic: $topic, difficulty: $difficulty, text: $text, options: $options, correctOptionIndexes: $correctOptionIndexes, explanation: $explanation, points: $points, textHi: $textHi, optionsHi: $optionsHi, explanationHi: $explanationHi, textPa: $textPa, optionsPa: $optionsPa, explanationPa: $explanationPa, seatingDiagram: $seatingDiagram, seatingExplanationFlow: $seatingExplanationFlow, imageUrl: $imageUrl, questionType: $questionType, diSetId: $diSetId, diSetTitle: $diSetTitle, diSetImageUrl: $diSetImageUrl, diSetDescription: $diSetDescription)';
  }
}

// dart format on
