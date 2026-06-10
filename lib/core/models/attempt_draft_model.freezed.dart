// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attempt_draft_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttemptDraftState {

 int get currentQuestionIndex; int get currentSectionIndex; Map<String, int?> get answers; Map<String, bool> get flags; int get timeLeft; Map<String, int> get sectionTimeLeftByName; List<int> get lockedSections; Map<String, int>? get sectionCompletionTimes; List<int>? get visitedQuestionIds; int get updatedAt;
/// Create a copy of AttemptDraftState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttemptDraftStateCopyWith<AttemptDraftState> get copyWith => _$AttemptDraftStateCopyWithImpl<AttemptDraftState>(this as AttemptDraftState, _$identity);

  /// Serializes this AttemptDraftState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttemptDraftState&&(identical(other.currentQuestionIndex, currentQuestionIndex) || other.currentQuestionIndex == currentQuestionIndex)&&(identical(other.currentSectionIndex, currentSectionIndex) || other.currentSectionIndex == currentSectionIndex)&&const DeepCollectionEquality().equals(other.answers, answers)&&const DeepCollectionEquality().equals(other.flags, flags)&&(identical(other.timeLeft, timeLeft) || other.timeLeft == timeLeft)&&const DeepCollectionEquality().equals(other.sectionTimeLeftByName, sectionTimeLeftByName)&&const DeepCollectionEquality().equals(other.lockedSections, lockedSections)&&const DeepCollectionEquality().equals(other.sectionCompletionTimes, sectionCompletionTimes)&&const DeepCollectionEquality().equals(other.visitedQuestionIds, visitedQuestionIds)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentQuestionIndex,currentSectionIndex,const DeepCollectionEquality().hash(answers),const DeepCollectionEquality().hash(flags),timeLeft,const DeepCollectionEquality().hash(sectionTimeLeftByName),const DeepCollectionEquality().hash(lockedSections),const DeepCollectionEquality().hash(sectionCompletionTimes),const DeepCollectionEquality().hash(visitedQuestionIds),updatedAt);

@override
String toString() {
  return 'AttemptDraftState(currentQuestionIndex: $currentQuestionIndex, currentSectionIndex: $currentSectionIndex, answers: $answers, flags: $flags, timeLeft: $timeLeft, sectionTimeLeftByName: $sectionTimeLeftByName, lockedSections: $lockedSections, sectionCompletionTimes: $sectionCompletionTimes, visitedQuestionIds: $visitedQuestionIds, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AttemptDraftStateCopyWith<$Res>  {
  factory $AttemptDraftStateCopyWith(AttemptDraftState value, $Res Function(AttemptDraftState) _then) = _$AttemptDraftStateCopyWithImpl;
@useResult
$Res call({
 int currentQuestionIndex, int currentSectionIndex, Map<String, int?> answers, Map<String, bool> flags, int timeLeft, Map<String, int> sectionTimeLeftByName, List<int> lockedSections, Map<String, int>? sectionCompletionTimes, List<int>? visitedQuestionIds, int updatedAt
});




}
/// @nodoc
class _$AttemptDraftStateCopyWithImpl<$Res>
    implements $AttemptDraftStateCopyWith<$Res> {
  _$AttemptDraftStateCopyWithImpl(this._self, this._then);

  final AttemptDraftState _self;
  final $Res Function(AttemptDraftState) _then;

/// Create a copy of AttemptDraftState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentQuestionIndex = null,Object? currentSectionIndex = null,Object? answers = null,Object? flags = null,Object? timeLeft = null,Object? sectionTimeLeftByName = null,Object? lockedSections = null,Object? sectionCompletionTimes = freezed,Object? visitedQuestionIds = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
currentQuestionIndex: null == currentQuestionIndex ? _self.currentQuestionIndex : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
as int,currentSectionIndex: null == currentSectionIndex ? _self.currentSectionIndex : currentSectionIndex // ignore: cast_nullable_to_non_nullable
as int,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as Map<String, int?>,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,timeLeft: null == timeLeft ? _self.timeLeft : timeLeft // ignore: cast_nullable_to_non_nullable
as int,sectionTimeLeftByName: null == sectionTimeLeftByName ? _self.sectionTimeLeftByName : sectionTimeLeftByName // ignore: cast_nullable_to_non_nullable
as Map<String, int>,lockedSections: null == lockedSections ? _self.lockedSections : lockedSections // ignore: cast_nullable_to_non_nullable
as List<int>,sectionCompletionTimes: freezed == sectionCompletionTimes ? _self.sectionCompletionTimes : sectionCompletionTimes // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,visitedQuestionIds: freezed == visitedQuestionIds ? _self.visitedQuestionIds : visitedQuestionIds // ignore: cast_nullable_to_non_nullable
as List<int>?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AttemptDraftState].
extension AttemptDraftStatePatterns on AttemptDraftState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttemptDraftState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttemptDraftState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttemptDraftState value)  $default,){
final _that = this;
switch (_that) {
case _AttemptDraftState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttemptDraftState value)?  $default,){
final _that = this;
switch (_that) {
case _AttemptDraftState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentQuestionIndex,  int currentSectionIndex,  Map<String, int?> answers,  Map<String, bool> flags,  int timeLeft,  Map<String, int> sectionTimeLeftByName,  List<int> lockedSections,  Map<String, int>? sectionCompletionTimes,  List<int>? visitedQuestionIds,  int updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttemptDraftState() when $default != null:
return $default(_that.currentQuestionIndex,_that.currentSectionIndex,_that.answers,_that.flags,_that.timeLeft,_that.sectionTimeLeftByName,_that.lockedSections,_that.sectionCompletionTimes,_that.visitedQuestionIds,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentQuestionIndex,  int currentSectionIndex,  Map<String, int?> answers,  Map<String, bool> flags,  int timeLeft,  Map<String, int> sectionTimeLeftByName,  List<int> lockedSections,  Map<String, int>? sectionCompletionTimes,  List<int>? visitedQuestionIds,  int updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AttemptDraftState():
return $default(_that.currentQuestionIndex,_that.currentSectionIndex,_that.answers,_that.flags,_that.timeLeft,_that.sectionTimeLeftByName,_that.lockedSections,_that.sectionCompletionTimes,_that.visitedQuestionIds,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentQuestionIndex,  int currentSectionIndex,  Map<String, int?> answers,  Map<String, bool> flags,  int timeLeft,  Map<String, int> sectionTimeLeftByName,  List<int> lockedSections,  Map<String, int>? sectionCompletionTimes,  List<int>? visitedQuestionIds,  int updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AttemptDraftState() when $default != null:
return $default(_that.currentQuestionIndex,_that.currentSectionIndex,_that.answers,_that.flags,_that.timeLeft,_that.sectionTimeLeftByName,_that.lockedSections,_that.sectionCompletionTimes,_that.visitedQuestionIds,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttemptDraftState implements AttemptDraftState {
  const _AttemptDraftState({required this.currentQuestionIndex, this.currentSectionIndex = 0, final  Map<String, int?> answers = const {}, final  Map<String, bool> flags = const {}, required this.timeLeft, final  Map<String, int> sectionTimeLeftByName = const {}, final  List<int> lockedSections = const [], final  Map<String, int>? sectionCompletionTimes, final  List<int>? visitedQuestionIds, required this.updatedAt}): _answers = answers,_flags = flags,_sectionTimeLeftByName = sectionTimeLeftByName,_lockedSections = lockedSections,_sectionCompletionTimes = sectionCompletionTimes,_visitedQuestionIds = visitedQuestionIds;
  factory _AttemptDraftState.fromJson(Map<String, dynamic> json) => _$AttemptDraftStateFromJson(json);

@override final  int currentQuestionIndex;
@override@JsonKey() final  int currentSectionIndex;
 final  Map<String, int?> _answers;
@override@JsonKey() Map<String, int?> get answers {
  if (_answers is EqualUnmodifiableMapView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_answers);
}

 final  Map<String, bool> _flags;
@override@JsonKey() Map<String, bool> get flags {
  if (_flags is EqualUnmodifiableMapView) return _flags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_flags);
}

@override final  int timeLeft;
 final  Map<String, int> _sectionTimeLeftByName;
@override@JsonKey() Map<String, int> get sectionTimeLeftByName {
  if (_sectionTimeLeftByName is EqualUnmodifiableMapView) return _sectionTimeLeftByName;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sectionTimeLeftByName);
}

 final  List<int> _lockedSections;
@override@JsonKey() List<int> get lockedSections {
  if (_lockedSections is EqualUnmodifiableListView) return _lockedSections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lockedSections);
}

 final  Map<String, int>? _sectionCompletionTimes;
@override Map<String, int>? get sectionCompletionTimes {
  final value = _sectionCompletionTimes;
  if (value == null) return null;
  if (_sectionCompletionTimes is EqualUnmodifiableMapView) return _sectionCompletionTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<int>? _visitedQuestionIds;
@override List<int>? get visitedQuestionIds {
  final value = _visitedQuestionIds;
  if (value == null) return null;
  if (_visitedQuestionIds is EqualUnmodifiableListView) return _visitedQuestionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int updatedAt;

/// Create a copy of AttemptDraftState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttemptDraftStateCopyWith<_AttemptDraftState> get copyWith => __$AttemptDraftStateCopyWithImpl<_AttemptDraftState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttemptDraftStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttemptDraftState&&(identical(other.currentQuestionIndex, currentQuestionIndex) || other.currentQuestionIndex == currentQuestionIndex)&&(identical(other.currentSectionIndex, currentSectionIndex) || other.currentSectionIndex == currentSectionIndex)&&const DeepCollectionEquality().equals(other._answers, _answers)&&const DeepCollectionEquality().equals(other._flags, _flags)&&(identical(other.timeLeft, timeLeft) || other.timeLeft == timeLeft)&&const DeepCollectionEquality().equals(other._sectionTimeLeftByName, _sectionTimeLeftByName)&&const DeepCollectionEquality().equals(other._lockedSections, _lockedSections)&&const DeepCollectionEquality().equals(other._sectionCompletionTimes, _sectionCompletionTimes)&&const DeepCollectionEquality().equals(other._visitedQuestionIds, _visitedQuestionIds)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentQuestionIndex,currentSectionIndex,const DeepCollectionEquality().hash(_answers),const DeepCollectionEquality().hash(_flags),timeLeft,const DeepCollectionEquality().hash(_sectionTimeLeftByName),const DeepCollectionEquality().hash(_lockedSections),const DeepCollectionEquality().hash(_sectionCompletionTimes),const DeepCollectionEquality().hash(_visitedQuestionIds),updatedAt);

@override
String toString() {
  return 'AttemptDraftState(currentQuestionIndex: $currentQuestionIndex, currentSectionIndex: $currentSectionIndex, answers: $answers, flags: $flags, timeLeft: $timeLeft, sectionTimeLeftByName: $sectionTimeLeftByName, lockedSections: $lockedSections, sectionCompletionTimes: $sectionCompletionTimes, visitedQuestionIds: $visitedQuestionIds, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AttemptDraftStateCopyWith<$Res> implements $AttemptDraftStateCopyWith<$Res> {
  factory _$AttemptDraftStateCopyWith(_AttemptDraftState value, $Res Function(_AttemptDraftState) _then) = __$AttemptDraftStateCopyWithImpl;
@override @useResult
$Res call({
 int currentQuestionIndex, int currentSectionIndex, Map<String, int?> answers, Map<String, bool> flags, int timeLeft, Map<String, int> sectionTimeLeftByName, List<int> lockedSections, Map<String, int>? sectionCompletionTimes, List<int>? visitedQuestionIds, int updatedAt
});




}
/// @nodoc
class __$AttemptDraftStateCopyWithImpl<$Res>
    implements _$AttemptDraftStateCopyWith<$Res> {
  __$AttemptDraftStateCopyWithImpl(this._self, this._then);

  final _AttemptDraftState _self;
  final $Res Function(_AttemptDraftState) _then;

/// Create a copy of AttemptDraftState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentQuestionIndex = null,Object? currentSectionIndex = null,Object? answers = null,Object? flags = null,Object? timeLeft = null,Object? sectionTimeLeftByName = null,Object? lockedSections = null,Object? sectionCompletionTimes = freezed,Object? visitedQuestionIds = freezed,Object? updatedAt = null,}) {
  return _then(_AttemptDraftState(
currentQuestionIndex: null == currentQuestionIndex ? _self.currentQuestionIndex : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
as int,currentSectionIndex: null == currentSectionIndex ? _self.currentSectionIndex : currentSectionIndex // ignore: cast_nullable_to_non_nullable
as int,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as Map<String, int?>,flags: null == flags ? _self._flags : flags // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,timeLeft: null == timeLeft ? _self.timeLeft : timeLeft // ignore: cast_nullable_to_non_nullable
as int,sectionTimeLeftByName: null == sectionTimeLeftByName ? _self._sectionTimeLeftByName : sectionTimeLeftByName // ignore: cast_nullable_to_non_nullable
as Map<String, int>,lockedSections: null == lockedSections ? _self._lockedSections : lockedSections // ignore: cast_nullable_to_non_nullable
as List<int>,sectionCompletionTimes: freezed == sectionCompletionTimes ? _self._sectionCompletionTimes : sectionCompletionTimes // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,visitedQuestionIds: freezed == visitedQuestionIds ? _self._visitedQuestionIds : visitedQuestionIds // ignore: cast_nullable_to_non_nullable
as List<int>?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AttemptDraft {

@JsonKey(name: 'id') String get draftId; String get testId; String get testName; String get category; String get attemptType; String? get originalAttemptId; AttemptDraftState get state; int get version; AttemptDraftStatus get status; String? get lastDevice; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get expiresAt;
/// Create a copy of AttemptDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttemptDraftCopyWith<AttemptDraft> get copyWith => _$AttemptDraftCopyWithImpl<AttemptDraft>(this as AttemptDraft, _$identity);

  /// Serializes this AttemptDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttemptDraft&&(identical(other.draftId, draftId) || other.draftId == draftId)&&(identical(other.testId, testId) || other.testId == testId)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.category, category) || other.category == category)&&(identical(other.attemptType, attemptType) || other.attemptType == attemptType)&&(identical(other.originalAttemptId, originalAttemptId) || other.originalAttemptId == originalAttemptId)&&(identical(other.state, state) || other.state == state)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastDevice, lastDevice) || other.lastDevice == lastDevice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,draftId,testId,testName,category,attemptType,originalAttemptId,state,version,status,lastDevice,createdAt,updatedAt,expiresAt);

@override
String toString() {
  return 'AttemptDraft(draftId: $draftId, testId: $testId, testName: $testName, category: $category, attemptType: $attemptType, originalAttemptId: $originalAttemptId, state: $state, version: $version, status: $status, lastDevice: $lastDevice, createdAt: $createdAt, updatedAt: $updatedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $AttemptDraftCopyWith<$Res>  {
  factory $AttemptDraftCopyWith(AttemptDraft value, $Res Function(AttemptDraft) _then) = _$AttemptDraftCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String draftId, String testId, String testName, String category, String attemptType, String? originalAttemptId, AttemptDraftState state, int version, AttemptDraftStatus status, String? lastDevice, DateTime? createdAt, DateTime? updatedAt, DateTime? expiresAt
});


$AttemptDraftStateCopyWith<$Res> get state;

}
/// @nodoc
class _$AttemptDraftCopyWithImpl<$Res>
    implements $AttemptDraftCopyWith<$Res> {
  _$AttemptDraftCopyWithImpl(this._self, this._then);

  final AttemptDraft _self;
  final $Res Function(AttemptDraft) _then;

/// Create a copy of AttemptDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? draftId = null,Object? testId = null,Object? testName = null,Object? category = null,Object? attemptType = null,Object? originalAttemptId = freezed,Object? state = null,Object? version = null,Object? status = null,Object? lastDevice = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
draftId: null == draftId ? _self.draftId : draftId // ignore: cast_nullable_to_non_nullable
as String,testId: null == testId ? _self.testId : testId // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,attemptType: null == attemptType ? _self.attemptType : attemptType // ignore: cast_nullable_to_non_nullable
as String,originalAttemptId: freezed == originalAttemptId ? _self.originalAttemptId : originalAttemptId // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as AttemptDraftState,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttemptDraftStatus,lastDevice: freezed == lastDevice ? _self.lastDevice : lastDevice // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of AttemptDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttemptDraftStateCopyWith<$Res> get state {
  
  return $AttemptDraftStateCopyWith<$Res>(_self.state, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}


/// Adds pattern-matching-related methods to [AttemptDraft].
extension AttemptDraftPatterns on AttemptDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttemptDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttemptDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttemptDraft value)  $default,){
final _that = this;
switch (_that) {
case _AttemptDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttemptDraft value)?  $default,){
final _that = this;
switch (_that) {
case _AttemptDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String draftId,  String testId,  String testName,  String category,  String attemptType,  String? originalAttemptId,  AttemptDraftState state,  int version,  AttemptDraftStatus status,  String? lastDevice,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttemptDraft() when $default != null:
return $default(_that.draftId,_that.testId,_that.testName,_that.category,_that.attemptType,_that.originalAttemptId,_that.state,_that.version,_that.status,_that.lastDevice,_that.createdAt,_that.updatedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String draftId,  String testId,  String testName,  String category,  String attemptType,  String? originalAttemptId,  AttemptDraftState state,  int version,  AttemptDraftStatus status,  String? lastDevice,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _AttemptDraft():
return $default(_that.draftId,_that.testId,_that.testName,_that.category,_that.attemptType,_that.originalAttemptId,_that.state,_that.version,_that.status,_that.lastDevice,_that.createdAt,_that.updatedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String draftId,  String testId,  String testName,  String category,  String attemptType,  String? originalAttemptId,  AttemptDraftState state,  int version,  AttemptDraftStatus status,  String? lastDevice,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _AttemptDraft() when $default != null:
return $default(_that.draftId,_that.testId,_that.testName,_that.category,_that.attemptType,_that.originalAttemptId,_that.state,_that.version,_that.status,_that.lastDevice,_that.createdAt,_that.updatedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttemptDraft implements AttemptDraft {
  const _AttemptDraft({@JsonKey(name: 'id') required this.draftId, required this.testId, required this.testName, required this.category, required this.attemptType, this.originalAttemptId, required this.state, required this.version, this.status = AttemptDraftStatus.inProgress, this.lastDevice, this.createdAt, this.updatedAt, this.expiresAt});
  factory _AttemptDraft.fromJson(Map<String, dynamic> json) => _$AttemptDraftFromJson(json);

@override@JsonKey(name: 'id') final  String draftId;
@override final  String testId;
@override final  String testName;
@override final  String category;
@override final  String attemptType;
@override final  String? originalAttemptId;
@override final  AttemptDraftState state;
@override final  int version;
@override@JsonKey() final  AttemptDraftStatus status;
@override final  String? lastDevice;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? expiresAt;

/// Create a copy of AttemptDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttemptDraftCopyWith<_AttemptDraft> get copyWith => __$AttemptDraftCopyWithImpl<_AttemptDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttemptDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttemptDraft&&(identical(other.draftId, draftId) || other.draftId == draftId)&&(identical(other.testId, testId) || other.testId == testId)&&(identical(other.testName, testName) || other.testName == testName)&&(identical(other.category, category) || other.category == category)&&(identical(other.attemptType, attemptType) || other.attemptType == attemptType)&&(identical(other.originalAttemptId, originalAttemptId) || other.originalAttemptId == originalAttemptId)&&(identical(other.state, state) || other.state == state)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastDevice, lastDevice) || other.lastDevice == lastDevice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,draftId,testId,testName,category,attemptType,originalAttemptId,state,version,status,lastDevice,createdAt,updatedAt,expiresAt);

@override
String toString() {
  return 'AttemptDraft(draftId: $draftId, testId: $testId, testName: $testName, category: $category, attemptType: $attemptType, originalAttemptId: $originalAttemptId, state: $state, version: $version, status: $status, lastDevice: $lastDevice, createdAt: $createdAt, updatedAt: $updatedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$AttemptDraftCopyWith<$Res> implements $AttemptDraftCopyWith<$Res> {
  factory _$AttemptDraftCopyWith(_AttemptDraft value, $Res Function(_AttemptDraft) _then) = __$AttemptDraftCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String draftId, String testId, String testName, String category, String attemptType, String? originalAttemptId, AttemptDraftState state, int version, AttemptDraftStatus status, String? lastDevice, DateTime? createdAt, DateTime? updatedAt, DateTime? expiresAt
});


@override $AttemptDraftStateCopyWith<$Res> get state;

}
/// @nodoc
class __$AttemptDraftCopyWithImpl<$Res>
    implements _$AttemptDraftCopyWith<$Res> {
  __$AttemptDraftCopyWithImpl(this._self, this._then);

  final _AttemptDraft _self;
  final $Res Function(_AttemptDraft) _then;

/// Create a copy of AttemptDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? draftId = null,Object? testId = null,Object? testName = null,Object? category = null,Object? attemptType = null,Object? originalAttemptId = freezed,Object? state = null,Object? version = null,Object? status = null,Object? lastDevice = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_AttemptDraft(
draftId: null == draftId ? _self.draftId : draftId // ignore: cast_nullable_to_non_nullable
as String,testId: null == testId ? _self.testId : testId // ignore: cast_nullable_to_non_nullable
as String,testName: null == testName ? _self.testName : testName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,attemptType: null == attemptType ? _self.attemptType : attemptType // ignore: cast_nullable_to_non_nullable
as String,originalAttemptId: freezed == originalAttemptId ? _self.originalAttemptId : originalAttemptId // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as AttemptDraftState,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttemptDraftStatus,lastDevice: freezed == lastDevice ? _self.lastDevice : lastDevice // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of AttemptDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttemptDraftStateCopyWith<$Res> get state {
  
  return $AttemptDraftStateCopyWith<$Res>(_self.state, (value) {
    return _then(_self.copyWith(state: value));
  });
}
}


/// @nodoc
mixin _$AttemptDraftListResponse {

 List<AttemptDraft> get drafts;
/// Create a copy of AttemptDraftListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttemptDraftListResponseCopyWith<AttemptDraftListResponse> get copyWith => _$AttemptDraftListResponseCopyWithImpl<AttemptDraftListResponse>(this as AttemptDraftListResponse, _$identity);

  /// Serializes this AttemptDraftListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttemptDraftListResponse&&const DeepCollectionEquality().equals(other.drafts, drafts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(drafts));

@override
String toString() {
  return 'AttemptDraftListResponse(drafts: $drafts)';
}


}

/// @nodoc
abstract mixin class $AttemptDraftListResponseCopyWith<$Res>  {
  factory $AttemptDraftListResponseCopyWith(AttemptDraftListResponse value, $Res Function(AttemptDraftListResponse) _then) = _$AttemptDraftListResponseCopyWithImpl;
@useResult
$Res call({
 List<AttemptDraft> drafts
});




}
/// @nodoc
class _$AttemptDraftListResponseCopyWithImpl<$Res>
    implements $AttemptDraftListResponseCopyWith<$Res> {
  _$AttemptDraftListResponseCopyWithImpl(this._self, this._then);

  final AttemptDraftListResponse _self;
  final $Res Function(AttemptDraftListResponse) _then;

/// Create a copy of AttemptDraftListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? drafts = null,}) {
  return _then(_self.copyWith(
drafts: null == drafts ? _self.drafts : drafts // ignore: cast_nullable_to_non_nullable
as List<AttemptDraft>,
  ));
}

}


/// Adds pattern-matching-related methods to [AttemptDraftListResponse].
extension AttemptDraftListResponsePatterns on AttemptDraftListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttemptDraftListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttemptDraftListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttemptDraftListResponse value)  $default,){
final _that = this;
switch (_that) {
case _AttemptDraftListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttemptDraftListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AttemptDraftListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AttemptDraft> drafts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttemptDraftListResponse() when $default != null:
return $default(_that.drafts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AttemptDraft> drafts)  $default,) {final _that = this;
switch (_that) {
case _AttemptDraftListResponse():
return $default(_that.drafts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AttemptDraft> drafts)?  $default,) {final _that = this;
switch (_that) {
case _AttemptDraftListResponse() when $default != null:
return $default(_that.drafts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttemptDraftListResponse implements AttemptDraftListResponse {
  const _AttemptDraftListResponse({final  List<AttemptDraft> drafts = const []}): _drafts = drafts;
  factory _AttemptDraftListResponse.fromJson(Map<String, dynamic> json) => _$AttemptDraftListResponseFromJson(json);

 final  List<AttemptDraft> _drafts;
@override@JsonKey() List<AttemptDraft> get drafts {
  if (_drafts is EqualUnmodifiableListView) return _drafts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_drafts);
}


/// Create a copy of AttemptDraftListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttemptDraftListResponseCopyWith<_AttemptDraftListResponse> get copyWith => __$AttemptDraftListResponseCopyWithImpl<_AttemptDraftListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttemptDraftListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttemptDraftListResponse&&const DeepCollectionEquality().equals(other._drafts, _drafts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_drafts));

@override
String toString() {
  return 'AttemptDraftListResponse(drafts: $drafts)';
}


}

/// @nodoc
abstract mixin class _$AttemptDraftListResponseCopyWith<$Res> implements $AttemptDraftListResponseCopyWith<$Res> {
  factory _$AttemptDraftListResponseCopyWith(_AttemptDraftListResponse value, $Res Function(_AttemptDraftListResponse) _then) = __$AttemptDraftListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<AttemptDraft> drafts
});




}
/// @nodoc
class __$AttemptDraftListResponseCopyWithImpl<$Res>
    implements _$AttemptDraftListResponseCopyWith<$Res> {
  __$AttemptDraftListResponseCopyWithImpl(this._self, this._then);

  final _AttemptDraftListResponse _self;
  final $Res Function(_AttemptDraftListResponse) _then;

/// Create a copy of AttemptDraftListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? drafts = null,}) {
  return _then(_AttemptDraftListResponse(
drafts: null == drafts ? _self._drafts : drafts // ignore: cast_nullable_to_non_nullable
as List<AttemptDraft>,
  ));
}


}


/// @nodoc
mixin _$SaveAttemptDraftResult {

@JsonKey(name: 'id') String get draftId; int get version; DateTime? get updatedAt;
/// Create a copy of SaveAttemptDraftResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveAttemptDraftResultCopyWith<SaveAttemptDraftResult> get copyWith => _$SaveAttemptDraftResultCopyWithImpl<SaveAttemptDraftResult>(this as SaveAttemptDraftResult, _$identity);

  /// Serializes this SaveAttemptDraftResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveAttemptDraftResult&&(identical(other.draftId, draftId) || other.draftId == draftId)&&(identical(other.version, version) || other.version == version)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,draftId,version,updatedAt);

@override
String toString() {
  return 'SaveAttemptDraftResult(draftId: $draftId, version: $version, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SaveAttemptDraftResultCopyWith<$Res>  {
  factory $SaveAttemptDraftResultCopyWith(SaveAttemptDraftResult value, $Res Function(SaveAttemptDraftResult) _then) = _$SaveAttemptDraftResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String draftId, int version, DateTime? updatedAt
});




}
/// @nodoc
class _$SaveAttemptDraftResultCopyWithImpl<$Res>
    implements $SaveAttemptDraftResultCopyWith<$Res> {
  _$SaveAttemptDraftResultCopyWithImpl(this._self, this._then);

  final SaveAttemptDraftResult _self;
  final $Res Function(SaveAttemptDraftResult) _then;

/// Create a copy of SaveAttemptDraftResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? draftId = null,Object? version = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
draftId: null == draftId ? _self.draftId : draftId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SaveAttemptDraftResult].
extension SaveAttemptDraftResultPatterns on SaveAttemptDraftResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaveAttemptDraftResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaveAttemptDraftResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaveAttemptDraftResult value)  $default,){
final _that = this;
switch (_that) {
case _SaveAttemptDraftResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaveAttemptDraftResult value)?  $default,){
final _that = this;
switch (_that) {
case _SaveAttemptDraftResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String draftId,  int version,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveAttemptDraftResult() when $default != null:
return $default(_that.draftId,_that.version,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String draftId,  int version,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SaveAttemptDraftResult():
return $default(_that.draftId,_that.version,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String draftId,  int version,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SaveAttemptDraftResult() when $default != null:
return $default(_that.draftId,_that.version,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaveAttemptDraftResult implements SaveAttemptDraftResult {
  const _SaveAttemptDraftResult({@JsonKey(name: 'id') required this.draftId, required this.version, this.updatedAt});
  factory _SaveAttemptDraftResult.fromJson(Map<String, dynamic> json) => _$SaveAttemptDraftResultFromJson(json);

@override@JsonKey(name: 'id') final  String draftId;
@override final  int version;
@override final  DateTime? updatedAt;

/// Create a copy of SaveAttemptDraftResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveAttemptDraftResultCopyWith<_SaveAttemptDraftResult> get copyWith => __$SaveAttemptDraftResultCopyWithImpl<_SaveAttemptDraftResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaveAttemptDraftResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveAttemptDraftResult&&(identical(other.draftId, draftId) || other.draftId == draftId)&&(identical(other.version, version) || other.version == version)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,draftId,version,updatedAt);

@override
String toString() {
  return 'SaveAttemptDraftResult(draftId: $draftId, version: $version, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SaveAttemptDraftResultCopyWith<$Res> implements $SaveAttemptDraftResultCopyWith<$Res> {
  factory _$SaveAttemptDraftResultCopyWith(_SaveAttemptDraftResult value, $Res Function(_SaveAttemptDraftResult) _then) = __$SaveAttemptDraftResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String draftId, int version, DateTime? updatedAt
});




}
/// @nodoc
class __$SaveAttemptDraftResultCopyWithImpl<$Res>
    implements _$SaveAttemptDraftResultCopyWith<$Res> {
  __$SaveAttemptDraftResultCopyWithImpl(this._self, this._then);

  final _SaveAttemptDraftResult _self;
  final $Res Function(_SaveAttemptDraftResult) _then;

/// Create a copy of SaveAttemptDraftResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? draftId = null,Object? version = null,Object? updatedAt = freezed,}) {
  return _then(_SaveAttemptDraftResult(
draftId: null == draftId ? _self.draftId : draftId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
