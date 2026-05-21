// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthSessionState {

 AuthResolutionStatus get status; AccountProfile? get profile; String? get errorMessage;
/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionStateCopyWith<AuthSessionState> get copyWith => _$AuthSessionStateCopyWithImpl<AuthSessionState>(this as AuthSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionState&&(identical(other.status, status) || other.status == status)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,profile,errorMessage);

@override
String toString() {
  return 'AuthSessionState(status: $status, profile: $profile, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AuthSessionStateCopyWith<$Res>  {
  factory $AuthSessionStateCopyWith(AuthSessionState value, $Res Function(AuthSessionState) _then) = _$AuthSessionStateCopyWithImpl;
@useResult
$Res call({
 AuthResolutionStatus status, AccountProfile? profile, String? errorMessage
});


$AccountProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$AuthSessionStateCopyWithImpl<$Res>
    implements $AuthSessionStateCopyWith<$Res> {
  _$AuthSessionStateCopyWithImpl(this._self, this._then);

  final AuthSessionState _self;
  final $Res Function(AuthSessionState) _then;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? profile = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthResolutionStatus,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as AccountProfile?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $AccountProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthSessionState].
extension AuthSessionStatePatterns on AuthSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSessionState value)  $default,){
final _that = this;
switch (_that) {
case _AuthSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthResolutionStatus status,  AccountProfile? profile,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSessionState() when $default != null:
return $default(_that.status,_that.profile,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthResolutionStatus status,  AccountProfile? profile,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AuthSessionState():
return $default(_that.status,_that.profile,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthResolutionStatus status,  AccountProfile? profile,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AuthSessionState() when $default != null:
return $default(_that.status,_that.profile,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _AuthSessionState extends AuthSessionState {
  const _AuthSessionState({this.status = AuthResolutionStatus.idle, this.profile, this.errorMessage}): super._();
  

@override@JsonKey() final  AuthResolutionStatus status;
@override final  AccountProfile? profile;
@override final  String? errorMessage;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSessionStateCopyWith<_AuthSessionState> get copyWith => __$AuthSessionStateCopyWithImpl<_AuthSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSessionState&&(identical(other.status, status) || other.status == status)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,profile,errorMessage);

@override
String toString() {
  return 'AuthSessionState(status: $status, profile: $profile, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AuthSessionStateCopyWith<$Res> implements $AuthSessionStateCopyWith<$Res> {
  factory _$AuthSessionStateCopyWith(_AuthSessionState value, $Res Function(_AuthSessionState) _then) = __$AuthSessionStateCopyWithImpl;
@override @useResult
$Res call({
 AuthResolutionStatus status, AccountProfile? profile, String? errorMessage
});


@override $AccountProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$AuthSessionStateCopyWithImpl<$Res>
    implements _$AuthSessionStateCopyWith<$Res> {
  __$AuthSessionStateCopyWithImpl(this._self, this._then);

  final _AuthSessionState _self;
  final $Res Function(_AuthSessionState) _then;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? profile = freezed,Object? errorMessage = freezed,}) {
  return _then(_AuthSessionState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthResolutionStatus,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as AccountProfile?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $AccountProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
