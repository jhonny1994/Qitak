import 'package:qitak_app/features/auth/domain/account_profile.dart';

enum SignInVariant {
  buyer,
  seller,
  admin,
}

enum SignUpVariant {
  buyer,
  seller,
}

extension SignInVariantX on SignInVariant {
  AccountRole get requiredRole {
    switch (this) {
      case SignInVariant.buyer:
        return AccountRole.buyer;
      case SignInVariant.seller:
        return AccountRole.seller;
      case SignInVariant.admin:
        return AccountRole.admin;
    }
  }
}
