// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Exam {

 String get id; String get title; String get description; int get durationInSeconds; int get totalQuestions; double get totalMarks; int get maxAttempts; double get negativeMarking; String get difficulty; String get status; String get category; List<String> get tags; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Exam
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExamCopyWith<Exam> get copyWith => _$ExamCopyWithImpl<Exam>(this as Exam, _$identity);

  /// Serializes this Exam to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Exam&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationInSeconds, durationInSeconds) || other.durationInSeconds == durationInSeconds)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions)&&(identical(other.totalMarks, totalMarks) || other.totalMarks == totalMarks)&&(identical(other.maxAttempts, maxAttempts) || other.maxAttempts == maxAttempts)&&(identical(other.negativeMarking, negativeMarking) || other.negativeMarking == negativeMarking)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,durationInSeconds,totalQuestions,totalMarks,maxAttempts,negativeMarking,difficulty,status,category,const DeepCollectionEquality().hash(tags),createdAt,updatedAt);

@override
String toString() {
  return 'Exam(id: $id, title: $title, description: $description, durationInSeconds: $durationInSeconds, totalQuestions: $totalQuestions, totalMarks: $totalMarks, maxAttempts: $maxAttempts, negativeMarking: $negativeMarking, difficulty: $difficulty, status: $status, category: $category, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ExamCopyWith<$Res>  {
  factory $ExamCopyWith(Exam value, $Res Function(Exam) _then) = _$ExamCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, int durationInSeconds, int totalQuestions, double totalMarks, int maxAttempts, double negativeMarking, String difficulty, String status, String category, List<String> tags, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ExamCopyWithImpl<$Res>
    implements $ExamCopyWith<$Res> {
  _$ExamCopyWithImpl(this._self, this._then);

  final Exam _self;
  final $Res Function(Exam) _then;

/// Create a copy of Exam
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? durationInSeconds = null,Object? totalQuestions = null,Object? totalMarks = null,Object? maxAttempts = null,Object? negativeMarking = null,Object? difficulty = null,Object? status = null,Object? category = null,Object? tags = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,durationInSeconds: null == durationInSeconds ? _self.durationInSeconds : durationInSeconds // ignore: cast_nullable_to_non_nullable
as int,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,totalMarks: null == totalMarks ? _self.totalMarks : totalMarks // ignore: cast_nullable_to_non_nullable
as double,maxAttempts: null == maxAttempts ? _self.maxAttempts : maxAttempts // ignore: cast_nullable_to_non_nullable
as int,negativeMarking: null == negativeMarking ? _self.negativeMarking : negativeMarking // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Exam].
extension ExamPatterns on Exam {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Exam value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Exam() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Exam value)  $default,){
final _that = this;
switch (_that) {
case _Exam():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Exam value)?  $default,){
final _that = this;
switch (_that) {
case _Exam() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int durationInSeconds,  int totalQuestions,  double totalMarks,  int maxAttempts,  double negativeMarking,  String difficulty,  String status,  String category,  List<String> tags,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Exam() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.durationInSeconds,_that.totalQuestions,_that.totalMarks,_that.maxAttempts,_that.negativeMarking,_that.difficulty,_that.status,_that.category,_that.tags,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int durationInSeconds,  int totalQuestions,  double totalMarks,  int maxAttempts,  double negativeMarking,  String difficulty,  String status,  String category,  List<String> tags,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Exam():
return $default(_that.id,_that.title,_that.description,_that.durationInSeconds,_that.totalQuestions,_that.totalMarks,_that.maxAttempts,_that.negativeMarking,_that.difficulty,_that.status,_that.category,_that.tags,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  int durationInSeconds,  int totalQuestions,  double totalMarks,  int maxAttempts,  double negativeMarking,  String difficulty,  String status,  String category,  List<String> tags,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Exam() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.durationInSeconds,_that.totalQuestions,_that.totalMarks,_that.maxAttempts,_that.negativeMarking,_that.difficulty,_that.status,_that.category,_that.tags,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Exam implements Exam {
  const _Exam({required this.id, required this.title, required this.description, required this.durationInSeconds, required this.totalQuestions, required this.totalMarks, required this.maxAttempts, required this.negativeMarking, required this.difficulty, required this.status, required this.category, final  List<String> tags = const [], required this.createdAt, required this.updatedAt}): _tags = tags;
  factory _Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  int durationInSeconds;
@override final  int totalQuestions;
@override final  double totalMarks;
@override final  int maxAttempts;
@override final  double negativeMarking;
@override final  String difficulty;
@override final  String status;
@override final  String category;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Exam
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExamCopyWith<_Exam> get copyWith => __$ExamCopyWithImpl<_Exam>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exam&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationInSeconds, durationInSeconds) || other.durationInSeconds == durationInSeconds)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions)&&(identical(other.totalMarks, totalMarks) || other.totalMarks == totalMarks)&&(identical(other.maxAttempts, maxAttempts) || other.maxAttempts == maxAttempts)&&(identical(other.negativeMarking, negativeMarking) || other.negativeMarking == negativeMarking)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,durationInSeconds,totalQuestions,totalMarks,maxAttempts,negativeMarking,difficulty,status,category,const DeepCollectionEquality().hash(_tags),createdAt,updatedAt);

@override
String toString() {
  return 'Exam(id: $id, title: $title, description: $description, durationInSeconds: $durationInSeconds, totalQuestions: $totalQuestions, totalMarks: $totalMarks, maxAttempts: $maxAttempts, negativeMarking: $negativeMarking, difficulty: $difficulty, status: $status, category: $category, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ExamCopyWith<$Res> implements $ExamCopyWith<$Res> {
  factory _$ExamCopyWith(_Exam value, $Res Function(_Exam) _then) = __$ExamCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, int durationInSeconds, int totalQuestions, double totalMarks, int maxAttempts, double negativeMarking, String difficulty, String status, String category, List<String> tags, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ExamCopyWithImpl<$Res>
    implements _$ExamCopyWith<$Res> {
  __$ExamCopyWithImpl(this._self, this._then);

  final _Exam _self;
  final $Res Function(_Exam) _then;

/// Create a copy of Exam
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? durationInSeconds = null,Object? totalQuestions = null,Object? totalMarks = null,Object? maxAttempts = null,Object? negativeMarking = null,Object? difficulty = null,Object? status = null,Object? category = null,Object? tags = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Exam(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,durationInSeconds: null == durationInSeconds ? _self.durationInSeconds : durationInSeconds // ignore: cast_nullable_to_non_nullable
as int,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,totalMarks: null == totalMarks ? _self.totalMarks : totalMarks // ignore: cast_nullable_to_non_nullable
as double,maxAttempts: null == maxAttempts ? _self.maxAttempts : maxAttempts // ignore: cast_nullable_to_non_nullable
as int,negativeMarking: null == negativeMarking ? _self.negativeMarking : negativeMarking // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
