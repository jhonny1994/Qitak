// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_fitment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListingFitment {

 String get brandCode; String get modelCode; int get year; String? get wilayaCode; String? get communeCode;
/// Create a copy of ListingFitment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingFitmentCopyWith<ListingFitment> get copyWith => _$ListingFitmentCopyWithImpl<ListingFitment>(this as ListingFitment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingFitment&&(identical(other.brandCode, brandCode) || other.brandCode == brandCode)&&(identical(other.modelCode, modelCode) || other.modelCode == modelCode)&&(identical(other.year, year) || other.year == year)&&(identical(other.wilayaCode, wilayaCode) || other.wilayaCode == wilayaCode)&&(identical(other.communeCode, communeCode) || other.communeCode == communeCode));
}


@override
int get hashCode => Object.hash(runtimeType,brandCode,modelCode,year,wilayaCode,communeCode);

@override
String toString() {
  return 'ListingFitment(brandCode: $brandCode, modelCode: $modelCode, year: $year, wilayaCode: $wilayaCode, communeCode: $communeCode)';
}


}

/// @nodoc
abstract mixin class $ListingFitmentCopyWith<$Res>  {
  factory $ListingFitmentCopyWith(ListingFitment value, $Res Function(ListingFitment) _then) = _$ListingFitmentCopyWithImpl;
@useResult
$Res call({
 String brandCode, String modelCode, int year, String? wilayaCode, String? communeCode
});




}
/// @nodoc
class _$ListingFitmentCopyWithImpl<$Res>
    implements $ListingFitmentCopyWith<$Res> {
  _$ListingFitmentCopyWithImpl(this._self, this._then);

  final ListingFitment _self;
  final $Res Function(ListingFitment) _then;

/// Create a copy of ListingFitment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? brandCode = null,Object? modelCode = null,Object? year = null,Object? wilayaCode = freezed,Object? communeCode = freezed,}) {
  return _then(_self.copyWith(
brandCode: null == brandCode ? _self.brandCode : brandCode // ignore: cast_nullable_to_non_nullable
as String,modelCode: null == modelCode ? _self.modelCode : modelCode // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,wilayaCode: freezed == wilayaCode ? _self.wilayaCode : wilayaCode // ignore: cast_nullable_to_non_nullable
as String?,communeCode: freezed == communeCode ? _self.communeCode : communeCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingFitment].
extension ListingFitmentPatterns on ListingFitment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingFitment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingFitment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingFitment value)  $default,){
final _that = this;
switch (_that) {
case _ListingFitment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingFitment value)?  $default,){
final _that = this;
switch (_that) {
case _ListingFitment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String brandCode,  String modelCode,  int year,  String? wilayaCode,  String? communeCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingFitment() when $default != null:
return $default(_that.brandCode,_that.modelCode,_that.year,_that.wilayaCode,_that.communeCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String brandCode,  String modelCode,  int year,  String? wilayaCode,  String? communeCode)  $default,) {final _that = this;
switch (_that) {
case _ListingFitment():
return $default(_that.brandCode,_that.modelCode,_that.year,_that.wilayaCode,_that.communeCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String brandCode,  String modelCode,  int year,  String? wilayaCode,  String? communeCode)?  $default,) {final _that = this;
switch (_that) {
case _ListingFitment() when $default != null:
return $default(_that.brandCode,_that.modelCode,_that.year,_that.wilayaCode,_that.communeCode);case _:
  return null;

}
}

}

/// @nodoc


class _ListingFitment implements ListingFitment {
  const _ListingFitment({required this.brandCode, required this.modelCode, required this.year, this.wilayaCode, this.communeCode});
  

@override final  String brandCode;
@override final  String modelCode;
@override final  int year;
@override final  String? wilayaCode;
@override final  String? communeCode;

/// Create a copy of ListingFitment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingFitmentCopyWith<_ListingFitment> get copyWith => __$ListingFitmentCopyWithImpl<_ListingFitment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingFitment&&(identical(other.brandCode, brandCode) || other.brandCode == brandCode)&&(identical(other.modelCode, modelCode) || other.modelCode == modelCode)&&(identical(other.year, year) || other.year == year)&&(identical(other.wilayaCode, wilayaCode) || other.wilayaCode == wilayaCode)&&(identical(other.communeCode, communeCode) || other.communeCode == communeCode));
}


@override
int get hashCode => Object.hash(runtimeType,brandCode,modelCode,year,wilayaCode,communeCode);

@override
String toString() {
  return 'ListingFitment(brandCode: $brandCode, modelCode: $modelCode, year: $year, wilayaCode: $wilayaCode, communeCode: $communeCode)';
}


}

/// @nodoc
abstract mixin class _$ListingFitmentCopyWith<$Res> implements $ListingFitmentCopyWith<$Res> {
  factory _$ListingFitmentCopyWith(_ListingFitment value, $Res Function(_ListingFitment) _then) = __$ListingFitmentCopyWithImpl;
@override @useResult
$Res call({
 String brandCode, String modelCode, int year, String? wilayaCode, String? communeCode
});




}
/// @nodoc
class __$ListingFitmentCopyWithImpl<$Res>
    implements _$ListingFitmentCopyWith<$Res> {
  __$ListingFitmentCopyWithImpl(this._self, this._then);

  final _ListingFitment _self;
  final $Res Function(_ListingFitment) _then;

/// Create a copy of ListingFitment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? brandCode = null,Object? modelCode = null,Object? year = null,Object? wilayaCode = freezed,Object? communeCode = freezed,}) {
  return _then(_ListingFitment(
brandCode: null == brandCode ? _self.brandCode : brandCode // ignore: cast_nullable_to_non_nullable
as String,modelCode: null == modelCode ? _self.modelCode : modelCode // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,wilayaCode: freezed == wilayaCode ? _self.wilayaCode : wilayaCode // ignore: cast_nullable_to_non_nullable
as String?,communeCode: freezed == communeCode ? _self.communeCode : communeCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
