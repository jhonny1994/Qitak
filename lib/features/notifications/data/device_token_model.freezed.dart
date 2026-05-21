// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_token_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceTokenModel {

 String get id; String get userId; String get token; String get platform; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of DeviceTokenModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceTokenModelCopyWith<DeviceTokenModel> get copyWith => _$DeviceTokenModelCopyWithImpl<DeviceTokenModel>(this as DeviceTokenModel, _$identity);

  /// Serializes this DeviceTokenModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceTokenModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.token, token) || other.token == token)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,token,platform,createdAt,updatedAt);

@override
String toString() {
  return 'DeviceTokenModel(id: $id, userId: $userId, token: $token, platform: $platform, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DeviceTokenModelCopyWith<$Res>  {
  factory $DeviceTokenModelCopyWith(DeviceTokenModel value, $Res Function(DeviceTokenModel) _then) = _$DeviceTokenModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String token, String platform, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$DeviceTokenModelCopyWithImpl<$Res>
    implements $DeviceTokenModelCopyWith<$Res> {
  _$DeviceTokenModelCopyWithImpl(this._self, this._then);

  final DeviceTokenModel _self;
  final $Res Function(DeviceTokenModel) _then;

/// Create a copy of DeviceTokenModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? token = null,Object? platform = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceTokenModel].
extension DeviceTokenModelPatterns on DeviceTokenModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceTokenModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceTokenModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceTokenModel value)  $default,){
final _that = this;
switch (_that) {
case _DeviceTokenModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceTokenModel value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceTokenModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String token,  String platform,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceTokenModel() when $default != null:
return $default(_that.id,_that.userId,_that.token,_that.platform,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String token,  String platform,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DeviceTokenModel():
return $default(_that.id,_that.userId,_that.token,_that.platform,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String token,  String platform,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DeviceTokenModel() when $default != null:
return $default(_that.id,_that.userId,_that.token,_that.platform,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceTokenModel implements DeviceTokenModel {
  const _DeviceTokenModel({required this.id, required this.userId, required this.token, required this.platform, required this.createdAt, required this.updatedAt});
  factory _DeviceTokenModel.fromJson(Map<String, dynamic> json) => _$DeviceTokenModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String token;
@override final  String platform;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of DeviceTokenModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceTokenModelCopyWith<_DeviceTokenModel> get copyWith => __$DeviceTokenModelCopyWithImpl<_DeviceTokenModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceTokenModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceTokenModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.token, token) || other.token == token)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,token,platform,createdAt,updatedAt);

@override
String toString() {
  return 'DeviceTokenModel(id: $id, userId: $userId, token: $token, platform: $platform, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DeviceTokenModelCopyWith<$Res> implements $DeviceTokenModelCopyWith<$Res> {
  factory _$DeviceTokenModelCopyWith(_DeviceTokenModel value, $Res Function(_DeviceTokenModel) _then) = __$DeviceTokenModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String token, String platform, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$DeviceTokenModelCopyWithImpl<$Res>
    implements _$DeviceTokenModelCopyWith<$Res> {
  __$DeviceTokenModelCopyWithImpl(this._self, this._then);

  final _DeviceTokenModel _self;
  final $Res Function(_DeviceTokenModel) _then;

/// Create a copy of DeviceTokenModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? token = null,Object? platform = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_DeviceTokenModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
