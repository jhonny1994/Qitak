import 'dart:math';

import 'package:qitak_app/core/constants/app_constants.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/features/auth/data/auth_repository.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/auth_variant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalMemoryAuthRepository implements AuthRepository {
  LocalMemoryAuthRepository(this._prefs) {
    for (final profile in _seedProfiles) {
      _profilesByEmail[profile.email.toLowerCase()] = profile;
    }
  }

  static const _sessionKey = 'qitak.local.session.email';
  final SharedPreferences _prefs;
  final Map<String, AccountProfile> _profilesByEmail =
      <String, AccountProfile>{};

  static final List<AccountProfile> _seedProfiles = [
    const AccountProfile(
      id: 'buyer-001',
      fullName: 'Karim Benali',
      email: 'buyer@qitak.test',
      phone: '+213555000111',
      role: AccountRole.buyer,
      language: 'ar',
      isActive: true,
    ),
    const AccountProfile(
      id: 'seller-001',
      fullName: 'Samir Auto Parts',
      email: 'seller@qitak.test',
      phone: '+213555000222',
      role: AccountRole.seller,
      language: 'ar',
      isActive: true,
    ),
    const AccountProfile(
      id: 'admin-001',
      fullName: 'Amina Ops',
      email: 'admin@qitak.test',
      phone: '+213555000333',
      role: AccountRole.admin,
      language: 'ar',
      isActive: true,
    ),
    const AccountProfile(
      id: 'super-admin-001',
      fullName: kLocalOpsControlName,
      email: 'superadmin@qitak.test',
      phone: '+213555000444',
      role: AccountRole.superAdmin,
      language: 'ar',
      isActive: true,
    ),
  ];

  @override
  Future<AuthSessionSnapshot> restoreSession() async {
    final email = _prefs.getString(_sessionKey);
    if (email == null) {
      return const AuthSessionSnapshot(isAuthenticated: false);
    }

    final profile = _profilesByEmail[email.toLowerCase()];
    if (profile == null || !profile.isActive) {
      await _prefs.remove(_sessionKey);
      return const AuthSessionSnapshot(isAuthenticated: false);
    }

    return AuthSessionSnapshot(isAuthenticated: true, profile: profile);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> deactivateAccount() async {
    final email = _prefs.getString(_sessionKey);
    if (email == null) {
      throw const AppException('Session not found.');
    }
    final existing = _profilesByEmail[email.toLowerCase()];
    if (existing == null) {
      throw const AppException('Profile not found.');
    }
    _profilesByEmail[email.toLowerCase()] = existing.copyWith(isActive: false);
    await _prefs.remove(_sessionKey);
  }

  @override
  Future<AccountProfile> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final profile = _profilesByEmail[email.toLowerCase()];
    if (profile == null || password.length < 8) {
      throw const AppException('Invalid credentials.');
    }
    await _prefs.setString(_sessionKey, profile.email.toLowerCase());
    return profile;
  }

  @override
  Future<AccountProfile> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required SignUpVariant variant,
    String language = 'ar',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (_profilesByEmail.containsKey(email.toLowerCase())) {
      throw const AppException('Unable to create account.');
    }

    final profile = AccountProfile(
      id: '${variant.name}-${Random().nextInt(9000) + 1000}',
      fullName: fullName,
      email: email,
      phone: phone,
      role: variant == SignUpVariant.seller
          ? AccountRole.seller
          : AccountRole.buyer,
      language: language,
      isActive: true,
    );
    _profilesByEmail[email.toLowerCase()] = profile;
    await _prefs.setString(_sessionKey, email.toLowerCase());
    return profile;
  }

  @override
  Future<AccountProfile> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final email = _prefs.getString(_sessionKey);
    if (email == null) {
      throw const AppException('Session not found.');
    }
    final existing = _profilesByEmail[email.toLowerCase()];
    if (existing == null) {
      throw const AppException('Profile not found.');
    }
    final updated = existing.copyWith(
      fullName: fullName,
      phone: phone,
    );
    _profilesByEmail[email.toLowerCase()] = updated;
    return updated;
  }

  @override
  Future<AccountProfile> updateLanguage(String language) async {
    final email = _prefs.getString(_sessionKey);
    if (email == null) {
      throw const AppException('Session not found.');
    }
    final existing = _profilesByEmail[email.toLowerCase()];
    if (existing == null) {
      throw const AppException('Profile not found.');
    }
    final updated = existing.copyWith(language: language);
    _profilesByEmail[email.toLowerCase()] = updated;
    return updated;
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_sessionKey);
  }
}
