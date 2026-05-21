import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/auth_entry_service.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';

void main() {
  const service = AuthEntryService();

  const buyer = AccountProfile(
    id: 'buyer',
    fullName: 'Buyer',
    email: 'buyer@qitak.test',
    phone: '+213',
    role: AccountRole.buyer,
    language: 'ar',
    isActive: true,
  );

  const seller = AccountProfile(
    id: 'seller',
    fullName: 'Seller',
    email: 'seller@qitak.test',
    phone: '+213',
    role: AccountRole.seller,
    language: 'ar',
    isActive: true,
  );

  test('resolves default landing routes by role', () {
    expect(service.resolveLandingRoute(buyer), '/home');
    expect(service.resolveLandingRoute(seller), '/seller/onboarding/status');
    expect(
      service.resolveLandingRoute(seller, isSellerApproved: true),
      '/seller/home',
    );
  });

  test('resumes allowed protected route for matching role', () {
    final intent = PostAuthRedirectIntent.route('/profile');
    expect(
      service.resolvePostAuthDestination(profile: buyer, intent: intent),
      '/profile',
    );
  });

  test('falls back to role landing for unauthorized route', () {
    final intent = PostAuthRedirectIntent.route('/admin/dashboard');
    expect(
      service.resolvePostAuthDestination(profile: buyer, intent: intent),
      '/home',
    );
  });

  test(
    'public account routes remain accessible to anonymous and buyer flows',
    () {
      expect(
        service.canAccessRoleRoute(AccountRole.buyer, '/guest/account'),
        isTrue,
      );
      expect(
        service.resolvePostAuthDestination(
          profile: buyer,
          intent: PostAuthRedirectIntent.route('/guest/account'),
        ),
        '/guest/account',
      );
    },
  );

  test('resumes action intent using the embedded fallback route', () {
    final intent = PostAuthRedirectIntent.action(
      'message-seller',
      arguments: const <String, String>{
        'route': '/messages/thread-1',
      },
    );
    expect(
      service.resolvePostAuthDestination(profile: buyer, intent: intent),
      '/messages/thread-1',
    );
  });

  test('buyer cannot access seller-only routes', () {
    expect(
      service.canAccessRoleRoute(AccountRole.buyer, '/seller/home'),
      isFalse,
    );
    expect(
      service.canAccessRoleRoute(AccountRole.buyer, '/seller/dashboard'),
      isFalse,
    );
    expect(
      service.canAccessRoleRoute(AccountRole.buyer, '/seller/listings/new'),
      isFalse,
    );
    expect(
      service.canAccessRoleRoute(AccountRole.buyer, '/seller/onboarding'),
      isFalse,
    );
    expect(
      service.canAccessRoleRoute(
        AccountRole.buyer,
        '/seller/onboarding/status',
      ),
      isFalse,
    );
    expect(
      service.canAccessRoleRoute(AccountRole.seller, '/seller/profile'),
      isTrue,
    );
    expect(
      service.canAccessRoleRoute(AccountRole.seller, '/seller/home'),
      isFalse,
    );
    expect(
      service.canAccessRoleRoute(
        AccountRole.seller,
        '/seller/home',
        isSellerApproved: true,
      ),
      isTrue,
    );
    expect(
      service.canAccessRoleRoute(AccountRole.admin, '/admin/profile'),
      isTrue,
    );
    expect(
      service.canAccessRoleRoute(AccountRole.seller, '/profile'),
      isFalse,
    );
  });

  test(
    'shared account utility routes stay scoped to the matching role root',
    () {
      expect(
        service.canAccessRoleRoute(AccountRole.buyer, '/profile/settings'),
        isTrue,
      );
      expect(
        service.canAccessRoleRoute(
          AccountRole.buyer,
          '/seller/profile/settings',
        ),
        isFalse,
      );
      expect(
        service.canAccessRoleRoute(
          AccountRole.seller,
          '/seller/profile/appearance',
        ),
        isTrue,
      );
      expect(
        service.canAccessRoleRoute(AccountRole.seller, '/admin/profile/legal'),
        isFalse,
      );
      expect(
        service.canAccessRoleRoute(
          AccountRole.admin,
          '/admin/profile/notifications',
        ),
        isTrue,
      );
      expect(
        service.canAccessRoleRoute(AccountRole.admin, '/profile/support'),
        isFalse,
      );
    },
  );

  test(
    'seller auth destinations stay approval-gated after sign-in or sign-up',
    () {
      expect(
        service.resolvePostAuthDestination(
          profile: seller,
          intent: PostAuthRedirectIntent.route('/seller/home'),
        ),
        '/seller/onboarding/status',
      );
      expect(
        service.resolvePostAuthDestination(
          profile: seller,
          intent: PostAuthRedirectIntent.route('/seller/profile'),
        ),
        '/seller/profile',
      );
    },
  );
}
