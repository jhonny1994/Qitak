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
    // Auth screens: all users
    if (path.startsWith('/auth')) return true;

    // Shared discovery and communication routes: all authenticated roles
    if (path == '/home' ||
        path.startsWith('/search') ||
        path.startsWith('/notifications') ||
        path.startsWith('/messages') ||
        path.startsWith('/listing/') ||
        path.startsWith('/guest')) {
      return true;
    }

    // Transaction and rating routes: buyers and sellers
    if (path.startsWith('/deals') ||
        path.startsWith('/transactions') ||
        path.startsWith('/ratings')) {
      return role == AccountRole.buyer || role == AccountRole.seller;
    }

    // Saved listings and buyer profile: buyer only
    if (path.startsWith('/saved') || path.startsWith('/profile')) {
      return role == AccountRole.buyer;
    }

    // Seller onboarding: seller only, no approval required
    if (path.startsWith('/seller/onboarding')) {
      return role == AccountRole.seller;
    }

    // Seller profile: seller only, no approval required
    if (path.startsWith('/seller/profile')) return role == AccountRole.seller;

    // Remaining seller routes: approved seller only
    if (path.startsWith('/seller')) {
      return role == AccountRole.seller && isSellerApproved;
    }

    // Admin routes: admin/super_admin only
    if (path.startsWith('/admin')) {
      return role == AccountRole.admin || role == AccountRole.superAdmin;
    }

    return false;
  }
}
