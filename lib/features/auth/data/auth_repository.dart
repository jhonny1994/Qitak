import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/constants/app_constants.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/notifications/notification_service.dart';
import 'package:qitak_app/core/storage/secure_storage_service.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/auth_variant.dart';
import 'package:qitak_app/features/notifications/data/device_token_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionSnapshot {
  const AuthSessionSnapshot({
    required this.isAuthenticated,
    this.profile,
  });

  final bool isAuthenticated;
  final AccountProfile? profile;
}

abstract class AuthRepository {
  Future<AuthSessionSnapshot> restoreSession();
  Future<AccountProfile> signIn({
    required String email,
    required String password,
  });
  Future<AccountProfile> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required SignUpVariant variant,
  });
  Future<void> requestPasswordReset(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> deactivateAccount();
  Future<AccountProfile> updateProfile({
    required String fullName,
    required String phone,
  });
  Future<AccountProfile> updateLanguage(String language);
  Future<void> signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final deviceTokenRepository = ref.watch(deviceTokenRepositoryProvider);
  if (client == null) {
    throw StateError('Supabase client is required for runtime auth.');
  }
  return SupabaseAuthRepository(
    client,
    prefs,
    secureStorage,
    notificationService,
    deviceTokenRepository,
  );
});

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
      language: 'ar',
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

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(
    this._client,
    this._prefs,
    this._secureStorageService,
    this._notificationService,
    this._deviceTokenRepository,
  );

  final SupabaseClient _client;
  final SharedPreferences _prefs;
  final SecureStorageService _secureStorageService;
  final NotificationService _notificationService;
  final DeviceTokenRepository _deviceTokenRepository;

  @override
  Future<AuthSessionSnapshot> restoreSession() async {
    await _secureStorageService.migrateFromSharedPreferences(_prefs);
    final session = _client.auth.currentSession;
    final user = _client.auth.currentUser;

    if (session == null || user == null) {
      return const AuthSessionSnapshot(isAuthenticated: false);
    }

    final profile = await _fetchProfile(
      user.id,
      user.email ?? '',
      fallbackName: (user.userMetadata?['full_name'] as String?) ?? '',
      fallbackPhone: (user.userMetadata?['phone'] as String?) ?? '',
      fallbackRole: _fallbackRoleFromMetadata(user.userMetadata),
      allowFallbackOnError: true,
    );
    return AuthSessionSnapshot(isAuthenticated: true, profile: profile);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> deactivateAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AppException('Session not found.');
    }
    await _client.rpc<dynamic>('self_deactivate_account');
    await _deleteCurrentDeviceToken();
    await _secureStorageService.deleteRefreshToken();
    await _client.auth.signOut();
  }

  @override
  Future<AccountProfile> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AppException('Invalid credentials.');
    }
    final refreshToken = response.session?.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorageService.writeRefreshToken(refreshToken);
    }
    final profile = await _fetchProfile(
      user.id,
      user.email ?? email,
      fallbackName: (user.userMetadata?['full_name'] as String?) ?? '',
      fallbackPhone: (user.userMetadata?['phone'] as String?) ?? '',
      fallbackRole: _fallbackRoleFromMetadata(user.userMetadata),
      allowFallbackOnError: true,
    );
    await _registerCurrentDeviceToken();
    return profile;
  }

  @override
  Future<AccountProfile> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required SignUpVariant variant,
  }) async {
    late final AuthResponse response;
    try {
      response = await _client.auth.signUp(
        email: email,
        password: password,
        data: <String, dynamic>{
          'full_name': fullName,
          'phone': phone,
          'role': variant == SignUpVariant.seller ? 'seller' : 'buyer',
        },
      );
    } on AuthException catch (error) {
      throw AppException(_friendlySignUpError(error.message));
    }

    final user = response.user;
    if (user == null) {
      throw const AppException('Unable to create account.');
    }
    final refreshToken = response.session?.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorageService.writeRefreshToken(refreshToken);
    }

    final role = variant == SignUpVariant.seller ? 'seller' : 'buyer';
    final profilePayload = <String, dynamic>{
      'id': user.id,
      'full_name': fullName,
      'email': user.email ?? email,
      'phone': phone,
      'role': role,
      'language': 'ar',
      'is_active': true,
    };
    try {
      await _client.from('profiles').upsert(profilePayload, onConflict: 'id');
    } on PostgrestException catch (error, stackTrace) {
      _logAuthDebug(
        'sign_up_profile_upsert_failed',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{
          'userId': user.id,
          'email': user.email ?? email,
          'role': role,
          'code': error.code,
          'details': error.details,
          'hint': error.hint,
          'message': error.message,
        },
      );
      throw AppException(_friendlyProfileSetupError(error));
    }

    return _fetchProfile(
      user.id,
      user.email ?? email,
      fallbackName: fullName,
      fallbackPhone: phone,
      fallbackRole: variant == SignUpVariant.seller
          ? AccountRole.seller
          : AccountRole.buyer,
      allowFallbackOnError: true,
    );
  }

  @override
  Future<AccountProfile> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AppException('Session not found.');
    }
    await _client
        .from('profiles')
        .update(<String, dynamic>{
          'full_name': fullName,
          'phone': phone,
        })
        .eq('id', user.id);
    return _fetchProfile(
      user.id,
      user.email ?? '',
      fallbackName: fullName,
      fallbackPhone: phone,
      fallbackRole: _fallbackRoleFromMetadata(user.userMetadata),
      allowFallbackOnError: true,
    );
  }

  @override
  Future<AccountProfile> updateLanguage(String language) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AppException('Session not found.');
    }
    final existing = await _client
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('profiles')
          .update(<String, dynamic>{'language': language})
          .eq('id', user.id);
    } else {
      final metadataName = (user.userMetadata?['full_name'] as String?)?.trim();
      final metadataPhone = (user.userMetadata?['phone'] as String?)?.trim();
      final fallbackRole = _fallbackRoleFromMetadata(user.userMetadata);
      await _client.from('profiles').insert(<String, dynamic>{
        'id': user.id,
        'email': user.email ?? '',
        'full_name': (metadataName?.isNotEmpty ?? false)
            ? metadataName
            : _nameFromEmail(user.email),
        'phone': (metadataPhone?.isNotEmpty ?? false) ? metadataPhone : '-',
        'role': _roleToStorageValue(fallbackRole),
        'language': language,
        'is_active': true,
      });
    }
    return _fetchProfile(
      user.id,
      user.email ?? '',
      fallbackLanguage: language,
      fallbackRole: _fallbackRoleFromMetadata(user.userMetadata),
      allowFallbackOnError: true,
    );
  }

  @override
  Future<void> signOut() async {
    await _deleteCurrentDeviceToken();
    await _secureStorageService.deleteRefreshToken();
    await _client.auth.signOut();
  }

  Future<AccountProfile> _fetchProfile(
    String userId,
    String email, {
    String fallbackName = '',
    String fallbackPhone = '',
    String fallbackLanguage = 'ar',
    AccountRole fallbackRole = AccountRole.buyer,
    bool allowFallbackOnError = false,
  }) async {
    final data = await _readProfileData(
      userId,
      allowFallbackOnError: allowFallbackOnError,
    );

    final map =
        data ??
        _fallbackProfileMap(
          userId: userId,
          email: email,
          fallbackName: fallbackName,
          fallbackPhone: fallbackPhone,
          fallbackLanguage: fallbackLanguage,
          fallbackRole: fallbackRole,
        );

    final resolvedFullName = ((map['full_name'] as String?) ?? '').trim();
    final resolvedPhone = ((map['phone'] as String?) ?? '').trim();
    return AccountProfile(
      id: map['id'] as String,
      fullName: resolvedFullName.isNotEmpty ? resolvedFullName : fallbackName,
      email: (map['email'] as String?) ?? email,
      phone: resolvedPhone.isNotEmpty ? resolvedPhone : fallbackPhone,
      role: _roleFromString(
        (map['role'] as String?) ?? _roleToStorageValue(fallbackRole),
      ),
      language: (map['language'] as String?) ?? fallbackLanguage,
      isActive: (map['is_active'] as bool?) ?? true,
    );
  }

  Future<Map<String, dynamic>?> _readProfileData(
    String userId, {
    required bool allowFallbackOnError,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final data = await _client
            .from('profiles')
            .select('id, full_name, email, phone, role, language, is_active')
            .eq('id', userId)
            .maybeSingle();
        if (data != null) {
          return data;
        }
      } on PostgrestException catch (error) {
        lastError = error;
      }

      if (attempt < 2) {
        await Future<void>.delayed(Duration(milliseconds: 150 * (attempt + 1)));
      }
    }

    if (lastError != null && !allowFallbackOnError) {
      if (lastError case final PostgrestException error) {
        throw error;
      }
    }
    return null;
  }

  Map<String, dynamic> _fallbackProfileMap({
    required String userId,
    required String email,
    required String fallbackName,
    required String fallbackPhone,
    required String fallbackLanguage,
    required AccountRole fallbackRole,
  }) {
    final resolvedName = fallbackName.trim().isNotEmpty
        ? fallbackName.trim()
        : _nameFromEmail(email);
    return <String, dynamic>{
      'id': userId,
      'full_name': resolvedName,
      'email': email,
      'phone': fallbackPhone,
      'role': _roleToStorageValue(fallbackRole),
      'language': fallbackLanguage,
      'is_active': true,
    };
  }

  Future<void> _registerCurrentDeviceToken() async {
    final platform = _notificationService.currentPlatform;
    if (platform == null) {
      return;
    }

    try {
      await _notificationService.requestPermission();
      final token = await _notificationService.getToken();
      if (token == null || token.isEmpty) {
        return;
      }
      await _deviceTokenRepository.register(token: token, platform: platform);
    } on Object {
      // Push registration failure is non-fatal for auth flows.
    }
  }

  Future<void> _deleteCurrentDeviceToken() async {
    final platform = _notificationService.currentPlatform;
    if (platform == null) {
      return;
    }

    try {
      await _deviceTokenRepository.deleteForCurrentPlatform(platform);
    } on Object {
      // Sign-out should continue even if token cleanup fails.
    }
  }
}

String _friendlySignUpError(String message) {
  final normalized = message.toLowerCase();
  if (normalized.contains('already registered') ||
      normalized.contains('already exists')) {
    return 'An account with this email already exists.';
  }
  if (normalized.contains('password')) {
    return 'Password does not meet security requirements.';
  }
  if (normalized.contains('invalid email')) {
    return 'Please enter a valid email address.';
  }
  return 'Unable to create account.';
}

String _friendlyProfileSetupError(PostgrestException error) {
  final message = error.message.toLowerCase();
  final details = '${error.details ?? ''}'.toLowerCase();
  if (message.contains('row-level security') ||
      details.contains('row-level security') ||
      message.contains('new row violates row-level security policy')) {
    return 'Account created, but profile setup was blocked. Please try signing in again after updating the backend.';
  }
  if (message.contains('infinite recursion')) {
    return 'Account created, but profile setup is blocked by a backend policy issue.';
  }
  return 'Account created, but profile setup could not finish.';
}

String _nameFromEmail(String? email) {
  if (email == null || email.isEmpty || !email.contains('@')) {
    return 'Buyer';
  }
  final handle = email.split('@').first.trim();
  if (handle.isEmpty) {
    return 'Buyer';
  }
  final first = handle[0].toUpperCase();
  final rest = handle.length > 1 ? handle.substring(1) : '';
  return '$first$rest';
}

AccountRole _roleFromString(String value) {
  switch (value) {
    case 'seller':
      return AccountRole.seller;
    case 'admin':
      return AccountRole.admin;
    case 'super_admin':
      return AccountRole.superAdmin;
    case 'buyer':
    default:
      return AccountRole.buyer;
  }
}

AccountRole _fallbackRoleFromMetadata(Map<String, dynamic>? metadata) {
  final role = metadata?['role'];
  if (role is String && role.isNotEmpty) {
    return _roleFromString(role);
  }
  return AccountRole.buyer;
}

String _roleToStorageValue(AccountRole role) {
  switch (role) {
    case AccountRole.seller:
      return 'seller';
    case AccountRole.admin:
      return 'admin';
    case AccountRole.superAdmin:
      return 'super_admin';
    case AccountRole.buyer:
    case AccountRole.anonymous:
      return 'buyer';
  }
}

void _logAuthDebug(
  String event, {
  Object? error,
  StackTrace? stackTrace,
  Map<String, Object?> context = const <String, Object?>{},
}) {
  developer.log(
    'auth_debug::$event ${context.isEmpty ? '' : context}',
    name: 'qitak.auth',
    error: error,
    stackTrace: stackTrace,
  );
}
