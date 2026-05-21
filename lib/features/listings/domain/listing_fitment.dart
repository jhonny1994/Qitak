import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_fitment.freezed.dart';

@freezed
abstract class ListingFitment with _$ListingFitment {
  const factory ListingFitment({
    required String brandCode,
    required String modelCode,
    required int year,
    String? wilayaCode,
    String? communeCode,
  }) = _ListingFitment;
}
