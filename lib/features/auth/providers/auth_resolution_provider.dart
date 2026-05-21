import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';

class AuthResolutionNotifier extends Notifier<AsyncValue<AuthSessionState>> {
  @override
  AsyncValue<AuthSessionState> build() => const AsyncValue.loading();

  Future<void> resolve() async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(authSessionProvider.notifier)
          .restore()
          .timeout(const Duration(seconds: 3));
      state = AsyncValue.data(ref.read(authSessionProvider));
    } on TimeoutException {
      state = AsyncValue.error('auth-timeout', StackTrace.current);
    } on Object catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final authResolutionProvider =
    NotifierProvider<AuthResolutionNotifier, AsyncValue<AuthSessionState>>(
      AuthResolutionNotifier.new,
    );
