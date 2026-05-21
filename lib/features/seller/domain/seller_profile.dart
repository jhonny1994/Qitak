import 'package:freezed_annotation/freezed_annotation.dart';

part 'seller_profile.freezed.dart';

@freezed
abstract class SellerProfile with _$SellerProfile {
  const factory SellerProfile({
    required String userId,
    required String businessName,
    required String phone,
    @Default('pending') String verificationStatus,
    @Default(true) bool isSellerEnabled,
  }) = _SellerProfile;
}
