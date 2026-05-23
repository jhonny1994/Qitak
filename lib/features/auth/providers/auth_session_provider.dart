import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:qitak_app/features/auth/data/auth_repository.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/auth_variant.dart';

part 'auth_session_provider.freezed.dart';

enum AuthResolutionStatus { idle, loading, authenticated, anonymous, failure }

@freezed
abstract class AuthSessionState with _$AuthSessionState {
  const factory AuthSessionState({
    @Default(AuthResolutionStatus.idle) AuthResolutionStatus status,
    AccountProfile? profile,
    String? errorMessage,
  }) = _AuthSessionState;

  const AuthSessionState._();

  factory AuthSessionState.idle() => const AuthSessionState();
  factory AuthSessionState.loading() =>
      const AuthSessionState(status: AuthResolutionStatus.loading);
  factory AuthSessionState.anonymous() =>
      const AuthSessionState(status: AuthResolutionStatus.anonymous);
  factory AuthSessionState.failure(String message) => AuthSessionState(
    status: AuthResolutionStatus.failure,
    errorMessage: message,
  );
  factory AuthSessionState.authenticated(AccountProfile profile) =>
      AuthSessionState(
        status: AuthResolutionStatus.authenticated,
        profile: profile,
      );

  bool get isAuthenticated =>
      status == AuthResolutionStatus.authenticated && profile != null;
}

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() => AuthSessionState.idle();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> restore() async {
    state = AuthSessionState.loading();
    try {
      final snapshot = await _repository.restoreSession();
      if (!snapshot.isAuthenticated || snapshot.profile == null) {
        state = AuthSessionState.anonymous();
        return;
      }
      if (!snapshot.profile!.isActive) {
        await _repository.signOut();
        state = AuthSessionState.failure('inactive-account');
        return;
      }
      state = AuthSessionState.authenticated(snapshot.profile!);
    } on Object {
      state = AuthSessionState.failure('session-restore-failed');
    }
  }

  Future<AccountProfile> signIn({
    required String email,
    required String password,
  }) async {
    final profile = await _repository.signIn(email: email, password: password);
    state = AuthSessionState.authenticated(profile);
    return profile;
  }

  Future<AccountProfile> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required SignUpVariant variant,
    String language = 'ar',
  }) async {
    final profile = await _repository.signUp(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      variant: variant,
      language: language,
    );
    state = AuthSessionState.authenticated(profile);
    return profile;
  }

  Future<void> requestPasswordReset(String email) {
    return _repository.requestPasswordReset(email);
  }

  Future<void> updatePassword(String newPassword) {
    return _repository.updatePassword(newPassword);
  }

  Future<void> deactivateAccount() async {
    await _repository.deactivateAccount();
    state = AuthSessionState.anonymous();
  }

  Future<AccountProfile> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final profile = await _repository.updateProfile(
      fullName: fullName,
      phone: phone,
    );
    state = AuthSessionState.authenticated(profile);
    return profile;
  }

  Future<AccountProfile> updateLanguage(String language) async {
    final profile = await _repository.updateLanguage(language);
    state = AuthSessionState.authenticated(profile);
    return profile;
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = AuthSessionState.anonymous();
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
      AuthSessionNotifier.new,
    );
