import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';

class RedirectIntentNotifier extends Notifier<PostAuthRedirectIntent?> {
  @override
  PostAuthRedirectIntent? build() => null;

  PostAuthRedirectIntent? get rememberedIntent => state;
  set rememberedIntent(PostAuthRedirectIntent? intent) => state = intent;

  PostAuthRedirectIntent? consume() {
    final intent = rememberedIntent;
    rememberedIntent = null;
    return intent;
  }
}

final redirectIntentProvider =
    NotifierProvider<RedirectIntentNotifier, PostAuthRedirectIntent?>(
      RedirectIntentNotifier.new,
    );
