// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_auth_redirect_intent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostAuthRedirectIntent {

 IntentTargetType get targetType; String get targetValue; Map<String, String>? get arguments; Duration get createdAt;
/// Create a copy of PostAuthRedirectIntent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostAuthRedirectIntentCopyWith<PostAuthRedirectIntent> get copyWith => _$PostAuthRedirectIntentCopyWithImpl<PostAuthRedirectIntent>(this as PostAuthRedirectIntent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostAuthRedirectIntent&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&const DeepCollectionEquality().equals(other.arguments, arguments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,targetType,targetValue,const DeepCollectionEquality().hash(arguments),createdAt);

@override
String toString() {
  return 'PostAuthRedirectIntent(targetType: $targetType, targetValue: $targetValue, arguments: $arguments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PostAuthRedirectIntentCopyWith<$Res>  {
  factory $PostAuthRedirectIntentCopyWith(PostAuthRedirectIntent value, $Res Function(PostAuthRedirectIntent) _then) = _$PostAuthRedirectIntentCopyWithImpl;
@useResult
$Res call({
 IntentTargetType targetType, String targetValue, Map<String, String>? arguments, Duration createdAt
});




}
/// @nodoc
class _$PostAuthRedirectIntentCopyWithImpl<$Res>
    implements $PostAuthRedirectIntentCopyWith<$Res> {
  _$PostAuthRedirectIntentCopyWithImpl(this._self, this._then);

  final PostAuthRedirectIntent _self;
  final $Res Function(PostAuthRedirectIntent) _then;

/// Create a copy of PostAuthRedirectIntent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetType = null,Object? targetValue = null,Object? arguments = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as IntentTargetType,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as String,arguments: freezed == arguments ? _self.arguments : arguments // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [PostAuthRedirectIntent].
extension PostAuthRedirectIntentPatterns on PostAuthRedirectIntent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostAuthRedirectIntent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostAuthRedirectIntent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostAuthRedirectIntent value)  $default,){
final _that = this;
switch (_that) {
case _PostAuthRedirectIntent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostAuthRedirectIntent value)?  $default,){
final _that = this;
switch (_that) {
case _PostAuthRedirectIntent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IntentTargetType targetType,  String targetValue,  Map<String, String>? arguments,  Duration createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostAuthRedirectIntent() when $default != null:
return $default(_that.targetType,_that.targetValue,_that.arguments,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IntentTargetType targetType,  String targetValue,  Map<String, String>? arguments,  Duration createdAt)  $default,) {final _that = this;
switch (_that) {
case _PostAuthRedirectIntent():
return $default(_that.targetType,_that.targetValue,_that.arguments,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IntentTargetType targetType,  String targetValue,  Map<String, String>? arguments,  Duration createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PostAuthRedirectIntent() when $default != null:
return $default(_that.targetType,_that.targetValue,_that.arguments,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _PostAuthRedirectIntent extends PostAuthRedirectIntent {
  const _PostAuthRedirectIntent({required this.targetType, required this.targetValue, final  Map<String, String>? arguments, this.createdAt = Duration.zero}): _arguments = arguments,super._();
  

@override final  IntentTargetType targetType;
@override final  String targetValue;
 final  Map<String, String>? _arguments;
@override Map<String, String>? get arguments {
  final value = _arguments;
  if (value == null) return null;
  if (_arguments is EqualUnmodifiableMapView) return _arguments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  Duration createdAt;

/// Create a copy of PostAuthRedirectIntent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostAuthRedirectIntentCopyWith<_PostAuthRedirectIntent> get copyWith => __$PostAuthRedirectIntentCopyWithImpl<_PostAuthRedirectIntent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostAuthRedirectIntent&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&const DeepCollectionEquality().equals(other._arguments, _arguments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,targetType,targetValue,const DeepCollectionEquality().hash(_arguments),createdAt);

@override
String toString() {
  return 'PostAuthRedirectIntent(targetType: $targetType, targetValue: $targetValue, arguments: $arguments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PostAuthRedirectIntentCopyWith<$Res> implements $PostAuthRedirectIntentCopyWith<$Res> {
  factory _$PostAuthRedirectIntentCopyWith(_PostAuthRedirectIntent value, $Res Function(_PostAuthRedirectIntent) _then) = __$PostAuthRedirectIntentCopyWithImpl;
@override @useResult
$Res call({
 IntentTargetType targetType, String targetValue, Map<String, String>? arguments, Duration createdAt
});




}
/// @nodoc
class __$PostAuthRedirectIntentCopyWithImpl<$Res>
    implements _$PostAuthRedirectIntentCopyWith<$Res> {
  __$PostAuthRedirectIntentCopyWithImpl(this._self, this._then);

  final _PostAuthRedirectIntent _self;
  final $Res Function(_PostAuthRedirectIntent) _then;

/// Create a copy of PostAuthRedirectIntent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetType = null,Object? targetValue = null,Object? arguments = freezed,Object? createdAt = null,}) {
  return _then(_PostAuthRedirectIntent(
targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as IntentTargetType,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as String,arguments: freezed == arguments ? _self._arguments : arguments // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
