import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/data/auth_repository.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/auth_variant.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'local auth seller sign up persists seller role across restore',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalMemoryAuthRepository(prefs);

      final profile = await repository.signUp(
        fullName: 'Seller Ready',
        email: 'seller.ready@qitak.test',
        phone: '+213555111222',
        password: 'password123',
        variant: SignUpVariant.seller,
      );
      final snapshot = await repository.restoreSession();

      expect(profile.role, AccountRole.seller);
      expect(profile.id.startsWith('seller-'), isTrue);
      expect(snapshot.isAuthenticated, isTrue);
      expect(snapshot.profile?.role, AccountRole.seller);
      expect(snapshot.profile?.fullName, 'Seller Ready');
    },
  );

  test('local auth buyer sign up persists buyer role across restore', () async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repository = LocalMemoryAuthRepository(prefs);

    final profile = await repository.signUp(
      fullName: 'Buyer Ready',
      email: 'buyer.ready@qitak.test',
      phone: '+213555333444',
      password: 'password123',
      variant: SignUpVariant.buyer,
    );
    final snapshot = await repository.restoreSession();

    expect(profile.role, AccountRole.buyer);
    expect(profile.id.startsWith('buyer-'), isTrue);
    expect(snapshot.isAuthenticated, isTrue);
    expect(snapshot.profile?.role, AccountRole.buyer);
    expect(snapshot.profile?.fullName, 'Buyer Ready');
  });
}
