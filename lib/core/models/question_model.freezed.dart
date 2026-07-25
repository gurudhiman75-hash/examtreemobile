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

 int get id; String get examId; String get subject; String get topic; String get difficulty; String get text; List<String> get options; List<int> get correctOptionIndexes; String get explanation; double get points; String? get textHi; List<String>? get optionsHi; String? get explanationHi; String? get textPa; List<String>? get optionsPa; String? get explanationPa; Map<String, dynamic>? get seatingDiagram; Map<String, dynamic>? get seatingExplanationFlow; String? get imageUrl; String? get questionType; int? get diSetId; String? get diSetTitle; String? get diSetImageUrl; String? get diSetDescription;
/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionCopyWith<Question> get copyWith => _$QuestionCopyWithImpl<Question>(this as Question, _$identity);

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Question&&(identical(other.id, id) || other.id == id)&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.options, options)&&const DeepCollectionEquality().equals(other.correctOptionIndexes, correctOptionIndexes)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.points, points) || other.points == points)&&(identical(other.textHi, textHi) || other.textHi == textHi)&&const DeepCollectionEquality().equals(other.optionsHi, optionsHi)&&(identical(other.explanationHi, explanationHi) || other.explanationHi == explanationHi)&&(identical(other.textPa, textPa) || other.textPa == textPa)&&const DeepCollectionEquality().equals(other.optionsPa, optionsPa)&&(identical(other.explanationPa, explanationPa) || other.explanationPa == explanationPa)&&const DeepCollectionEquality().equals(other.seatingDiagram, seatingDiagram)&&const DeepCollectionEquality().equals(other.seatingExplanationFlow, seatingExplanationFlow)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.questionType, questionType) || other.questionType == questionType)&&(identical(other.diSetId, diSetId) || other.diSetId == diSetId)&&(identical(other.diSetTitle, diSetTitle) || other.diSetTitle == diSetTitle)&&(identical(other.diSetImageUrl, diSetImageUrl) || other.diSetImageUrl == diSetImageUrl)&&(identical(other.diSetDescription, diSetDescription) || other.diSetDescription == diSetDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,examId,subject,topic,difficulty,text,const DeepCollectionEquality().hash(options),const DeepCollectionEquality().hash(correctOptionIndexes),explanation,points,textHi,const DeepCollectionEquality().hash(optionsHi),explanationHi,textPa,const DeepCollectionEquality().hash(optionsPa),explanationPa,const DeepCollectionEquality().hash(seatingDiagram),const DeepCollectionEquality().hash(seatingExplanationFlow),imageUrl,questionType,diSetId,diSetTitle,diSetImageUrl,diSetDescription]);

@override
String toString() {
  return 'Question(id: $id, examId: $examId, subject: $subject, topic: $topic, difficulty: $difficulty, text: $text, options: $options, correctOptionIndexes: $correctOptionIndexes, explanation: $explanation, points: $points, textHi: $textHi, optionsHi: $optionsHi, explanationHi: $explanationHi, textPa: $textPa, optionsPa: $optionsPa, explanationPa: $explanationPa, seatingDiagram: $seatingDiagram, seatingExplanationFlow: $seatingExplanationFlow, imageUrl: $imageUrl, questionType: $questionType, diSetId: $diSetId, diSetTitle: $diSetTitle, diSetImageUrl: $diSetImageUrl, diSetDescription: $diSetDescription)';
}


}

/// @nodoc
abstract mixin class $QuestionCopyWith<$Res>  {
  factory $QuestionCopyWith(Question value, $Res Function(Question) _then) = _$QuestionCopyWithImpl;
@useResult
$Res call({
 int id, String examId, String subject, String topic, String difficulty, String text, List<String> options, List<int> correctOptionIndexes, String explanation, double points, String? textHi, List<String>? optionsHi, String? explanationHi, String? textPa, List<String>? optionsPa, String? explanationPa, Map<String, dynamic>? seatingDiagram, Map<String, dynamic>? seatingExplanationFlow, String? imageUrl, String? questionType, int? diSetId, String? diSetTitle, String? diSetImageUrl, String? diSetDescription
});




}
/// @nodoc
class _$QuestionCopyWithImpl<$Res>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._self, this._then);

  final Question _self;
  final $Res Function(Question) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? examId = null,Object? subject = null,Object? topic = null,Object? difficulty = null,Object? text = null,Object? options = null,Object? correctOptionIndexes = null,Object? explanation = null,Object? points = null,Object? textHi = freezed,Object? optionsHi = freezed,Object? explanationHi = freezed,Object? textPa = freezed,Object? optionsPa = freezed,Object? explanationPa = freezed,Object? seatingDiagram = freezed,Object? seatingExplanationFlow = freezed,Object? imageUrl = freezed,Object? questionType = freezed,Object? diSetId = freezed,Object? diSetTitle = freezed,Object? diSetImageUrl = freezed,Object? diSetDescription = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<String>,correctOptionIndexes: null == correctOptionIndexes ? _self.correctOptionIndexes : correctOptionIndexes // ignore: cast_nullable_to_non_nullable
as List<int>,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as double,textHi: freezed == textHi ? _self.textHi : textHi // ignore: cast_nullable_to_non_nullable
as String?,optionsHi: freezed == optionsHi ? _self.optionsHi : optionsHi // ignore: cast_nullable_to_non_nullable
as List<String>?,explanationHi: freezed == explanationHi ? _self.explanationHi : explanationHi // ignore: cast_nullable_to_non_nullable
as String?,textPa: freezed == textPa ? _self.textPa : textPa // ignore: cast_nullable_to_non_nullable
as String?,optionsPa: freezed == optionsPa ? _self.optionsPa : optionsPa // ignore: cast_nullable_to_non_nullable
as List<String>?,explanationPa: freezed == explanationPa ? _self.explanationPa : explanationPa // ignore: cast_nullable_to_non_nullable
as String?,seatingDiagram: freezed == seatingDiagram ? _self.seatingDiagram : seatingDiagram // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,seatingExplanationFlow: freezed == seatingExplanationFlow ? _self.seatingExplanationFlow : seatingExplanationFlow // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,questionType: freezed == questionType ? _self.questionType : questionType // ignore: cast_nullable_to_non_nullable
as String?,diSetId: freezed == diSetId ? _self.diSetId : diSetId // ignore: cast_nullable_to_non_nullable
as int?,diSetTitle: freezed == diSetTitle ? _self.diSetTitle : diSetTitle // ignore: cast_nullable_to_non_nullable
as String?,diSetImageUrl: freezed == diSetImageUrl ? _self.diSetImageUrl : diSetImageUrl // ignore: cast_nullable_to_non_nullable
as String?,diSetDescription: freezed == diSetDescription ? _self.diSetDescription : diSetDescription // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Question].
extension QuestionPatterns on Question {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Question value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Question value)  $default,){
final _that = this;
switch (_that) {
case _Question():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Question value)?  $default,){
final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String examId,  String subject,  String topic,  String difficulty,  String text,  List<String> options,  List<int> correctOptionIndexes,  String explanation,  double points,  String? textHi,  List<String>? optionsHi,  String? explanationHi,  String? textPa,  List<String>? optionsPa,  String? explanationPa,  Map<String, dynamic>? seatingDiagram,  Map<String, dynamic>? seatingExplanationFlow,  String? imageUrl,  String? questionType,  int? diSetId,  String? diSetTitle,  String? diSetImageUrl,  String? diSetDescription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that.id,_that.examId,_that.subject,_that.topic,_that.difficulty,_that.text,_that.options,_that.correctOptionIndexes,_that.explanation,_that.points,_that.textHi,_that.optionsHi,_that.explanationHi,_that.textPa,_that.optionsPa,_that.explanationPa,_that.seatingDiagram,_that.seatingExplanationFlow,_that.imageUrl,_that.questionType,_that.diSetId,_that.diSetTitle,_that.diSetImageUrl,_that.diSetDescription);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String examId,  String subject,  String topic,  String difficulty,  String text,  List<String> options,  List<int> correctOptionIndexes,  String explanation,  double points,  String? textHi,  List<String>? optionsHi,  String? explanationHi,  String? textPa,  List<String>? optionsPa,  String? explanationPa,  Map<String, dynamic>? seatingDiagram,  Map<String, dynamic>? seatingExplanationFlow,  String? imageUrl,  String? questionType,  int? diSetId,  String? diSetTitle,  String? diSetImageUrl,  String? diSetDescription)  $default,) {final _that = this;
switch (_that) {
case _Question():
return $default(_that.id,_that.examId,_that.subject,_that.topic,_that.difficulty,_that.text,_that.options,_that.correctOptionIndexes,_that.explanation,_that.points,_that.textHi,_that.optionsHi,_that.explanationHi,_that.textPa,_that.optionsPa,_that.explanationPa,_that.seatingDiagram,_that.seatingExplanationFlow,_that.imageUrl,_that.questionType,_that.diSetId,_that.diSetTitle,_that.diSetImageUrl,_that.diSetDescription);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String examId,  String subject,  String topic,  String difficulty,  String text,  List<String> options,  List<int> correctOptionIndexes,  String explanation,  double points,  String? textHi,  List<String>? optionsHi,  String? explanationHi,  String? textPa,  List<String>? optionsPa,  String? explanationPa,  Map<String, dynamic>? seatingDiagram,  Map<String, dynamic>? seatingExplanationFlow,  String? imageUrl,  String? questionType,  int? diSetId,  String? diSetTitle,  String? diSetImageUrl,  String? diSetDescription)?  $default,) {final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that.id,_that.examId,_that.subject,_that.topic,_that.difficulty,_that.text,_that.options,_that.correctOptionIndexes,_that.explanation,_that.points,_that.textHi,_that.optionsHi,_that.explanationHi,_that.textPa,_that.optionsPa,_that.explanationPa,_that.seatingDiagram,_that.seatingExplanationFlow,_that.imageUrl,_that.questionType,_that.diSetId,_that.diSetTitle,_that.diSetImageUrl,_that.diSetDescription);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Question implements Question {
  const _Question({required this.id, required this.examId, required this.subject, required this.topic, required this.difficulty, required this.text, required final  List<String> options, required final  List<int> correctOptionIndexes, required this.explanation, required this.points, this.textHi, final  List<String>? optionsHi, this.explanationHi, this.textPa, final  List<String>? optionsPa, this.explanationPa, final  Map<String, dynamic>? seatingDiagram, final  Map<String, dynamic>? seatingExplanationFlow, this.imageUrl, this.questionType, this.diSetId, this.diSetTitle, this.diSetImageUrl, this.diSetDescription}): _options = options,_correctOptionIndexes = correctOptionIndexes,_optionsHi = optionsHi,_optionsPa = optionsPa,_seatingDiagram = seatingDiagram,_seatingExplanationFlow = seatingExplanationFlow;
  factory _Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);

@override final  int id;
@override final  String examId;
@override final  String subject;
@override final  String topic;
@override final  String difficulty;
@override final  String text;
 final  List<String> _options;
@override List<String> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  List<int> _correctOptionIndexes;
@override List<int> get correctOptionIndexes {
  if (_correctOptionIndexes is EqualUnmodifiableListView) return _correctOptionIndexes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_correctOptionIndexes);
}

@override final  String explanation;
@override final  double points;
@override final  String? textHi;
 final  List<String>? _optionsHi;
@override List<String>? get optionsHi {
  final value = _optionsHi;
  if (value == null) return null;
  if (_optionsHi is EqualUnmodifiableListView) return _optionsHi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? explanationHi;
@override final  String? textPa;
 final  List<String>? _optionsPa;
@override List<String>? get optionsPa {
  final value = _optionsPa;
  if (value == null) return null;
  if (_optionsPa is EqualUnmodifiableListView) return _optionsPa;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? explanationPa;
 final  Map<String, dynamic>? _seatingDiagram;
@override Map<String, dynamic>? get seatingDiagram {
  final value = _seatingDiagram;
  if (value == null) return null;
  if (_seatingDiagram is EqualUnmodifiableMapView) return _seatingDiagram;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _seatingExplanationFlow;
@override Map<String, dynamic>? get seatingExplanationFlow {
  final value = _seatingExplanationFlow;
  if (value == null) return null;
  if (_seatingExplanationFlow is EqualUnmodifiableMapView) return _seatingExplanationFlow;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? imageUrl;
@override final  String? questionType;
@override final  int? diSetId;
@override final  String? diSetTitle;
@override final  String? diSetImageUrl;
@override final  String? diSetDescription;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionCopyWith<_Question> get copyWith => __$QuestionCopyWithImpl<_Question>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Question&&(identical(other.id, id) || other.id == id)&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._options, _options)&&const DeepCollectionEquality().equals(other._correctOptionIndexes, _correctOptionIndexes)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.points, points) || other.points == points)&&(identical(other.textHi, textHi) || other.textHi == textHi)&&const DeepCollectionEquality().equals(other._optionsHi, _optionsHi)&&(identical(other.explanationHi, explanationHi) || other.explanationHi == explanationHi)&&(identical(other.textPa, textPa) || other.textPa == textPa)&&const DeepCollectionEquality().equals(other._optionsPa, _optionsPa)&&(identical(other.explanationPa, explanationPa) || other.explanationPa == explanationPa)&&const DeepCollectionEquality().equals(other._seatingDiagram, _seatingDiagram)&&const DeepCollectionEquality().equals(other._seatingExplanationFlow, _seatingExplanationFlow)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.questionType, questionType) || other.questionType == questionType)&&(identical(other.diSetId, diSetId) || other.diSetId == diSetId)&&(identical(other.diSetTitle, diSetTitle) || other.diSetTitle == diSetTitle)&&(identical(other.diSetImageUrl, diSetImageUrl) || other.diSetImageUrl == diSetImageUrl)&&(identical(other.diSetDescription, diSetDescription) || other.diSetDescription == diSetDescription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,examId,subject,topic,difficulty,text,const DeepCollectionEquality().hash(_options),const DeepCollectionEquality().hash(_correctOptionIndexes),explanation,points,textHi,const DeepCollectionEquality().hash(_optionsHi),explanationHi,textPa,const DeepCollectionEquality().hash(_optionsPa),explanationPa,const DeepCollectionEquality().hash(_seatingDiagram),const DeepCollectionEquality().hash(_seatingExplanationFlow),imageUrl,questionType,diSetId,diSetTitle,diSetImageUrl,diSetDescription]);

@override
String toString() {
  return 'Question(id: $id, examId: $examId, subject: $subject, topic: $topic, difficulty: $difficulty, text: $text, options: $options, correctOptionIndexes: $correctOptionIndexes, explanation: $explanation, points: $points, textHi: $textHi, optionsHi: $optionsHi, explanationHi: $explanationHi, textPa: $textPa, optionsPa: $optionsPa, explanationPa: $explanationPa, seatingDiagram: $seatingDiagram, seatingExplanationFlow: $seatingExplanationFlow, imageUrl: $imageUrl, questionType: $questionType, diSetId: $diSetId, diSetTitle: $diSetTitle, diSetImageUrl: $diSetImageUrl, diSetDescription: $diSetDescription)';
}


}

/// @nodoc
abstract mixin class _$QuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory _$QuestionCopyWith(_Question value, $Res Function(_Question) _then) = __$QuestionCopyWithImpl;
@override @useResult
$Res call({
 int id, String examId, String subject, String topic, String difficulty, String text, List<String> options, List<int> correctOptionIndexes, String explanation, double points, String? textHi, List<String>? optionsHi, String? explanationHi, String? textPa, List<String>? optionsPa, String? explanationPa, Map<String, dynamic>? seatingDiagram, Map<String, dynamic>? seatingExplanationFlow, String? imageUrl, String? questionType, int? diSetId, String? diSetTitle, String? diSetImageUrl, String? diSetDescription
});




}
/// @nodoc
class __$QuestionCopyWithImpl<$Res>
    implements _$QuestionCopyWith<$Res> {
  __$QuestionCopyWithImpl(this._self, this._then);

  final _Question _self;
  final $Res Function(_Question) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? examId = null,Object? subject = null,Object? topic = null,Object? difficulty = null,Object? text = null,Object? options = null,Object? correctOptionIndexes = null,Object? explanation = null,Object? points = null,Object? textHi = freezed,Object? optionsHi = freezed,Object? explanationHi = freezed,Object? textPa = freezed,Object? optionsPa = freezed,Object? explanationPa = freezed,Object? seatingDiagram = freezed,Object? seatingExplanationFlow = freezed,Object? imageUrl = freezed,Object? questionType = freezed,Object? diSetId = freezed,Object? diSetTitle = freezed,Object? diSetImageUrl = freezed,Object? diSetDescription = freezed,}) {
  return _then(_Question(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>,correctOptionIndexes: null == correctOptionIndexes ? _self._correctOptionIndexes : correctOptionIndexes // ignore: cast_nullable_to_non_nullable
as List<int>,explanation: null == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as double,textHi: freezed == textHi ? _self.textHi : textHi // ignore: cast_nullable_to_non_nullable
as String?,optionsHi: freezed == optionsHi ? _self._optionsHi : optionsHi // ignore: cast_nullable_to_non_nullable
as List<String>?,explanationHi: freezed == explanationHi ? _self.explanationHi : explanationHi // ignore: cast_nullable_to_non_nullable
as String?,textPa: freezed == textPa ? _self.textPa : textPa // ignore: cast_nullable_to_non_nullable
as String?,optionsPa: freezed == optionsPa ? _self._optionsPa : optionsPa // ignore: cast_nullable_to_non_nullable
as List<String>?,explanationPa: freezed == explanationPa ? _self.explanationPa : explanationPa // ignore: cast_nullable_to_non_nullable
as String?,seatingDiagram: freezed == seatingDiagram ? _self._seatingDiagram : seatingDiagram // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,seatingExplanationFlow: freezed == seatingExplanationFlow ? _self._seatingExplanationFlow : seatingExplanationFlow // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,questionType: freezed == questionType ? _self.questionType : questionType // ignore: cast_nullable_to_non_nullable
as String?,diSetId: freezed == diSetId ? _self.diSetId : diSetId // ignore: cast_nullable_to_non_nullable
as int?,diSetTitle: freezed == diSetTitle ? _self.diSetTitle : diSetTitle // ignore: cast_nullable_to_non_nullable
as String?,diSetImageUrl: freezed == diSetImageUrl ? _self.diSetImageUrl : diSetImageUrl // ignore: cast_nullable_to_non_nullable
as String?,diSetDescription: freezed == diSetDescription ? _self.diSetDescription : diSetDescription // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
