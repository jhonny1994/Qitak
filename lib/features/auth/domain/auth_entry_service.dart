import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';

class AuthEntryService {
  const AuthEntryService();

  String resolveLandingRoute(
    AccountProfile profile, {
    bool isSellerApproved = false,
  }) {
    if (!profile.isActive) {
      return '/';
    }
    if (profile.role == AccountRole.seller && !isSellerApproved) {
      return '/seller/onboarding/status';
    }
    return profile.role.route;
  }

  String resolvePostAuthDestination({
    required AccountProfile profile,
    PostAuthRedirectIntent? intent,
    bool isSellerApproved = false,
  }) {
    if (intent == null) {
      return resolveLandingRoute(
        profile,
        isSellerApproved: isSellerApproved,
      );
    }

    if (!profile.isActive) {
      return '/';
    }

    if (intent.targetType == IntentTargetType.route) {
      if (_canAccessRoute(
        profile.role,
        intent.targetValue,
        isSellerApproved: isSellerApproved,
      )) {
        return intent.targetValue;
      }
      return resolveLandingRoute(
        profile,
        isSellerApproved: isSellerApproved,
      );
    }

    final fallbackRoute = intent.fallbackRoute;
    if (fallbackRoute != null &&
        _canAccessRoute(
          profile.role,
          fallbackRoute,
          isSellerApproved: isSellerApproved,
        )) {
      return fallbackRoute;
    }

    return resolveLandingRoute(
      profile,
      isSellerApproved: isSellerApproved,
    );
  }

  bool canAccessRoleRoute(
    AccountRole role,
    String path, {
    bool isSellerApproved = false,
  }) {
    return _canAccessRoute(
      role,
      path,
      isSellerApproved: isSellerApproved,
    );
  }

  bool _canAccessRoute(
    AccountRole role,
    String path, {
    bool isSellerApproved = false,
  }) {
    if (path.startsWith('/auth')) {
      return true;
    }
    if (path.startsWith('/seller/onboarding')) {
      return role == AccountRole.seller;
    }
    if (path.startsWith('/admin')) {
      return role == AccountRole.admin || role == AccountRole.superAdmin;
    }
    if (path.startsWith('/seller/profile')) {
      return role == AccountRole.seller;
    }
    if (path.startsWith('/seller')) {
      return role == AccountRole.seller && isSellerApproved;
    }
    if (path.startsWith('/admin/profile')) {
      return role == AccountRole.admin || role == AccountRole.superAdmin;
    }
    if (path.startsWith('/profile')) {
      return role == AccountRole.buyer;
    }
    return true;
  }
}
