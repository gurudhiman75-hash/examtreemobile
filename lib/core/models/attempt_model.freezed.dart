// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attempt_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttemptResponse {

 String get questionId; List<int> get selectedOptionIndexes; QuestionAttemptStatus get status; int get timeSpentInSeconds;
/// Create a copy of AttemptResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttemptResponseCopyWith<AttemptResponse> get copyWith => _$AttemptResponseCopyWithImpl<AttemptResponse>(this as AttemptResponse, _$identity);

  /// Serializes this AttemptResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttemptResponse&&(identical(other.questionId, questionId) || other.questionId == questionId)&&const DeepCollectionEquality().equals(other.selectedOptionIndexes, selectedOptionIndexes)&&(identical(other.status, status) || other.status == status)&&(identical(other.timeSpentInSeconds, timeSpentInSeconds) || other.timeSpentInSeconds == timeSpentInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionId,const DeepCollectionEquality().hash(selectedOptionIndexes),status,timeSpentInSeconds);

@override
String toString() {
  return 'AttemptResponse(questionId: $questionId, selectedOptionIndexes: $selectedOptionIndexes, status: $status, timeSpentInSeconds: $timeSpentInSeconds)';
}


}

/// @nodoc
abstract mixin class $AttemptResponseCopyWith<$Res>  {
  factory $AttemptResponseCopyWith(AttemptResponse value, $Res Function(AttemptResponse) _then) = _$AttemptResponseCopyWithImpl;
@useResult
$Res call({
 String questionId, List<int> selectedOptionIndexes, QuestionAttemptStatus status, int timeSpentInSeconds
});




}
/// @nodoc
class _$AttemptResponseCopyWithImpl<$Res>
    implements $AttemptResponseCopyWith<$Res> {
  _$AttemptResponseCopyWithImpl(this._self, this._then);

  final AttemptResponse _self;
  final $Res Function(AttemptResponse) _then;

/// Create a copy of AttemptResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? questionId = null,Object? selectedOptionIndexes = null,Object? status = null,Object? timeSpentInSeconds = null,}) {
  return _then(_self.copyWith(
questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,selectedOptionIndexes: null == selectedOptionIndexes ? _self.selectedOptionIndexes : selectedOptionIndexes // ignore: cast_nullable_to_non_nullable
as List<int>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as QuestionAttemptStatus,timeSpentInSeconds: null == timeSpentInSeconds ? _self.timeSpentInSeconds : timeSpentInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AttemptResponse].
extension AttemptResponsePatterns on AttemptResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttemptResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttemptResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttemptResponse value)  $default,){
final _that = this;
switch (_that) {
case _AttemptResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttemptResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AttemptResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String questionId,  List<int> selectedOptionIndexes,  QuestionAttemptStatus status,  int timeSpentInSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttemptResponse() when $default != null:
return $default(_that.questionId,_that.selectedOptionIndexes,_that.status,_that.timeSpentInSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String questionId,  List<int> selectedOptionIndexes,  QuestionAttemptStatus status,  int timeSpentInSeconds)  $default,) {final _that = this;
switch (_that) {
case _AttemptResponse():
return $default(_that.questionId,_that.selectedOptionIndexes,_that.status,_that.timeSpentInSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String questionId,  List<int> selectedOptionIndexes,  QuestionAttemptStatus status,  int timeSpentInSeconds)?  $default,) {final _that = this;
switch (_that) {
case _AttemptResponse() when $default != null:
return $default(_that.questionId,_that.selectedOptionIndexes,_that.status,_that.timeSpentInSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttemptResponse implements AttemptResponse {
  const _AttemptResponse({required this.questionId, required final  List<int> selectedOptionIndexes, required this.status, required this.timeSpentInSeconds}): _selectedOptionIndexes = selectedOptionIndexes;
  factory _AttemptResponse.fromJson(Map<String, dynamic> json) => _$AttemptResponseFromJson(json);

@override final  String questionId;
 final  List<int> _selectedOptionIndexes;
@override List<int> get selectedOptionIndexes {
  if (_selectedOptionIndexes is EqualUnmodifiableListView) return _selectedOptionIndexes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedOptionIndexes);
}

@override final  QuestionAttemptStatus status;
@override final  int timeSpentInSeconds;

/// Create a copy of AttemptResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttemptResponseCopyWith<_AttemptResponse> get copyWith => __$AttemptResponseCopyWithImpl<_AttemptResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttemptResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttemptResponse&&(identical(other.questionId, questionId) || other.questionId == questionId)&&const DeepCollectionEquality().equals(other._selectedOptionIndexes, _selectedOptionIndexes)&&(identical(other.status, status) || other.status == status)&&(identical(other.timeSpentInSeconds, timeSpentInSeconds) || other.timeSpentInSeconds == timeSpentInSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionId,const DeepCollectionEquality().hash(_selectedOptionIndexes),status,timeSpentInSeconds);

@override
String toString() {
  return 'AttemptResponse(questionId: $questionId, selectedOptionIndexes: $selectedOptionIndexes, status: $status, timeSpentInSeconds: $timeSpentInSeconds)';
}


}

/// @nodoc
abstract mixin class _$AttemptResponseCopyWith<$Res> implements $AttemptResponseCopyWith<$Res> {
  factory _$AttemptResponseCopyWith(_AttemptResponse value, $Res Function(_AttemptResponse) _then) = __$AttemptResponseCopyWithImpl;
@override @useResult
$Res call({
 String questionId, List<int> selectedOptionIndexes, QuestionAttemptStatus status, int timeSpentInSeconds
});




}
/// @nodoc
class __$AttemptResponseCopyWithImpl<$Res>
    implements _$AttemptResponseCopyWith<$Res> {
  __$AttemptResponseCopyWithImpl(this._self, this._then);

  final _AttemptResponse _self;
  final $Res Function(_AttemptResponse) _then;

/// Create a copy of AttemptResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? questionId = null,Object? selectedOptionIndexes = null,Object? status = null,Object? timeSpentInSeconds = null,}) {
  return _then(_AttemptResponse(
questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,selectedOptionIndexes: null == selectedOptionIndexes ? _self._selectedOptionIndexes : selectedOptionIndexes // ignore: cast_nullable_to_non_nullable
as List<int>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as QuestionAttemptStatus,timeSpentInSeconds: null == timeSpentInSeconds ? _self.timeSpentInSeconds : timeSpentInSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Attempt {

 String get id; String get userId; String get examId; int get attemptNumber; AttemptStatus get status; DateTime get startTime; DateTime? get endTime; int get timeRemainingInSeconds; Map<String, AttemptResponse> get responses; SyncStatus get syncStatus; DateTime? get lastSyncedAt;
/// Create a copy of Attempt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttemptCopyWith<Attempt> get copyWith => _$AttemptCopyWithImpl<Attempt>(this as Attempt, _$identity);

  /// Serializes this Attempt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attempt&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.attemptNumber, attemptNumber) || other.attemptNumber == attemptNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.timeRemainingInSeconds, timeRemainingInSeconds) || other.timeRemainingInSeconds == timeRemainingInSeconds)&&const DeepCollectionEquality().equals(other.responses, responses)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,examId,attemptNumber,status,startTime,endTime,timeRemainingInSeconds,const DeepCollectionEquality().hash(responses),syncStatus,lastSyncedAt);

@override
String toString() {
  return 'Attempt(id: $id, userId: $userId, examId: $examId, attemptNumber: $attemptNumber, status: $status, startTime: $startTime, endTime: $endTime, timeRemainingInSeconds: $timeRemainingInSeconds, responses: $responses, syncStatus: $syncStatus, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $AttemptCopyWith<$Res>  {
  factory $AttemptCopyWith(Attempt value, $Res Function(Attempt) _then) = _$AttemptCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String examId, int attemptNumber, AttemptStatus status, DateTime startTime, DateTime? endTime, int timeRemainingInSeconds, Map<String, AttemptResponse> responses, SyncStatus syncStatus, DateTime? lastSyncedAt
});




}
/// @nodoc
class _$AttemptCopyWithImpl<$Res>
    implements $AttemptCopyWith<$Res> {
  _$AttemptCopyWithImpl(this._self, this._then);

  final Attempt _self;
  final $Res Function(Attempt) _then;

/// Create a copy of Attempt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? examId = null,Object? attemptNumber = null,Object? status = null,Object? startTime = null,Object? endTime = freezed,Object? timeRemainingInSeconds = null,Object? responses = null,Object? syncStatus = null,Object? lastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,attemptNumber: null == attemptNumber ? _self.attemptNumber : attemptNumber // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttemptStatus,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,timeRemainingInSeconds: null == timeRemainingInSeconds ? _self.timeRemainingInSeconds : timeRemainingInSeconds // ignore: cast_nullable_to_non_nullable
as int,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as Map<String, AttemptResponse>,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Attempt].
extension AttemptPatterns on Attempt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Attempt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Attempt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Attempt value)  $default,){
final _that = this;
switch (_that) {
case _Attempt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Attempt value)?  $default,){
final _that = this;
switch (_that) {
case _Attempt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String examId,  int attemptNumber,  AttemptStatus status,  DateTime startTime,  DateTime? endTime,  int timeRemainingInSeconds,  Map<String, AttemptResponse> responses,  SyncStatus syncStatus,  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Attempt() when $default != null:
return $default(_that.id,_that.userId,_that.examId,_that.attemptNumber,_that.status,_that.startTime,_that.endTime,_that.timeRemainingInSeconds,_that.responses,_that.syncStatus,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String examId,  int attemptNumber,  AttemptStatus status,  DateTime startTime,  DateTime? endTime,  int timeRemainingInSeconds,  Map<String, AttemptResponse> responses,  SyncStatus syncStatus,  DateTime? lastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _Attempt():
return $default(_that.id,_that.userId,_that.examId,_that.attemptNumber,_that.status,_that.startTime,_that.endTime,_that.timeRemainingInSeconds,_that.responses,_that.syncStatus,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String examId,  int attemptNumber,  AttemptStatus status,  DateTime startTime,  DateTime? endTime,  int timeRemainingInSeconds,  Map<String, AttemptResponse> responses,  SyncStatus syncStatus,  DateTime? lastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _Attempt() when $default != null:
return $default(_that.id,_that.userId,_that.examId,_that.attemptNumber,_that.status,_that.startTime,_that.endTime,_that.timeRemainingInSeconds,_that.responses,_that.syncStatus,_that.lastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Attempt implements Attempt {
  const _Attempt({required this.id, required this.userId, required this.examId, required this.attemptNumber, required this.status, required this.startTime, this.endTime, required this.timeRemainingInSeconds, final  Map<String, AttemptResponse> responses = const {}, required this.syncStatus, this.lastSyncedAt}): _responses = responses;
  factory _Attempt.fromJson(Map<String, dynamic> json) => _$AttemptFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String examId;
@override final  int attemptNumber;
@override final  AttemptStatus status;
@override final  DateTime startTime;
@override final  DateTime? endTime;
@override final  int timeRemainingInSeconds;
 final  Map<String, AttemptResponse> _responses;
@override@JsonKey() Map<String, AttemptResponse> get responses {
  if (_responses is EqualUnmodifiableMapView) return _responses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_responses);
}

@override final  SyncStatus syncStatus;
@override final  DateTime? lastSyncedAt;

/// Create a copy of Attempt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttemptCopyWith<_Attempt> get copyWith => __$AttemptCopyWithImpl<_Attempt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttemptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Attempt&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.attemptNumber, attemptNumber) || other.attemptNumber == attemptNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.timeRemainingInSeconds, timeRemainingInSeconds) || other.timeRemainingInSeconds == timeRemainingInSeconds)&&const DeepCollectionEquality().equals(other._responses, _responses)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,examId,attemptNumber,status,startTime,endTime,timeRemainingInSeconds,const DeepCollectionEquality().hash(_responses),syncStatus,lastSyncedAt);

@override
String toString() {
  return 'Attempt(id: $id, userId: $userId, examId: $examId, attemptNumber: $attemptNumber, status: $status, startTime: $startTime, endTime: $endTime, timeRemainingInSeconds: $timeRemainingInSeconds, responses: $responses, syncStatus: $syncStatus, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$AttemptCopyWith<$Res> implements $AttemptCopyWith<$Res> {
  factory _$AttemptCopyWith(_Attempt value, $Res Function(_Attempt) _then) = __$AttemptCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String examId, int attemptNumber, AttemptStatus status, DateTime startTime, DateTime? endTime, int timeRemainingInSeconds, Map<String, AttemptResponse> responses, SyncStatus syncStatus, DateTime? lastSyncedAt
});




}
/// @nodoc
class __$AttemptCopyWithImpl<$Res>
    implements _$AttemptCopyWith<$Res> {
  __$AttemptCopyWithImpl(this._self, this._then);

  final _Attempt _self;
  final $Res Function(_Attempt) _then;

/// Create a copy of Attempt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? examId = null,Object? attemptNumber = null,Object? status = null,Object? startTime = null,Object? endTime = freezed,Object? timeRemainingInSeconds = null,Object? responses = null,Object? syncStatus = null,Object? lastSyncedAt = freezed,}) {
  return _then(_Attempt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,attemptNumber: null == attemptNumber ? _self.attemptNumber : attemptNumber // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttemptStatus,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,timeRemainingInSeconds: null == timeRemainingInSeconds ? _self.timeRemainingInSeconds : timeRemainingInSeconds // ignore: cast_nullable_to_non_nullable
as int,responses: null == responses ? _self._responses : responses // ignore: cast_nullable_to_non_nullable
as Map<String, AttemptResponse>,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
