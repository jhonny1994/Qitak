import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_profile.freezed.dart';

enum AccountRole {
  anonymous,
  buyer,
  seller,
  admin,
  superAdmin,
}

@freezed
abstract class AccountProfile with _$AccountProfile {
  const factory AccountProfile({
    required String id,
    required String fullName,
    required String email,
    required String phone,
    required AccountRole role,
    required String language,
    required bool isActive,
  }) = _AccountProfile;

  const AccountProfile._();

  bool get isAuthenticated => role != AccountRole.anonymous;
}

extension AccountRoleX on AccountRole {
  String get route {
    switch (this) {
      case AccountRole.seller:
        return '/seller/home';
      case AccountRole.admin:
      case AccountRole.superAdmin:
        return '/admin/home';
      case AccountRole.anonymous:
      case AccountRole.buyer:
        return '/home';
    }
  }

  String get label {
    switch (this) {
      case AccountRole.anonymous:
        return 'anonymous';
      case AccountRole.buyer:
        return 'buyer';
      case AccountRole.seller:
        return 'seller';
      case AccountRole.admin:
        return 'admin';
      case AccountRole.superAdmin:
        return 'super_admin';
    }
  }
}
