// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Result {

 String get id; String get attemptId; String get userId; String get examId; double get score; double get maxScore; double get accuracy; int get correctCount; int get incorrectCount; int get skippedCount; int? get rank; double? get percentile; DateTime get calculatedAt;
/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultCopyWith<Result> get copyWith => _$ResultCopyWithImpl<Result>(this as Result, _$identity);

  /// Serializes this Result to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result&&(identical(other.id, id) || other.id == id)&&(identical(other.attemptId, attemptId) || other.attemptId == attemptId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.score, score) || other.score == score)&&(identical(other.maxScore, maxScore) || other.maxScore == maxScore)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.incorrectCount, incorrectCount) || other.incorrectCount == incorrectCount)&&(identical(other.skippedCount, skippedCount) || other.skippedCount == skippedCount)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.percentile, percentile) || other.percentile == percentile)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,attemptId,userId,examId,score,maxScore,accuracy,correctCount,incorrectCount,skippedCount,rank,percentile,calculatedAt);

@override
String toString() {
  return 'Result(id: $id, attemptId: $attemptId, userId: $userId, examId: $examId, score: $score, maxScore: $maxScore, accuracy: $accuracy, correctCount: $correctCount, incorrectCount: $incorrectCount, skippedCount: $skippedCount, rank: $rank, percentile: $percentile, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class $ResultCopyWith<$Res>  {
  factory $ResultCopyWith(Result value, $Res Function(Result) _then) = _$ResultCopyWithImpl;
@useResult
$Res call({
 String id, String attemptId, String userId, String examId, double score, double maxScore, double accuracy, int correctCount, int incorrectCount, int skippedCount, int? rank, double? percentile, DateTime calculatedAt
});




}
/// @nodoc
class _$ResultCopyWithImpl<$Res>
    implements $ResultCopyWith<$Res> {
  _$ResultCopyWithImpl(this._self, this._then);

  final Result _self;
  final $Res Function(Result) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? attemptId = null,Object? userId = null,Object? examId = null,Object? score = null,Object? maxScore = null,Object? accuracy = null,Object? correctCount = null,Object? incorrectCount = null,Object? skippedCount = null,Object? rank = freezed,Object? percentile = freezed,Object? calculatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attemptId: null == attemptId ? _self.attemptId : attemptId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,maxScore: null == maxScore ? _self.maxScore : maxScore // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,incorrectCount: null == incorrectCount ? _self.incorrectCount : incorrectCount // ignore: cast_nullable_to_non_nullable
as int,skippedCount: null == skippedCount ? _self.skippedCount : skippedCount // ignore: cast_nullable_to_non_nullable
as int,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,percentile: freezed == percentile ? _self.percentile : percentile // ignore: cast_nullable_to_non_nullable
as double?,calculatedAt: null == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns on Result {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Result value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Result value)  $default,){
final _that = this;
switch (_that) {
case _Result():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Result value)?  $default,){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String attemptId,  String userId,  String examId,  double score,  double maxScore,  double accuracy,  int correctCount,  int incorrectCount,  int skippedCount,  int? rank,  double? percentile,  DateTime calculatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.id,_that.attemptId,_that.userId,_that.examId,_that.score,_that.maxScore,_that.accuracy,_that.correctCount,_that.incorrectCount,_that.skippedCount,_that.rank,_that.percentile,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String attemptId,  String userId,  String examId,  double score,  double maxScore,  double accuracy,  int correctCount,  int incorrectCount,  int skippedCount,  int? rank,  double? percentile,  DateTime calculatedAt)  $default,) {final _that = this;
switch (_that) {
case _Result():
return $default(_that.id,_that.attemptId,_that.userId,_that.examId,_that.score,_that.maxScore,_that.accuracy,_that.correctCount,_that.incorrectCount,_that.skippedCount,_that.rank,_that.percentile,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String attemptId,  String userId,  String examId,  double score,  double maxScore,  double accuracy,  int correctCount,  int incorrectCount,  int skippedCount,  int? rank,  double? percentile,  DateTime calculatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.id,_that.attemptId,_that.userId,_that.examId,_that.score,_that.maxScore,_that.accuracy,_that.correctCount,_that.incorrectCount,_that.skippedCount,_that.rank,_that.percentile,_that.calculatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Result implements Result {
  const _Result({required this.id, required this.attemptId, required this.userId, required this.examId, required this.score, required this.maxScore, required this.accuracy, required this.correctCount, required this.incorrectCount, required this.skippedCount, this.rank, this.percentile, required this.calculatedAt});
  factory _Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);

@override final  String id;
@override final  String attemptId;
@override final  String userId;
@override final  String examId;
@override final  double score;
@override final  double maxScore;
@override final  double accuracy;
@override final  int correctCount;
@override final  int incorrectCount;
@override final  int skippedCount;
@override final  int? rank;
@override final  double? percentile;
@override final  DateTime calculatedAt;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultCopyWith<_Result> get copyWith => __$ResultCopyWithImpl<_Result>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Result&&(identical(other.id, id) || other.id == id)&&(identical(other.attemptId, attemptId) || other.attemptId == attemptId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.score, score) || other.score == score)&&(identical(other.maxScore, maxScore) || other.maxScore == maxScore)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.correctCount, correctCount) || other.correctCount == correctCount)&&(identical(other.incorrectCount, incorrectCount) || other.incorrectCount == incorrectCount)&&(identical(other.skippedCount, skippedCount) || other.skippedCount == skippedCount)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.percentile, percentile) || other.percentile == percentile)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,attemptId,userId,examId,score,maxScore,accuracy,correctCount,incorrectCount,skippedCount,rank,percentile,calculatedAt);

@override
String toString() {
  return 'Result(id: $id, attemptId: $attemptId, userId: $userId, examId: $examId, score: $score, maxScore: $maxScore, accuracy: $accuracy, correctCount: $correctCount, incorrectCount: $incorrectCount, skippedCount: $skippedCount, rank: $rank, percentile: $percentile, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class _$ResultCopyWith<$Res> implements $ResultCopyWith<$Res> {
  factory _$ResultCopyWith(_Result value, $Res Function(_Result) _then) = __$ResultCopyWithImpl;
@override @useResult
$Res call({
 String id, String attemptId, String userId, String examId, double score, double maxScore, double accuracy, int correctCount, int incorrectCount, int skippedCount, int? rank, double? percentile, DateTime calculatedAt
});




}
/// @nodoc
class __$ResultCopyWithImpl<$Res>
    implements _$ResultCopyWith<$Res> {
  __$ResultCopyWithImpl(this._self, this._then);

  final _Result _self;
  final $Res Function(_Result) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? attemptId = null,Object? userId = null,Object? examId = null,Object? score = null,Object? maxScore = null,Object? accuracy = null,Object? correctCount = null,Object? incorrectCount = null,Object? skippedCount = null,Object? rank = freezed,Object? percentile = freezed,Object? calculatedAt = null,}) {
  return _then(_Result(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attemptId: null == attemptId ? _self.attemptId : attemptId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,maxScore: null == maxScore ? _self.maxScore : maxScore // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,correctCount: null == correctCount ? _self.correctCount : correctCount // ignore: cast_nullable_to_non_nullable
as int,incorrectCount: null == incorrectCount ? _self.incorrectCount : incorrectCount // ignore: cast_nullable_to_non_nullable
as int,skippedCount: null == skippedCount ? _self.skippedCount : skippedCount // ignore: cast_nullable_to_non_nullable
as int,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,percentile: freezed == percentile ? _self.percentile : percentile // ignore: cast_nullable_to_non_nullable
as double?,calculatedAt: null == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
