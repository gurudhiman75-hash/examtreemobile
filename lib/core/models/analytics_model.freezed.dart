// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Analytics {

 String get id; String get userId; int get totalTestsAttempted; double get averageScore; double get averageAccuracy; Map<String, double> get topicPerformance; List<String> get strongestTopics; List<String> get weakestTopics; int get averageTimePerQuestion; DateTime get updatedAt;
/// Create a copy of Analytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsCopyWith<Analytics> get copyWith => _$AnalyticsCopyWithImpl<Analytics>(this as Analytics, _$identity);

  /// Serializes this Analytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Analytics&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalTestsAttempted, totalTestsAttempted) || other.totalTestsAttempted == totalTestsAttempted)&&(identical(other.averageScore, averageScore) || other.averageScore == averageScore)&&(identical(other.averageAccuracy, averageAccuracy) || other.averageAccuracy == averageAccuracy)&&const DeepCollectionEquality().equals(other.topicPerformance, topicPerformance)&&const DeepCollectionEquality().equals(other.strongestTopics, strongestTopics)&&const DeepCollectionEquality().equals(other.weakestTopics, weakestTopics)&&(identical(other.averageTimePerQuestion, averageTimePerQuestion) || other.averageTimePerQuestion == averageTimePerQuestion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,totalTestsAttempted,averageScore,averageAccuracy,const DeepCollectionEquality().hash(topicPerformance),const DeepCollectionEquality().hash(strongestTopics),const DeepCollectionEquality().hash(weakestTopics),averageTimePerQuestion,updatedAt);

@override
String toString() {
  return 'Analytics(id: $id, userId: $userId, totalTestsAttempted: $totalTestsAttempted, averageScore: $averageScore, averageAccuracy: $averageAccuracy, topicPerformance: $topicPerformance, strongestTopics: $strongestTopics, weakestTopics: $weakestTopics, averageTimePerQuestion: $averageTimePerQuestion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AnalyticsCopyWith<$Res>  {
  factory $AnalyticsCopyWith(Analytics value, $Res Function(Analytics) _then) = _$AnalyticsCopyWithImpl;
@useResult
$Res call({
 String id, String userId, int totalTestsAttempted, double averageScore, double averageAccuracy, Map<String, double> topicPerformance, List<String> strongestTopics, List<String> weakestTopics, int averageTimePerQuestion, DateTime updatedAt
});




}
/// @nodoc
class _$AnalyticsCopyWithImpl<$Res>
    implements $AnalyticsCopyWith<$Res> {
  _$AnalyticsCopyWithImpl(this._self, this._then);

  final Analytics _self;
  final $Res Function(Analytics) _then;

/// Create a copy of Analytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? totalTestsAttempted = null,Object? averageScore = null,Object? averageAccuracy = null,Object? topicPerformance = null,Object? strongestTopics = null,Object? weakestTopics = null,Object? averageTimePerQuestion = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalTestsAttempted: null == totalTestsAttempted ? _self.totalTestsAttempted : totalTestsAttempted // ignore: cast_nullable_to_non_nullable
as int,averageScore: null == averageScore ? _self.averageScore : averageScore // ignore: cast_nullable_to_non_nullable
as double,averageAccuracy: null == averageAccuracy ? _self.averageAccuracy : averageAccuracy // ignore: cast_nullable_to_non_nullable
as double,topicPerformance: null == topicPerformance ? _self.topicPerformance : topicPerformance // ignore: cast_nullable_to_non_nullable
as Map<String, double>,strongestTopics: null == strongestTopics ? _self.strongestTopics : strongestTopics // ignore: cast_nullable_to_non_nullable
as List<String>,weakestTopics: null == weakestTopics ? _self.weakestTopics : weakestTopics // ignore: cast_nullable_to_non_nullable
as List<String>,averageTimePerQuestion: null == averageTimePerQuestion ? _self.averageTimePerQuestion : averageTimePerQuestion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Analytics].
extension AnalyticsPatterns on Analytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Analytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Analytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Analytics value)  $default,){
final _that = this;
switch (_that) {
case _Analytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Analytics value)?  $default,){
final _that = this;
switch (_that) {
case _Analytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  int totalTestsAttempted,  double averageScore,  double averageAccuracy,  Map<String, double> topicPerformance,  List<String> strongestTopics,  List<String> weakestTopics,  int averageTimePerQuestion,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Analytics() when $default != null:
return $default(_that.id,_that.userId,_that.totalTestsAttempted,_that.averageScore,_that.averageAccuracy,_that.topicPerformance,_that.strongestTopics,_that.weakestTopics,_that.averageTimePerQuestion,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  int totalTestsAttempted,  double averageScore,  double averageAccuracy,  Map<String, double> topicPerformance,  List<String> strongestTopics,  List<String> weakestTopics,  int averageTimePerQuestion,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Analytics():
return $default(_that.id,_that.userId,_that.totalTestsAttempted,_that.averageScore,_that.averageAccuracy,_that.topicPerformance,_that.strongestTopics,_that.weakestTopics,_that.averageTimePerQuestion,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  int totalTestsAttempted,  double averageScore,  double averageAccuracy,  Map<String, double> topicPerformance,  List<String> strongestTopics,  List<String> weakestTopics,  int averageTimePerQuestion,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Analytics() when $default != null:
return $default(_that.id,_that.userId,_that.totalTestsAttempted,_that.averageScore,_that.averageAccuracy,_that.topicPerformance,_that.strongestTopics,_that.weakestTopics,_that.averageTimePerQuestion,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Analytics implements Analytics {
  const _Analytics({required this.id, required this.userId, required this.totalTestsAttempted, required this.averageScore, required this.averageAccuracy, final  Map<String, double> topicPerformance = const {}, final  List<String> strongestTopics = const [], final  List<String> weakestTopics = const [], required this.averageTimePerQuestion, required this.updatedAt}): _topicPerformance = topicPerformance,_strongestTopics = strongestTopics,_weakestTopics = weakestTopics;
  factory _Analytics.fromJson(Map<String, dynamic> json) => _$AnalyticsFromJson(json);

@override final  String id;
@override final  String userId;
@override final  int totalTestsAttempted;
@override final  double averageScore;
@override final  double averageAccuracy;
 final  Map<String, double> _topicPerformance;
@override@JsonKey() Map<String, double> get topicPerformance {
  if (_topicPerformance is EqualUnmodifiableMapView) return _topicPerformance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_topicPerformance);
}

 final  List<String> _strongestTopics;
@override@JsonKey() List<String> get strongestTopics {
  if (_strongestTopics is EqualUnmodifiableListView) return _strongestTopics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strongestTopics);
}

 final  List<String> _weakestTopics;
@override@JsonKey() List<String> get weakestTopics {
  if (_weakestTopics is EqualUnmodifiableListView) return _weakestTopics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weakestTopics);
}

@override final  int averageTimePerQuestion;
@override final  DateTime updatedAt;

/// Create a copy of Analytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsCopyWith<_Analytics> get copyWith => __$AnalyticsCopyWithImpl<_Analytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Analytics&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalTestsAttempted, totalTestsAttempted) || other.totalTestsAttempted == totalTestsAttempted)&&(identical(other.averageScore, averageScore) || other.averageScore == averageScore)&&(identical(other.averageAccuracy, averageAccuracy) || other.averageAccuracy == averageAccuracy)&&const DeepCollectionEquality().equals(other._topicPerformance, _topicPerformance)&&const DeepCollectionEquality().equals(other._strongestTopics, _strongestTopics)&&const DeepCollectionEquality().equals(other._weakestTopics, _weakestTopics)&&(identical(other.averageTimePerQuestion, averageTimePerQuestion) || other.averageTimePerQuestion == averageTimePerQuestion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,totalTestsAttempted,averageScore,averageAccuracy,const DeepCollectionEquality().hash(_topicPerformance),const DeepCollectionEquality().hash(_strongestTopics),const DeepCollectionEquality().hash(_weakestTopics),averageTimePerQuestion,updatedAt);

@override
String toString() {
  return 'Analytics(id: $id, userId: $userId, totalTestsAttempted: $totalTestsAttempted, averageScore: $averageScore, averageAccuracy: $averageAccuracy, topicPerformance: $topicPerformance, strongestTopics: $strongestTopics, weakestTopics: $weakestTopics, averageTimePerQuestion: $averageTimePerQuestion, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsCopyWith<$Res> implements $AnalyticsCopyWith<$Res> {
  factory _$AnalyticsCopyWith(_Analytics value, $Res Function(_Analytics) _then) = __$AnalyticsCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, int totalTestsAttempted, double averageScore, double averageAccuracy, Map<String, double> topicPerformance, List<String> strongestTopics, List<String> weakestTopics, int averageTimePerQuestion, DateTime updatedAt
});




}
/// @nodoc
class __$AnalyticsCopyWithImpl<$Res>
    implements _$AnalyticsCopyWith<$Res> {
  __$AnalyticsCopyWithImpl(this._self, this._then);

  final _Analytics _self;
  final $Res Function(_Analytics) _then;

/// Create a copy of Analytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? totalTestsAttempted = null,Object? averageScore = null,Object? averageAccuracy = null,Object? topicPerformance = null,Object? strongestTopics = null,Object? weakestTopics = null,Object? averageTimePerQuestion = null,Object? updatedAt = null,}) {
  return _then(_Analytics(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalTestsAttempted: null == totalTestsAttempted ? _self.totalTestsAttempted : totalTestsAttempted // ignore: cast_nullable_to_non_nullable
as int,averageScore: null == averageScore ? _self.averageScore : averageScore // ignore: cast_nullable_to_non_nullable
as double,averageAccuracy: null == averageAccuracy ? _self.averageAccuracy : averageAccuracy // ignore: cast_nullable_to_non_nullable
as double,topicPerformance: null == topicPerformance ? _self._topicPerformance : topicPerformance // ignore: cast_nullable_to_non_nullable
as Map<String, double>,strongestTopics: null == strongestTopics ? _self._strongestTopics : strongestTopics // ignore: cast_nullable_to_non_nullable
as List<String>,weakestTopics: null == weakestTopics ? _self._weakestTopics : weakestTopics // ignore: cast_nullable_to_non_nullable
as List<String>,averageTimePerQuestion: null == averageTimePerQuestion ? _self.averageTimePerQuestion : averageTimePerQuestion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
