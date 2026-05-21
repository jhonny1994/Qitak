// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seller_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SellerProfile {

 String get userId; String get businessName; String get phone; String get verificationStatus; bool get isSellerEnabled;
/// Create a copy of SellerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SellerProfileCopyWith<SellerProfile> get copyWith => _$SellerProfileCopyWithImpl<SellerProfile>(this as SellerProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SellerProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.isSellerEnabled, isSellerEnabled) || other.isSellerEnabled == isSellerEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,userId,businessName,phone,verificationStatus,isSellerEnabled);

@override
String toString() {
  return 'SellerProfile(userId: $userId, businessName: $businessName, phone: $phone, verificationStatus: $verificationStatus, isSellerEnabled: $isSellerEnabled)';
}


}

/// @nodoc
abstract mixin class $SellerProfileCopyWith<$Res>  {
  factory $SellerProfileCopyWith(SellerProfile value, $Res Function(SellerProfile) _then) = _$SellerProfileCopyWithImpl;
@useResult
$Res call({
 String userId, String businessName, String phone, String verificationStatus, bool isSellerEnabled
});




}
/// @nodoc
class _$SellerProfileCopyWithImpl<$Res>
    implements $SellerProfileCopyWith<$Res> {
  _$SellerProfileCopyWithImpl(this._self, this._then);

  final SellerProfile _self;
  final $Res Function(SellerProfile) _then;

/// Create a copy of SellerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? businessName = null,Object? phone = null,Object? verificationStatus = null,Object? isSellerEnabled = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,isSellerEnabled: null == isSellerEnabled ? _self.isSellerEnabled : isSellerEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SellerProfile].
extension SellerProfilePatterns on SellerProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SellerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SellerProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SellerProfile value)  $default,){
final _that = this;
switch (_that) {
case _SellerProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SellerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _SellerProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String businessName,  String phone,  String verificationStatus,  bool isSellerEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SellerProfile() when $default != null:
return $default(_that.userId,_that.businessName,_that.phone,_that.verificationStatus,_that.isSellerEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String businessName,  String phone,  String verificationStatus,  bool isSellerEnabled)  $default,) {final _that = this;
switch (_that) {
case _SellerProfile():
return $default(_that.userId,_that.businessName,_that.phone,_that.verificationStatus,_that.isSellerEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String businessName,  String phone,  String verificationStatus,  bool isSellerEnabled)?  $default,) {final _that = this;
switch (_that) {
case _SellerProfile() when $default != null:
return $default(_that.userId,_that.businessName,_that.phone,_that.verificationStatus,_that.isSellerEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _SellerProfile implements SellerProfile {
  const _SellerProfile({required this.userId, required this.businessName, required this.phone, this.verificationStatus = 'pending', this.isSellerEnabled = true});
  

@override final  String userId;
@override final  String businessName;
@override final  String phone;
@override@JsonKey() final  String verificationStatus;
@override@JsonKey() final  bool isSellerEnabled;

/// Create a copy of SellerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SellerProfileCopyWith<_SellerProfile> get copyWith => __$SellerProfileCopyWithImpl<_SellerProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SellerProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.isSellerEnabled, isSellerEnabled) || other.isSellerEnabled == isSellerEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,userId,businessName,phone,verificationStatus,isSellerEnabled);

@override
String toString() {
  return 'SellerProfile(userId: $userId, businessName: $businessName, phone: $phone, verificationStatus: $verificationStatus, isSellerEnabled: $isSellerEnabled)';
}


}

/// @nodoc
abstract mixin class _$SellerProfileCopyWith<$Res> implements $SellerProfileCopyWith<$Res> {
  factory _$SellerProfileCopyWith(_SellerProfile value, $Res Function(_SellerProfile) _then) = __$SellerProfileCopyWithImpl;
@override @useResult
$Res call({
 String userId, String businessName, String phone, String verificationStatus, bool isSellerEnabled
});




}
/// @nodoc
class __$SellerProfileCopyWithImpl<$Res>
    implements _$SellerProfileCopyWith<$Res> {
  __$SellerProfileCopyWithImpl(this._self, this._then);

  final _SellerProfile _self;
  final $Res Function(_SellerProfile) _then;

/// Create a copy of SellerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? businessName = null,Object? phone = null,Object? verificationStatus = null,Object? isSellerEnabled = null,}) {
  return _then(_SellerProfile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,isSellerEnabled: null == isSellerEnabled ? _self.isSellerEnabled : isSellerEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
