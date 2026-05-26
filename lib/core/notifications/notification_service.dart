import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum DevicePlatform { android, ios }

abstract interface class NotificationService {
  Future<void> initialize();
  Future<String?> getToken();
  Stream<RemoteMessage> get onMessage;
  Stream<String> get onTokenRefresh;
  Future<void> requestPermission();
  void bindRouter(GoRouter router);
  void dispose();
  DevicePlatform? get currentPlatform;
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return const NoopNotificationService();
});

/// Holds the target route resolved from the notification that launched the app
/// from a terminated state. Set as a [ProviderScope] override in `main.dart`
/// before [runApp], so the splash screen can incorporate it into its auth-aware
/// route resolution without any timing race.
///
/// Null (the default) means the app was opened normally — not via a
/// notification tap from the terminated state.
final initialNotificationRouteProvider = Provider<String?>((ref) => null);

class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService({
    FirebaseMessaging? messaging,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  GoRouter? _router;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  @override
  DevicePlatform? get currentPlatform {
    if (kIsWeb) {
      return null;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return DevicePlatform.android;
      case TargetPlatform.iOS:
        return DevicePlatform.ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  @override
  Future<void> initialize() async {
    await _messaging.setAutoInitEnabled(true);
  }

  @override
  Future<String?> getToken() {
    return _messaging.getToken();
  }

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission();
  }

  @override
  void bindRouter(GoRouter router) {
    _router = router;
    unawaited(_openedAppSubscription?.cancel());
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _navigateFromMessage,
    );
  }

  /// Resolves the deep-link target route from a [RemoteMessage] payload.
  ///
  /// Exposed as a static method so main can compute the initial
  /// notification route before the widget tree is built, eliminating the
  /// race condition between [FirebaseMessaging.getInitialMessage] and the
  /// splash-screen navigation.
  static String resolveDeepLink(RemoteMessage message) {
    final deepLink = message.data['deep_link'] as String?;
    if (deepLink == null || deepLink.isEmpty) return '/notifications';
    return _isAllowedDeepLink(deepLink) ? deepLink : '/notifications';
  }

  @override
  void dispose() {
    unawaited(_openedAppSubscription?.cancel());
    _openedAppSubscription = null;
  }

  // Called by onMessageOpenedApp (background → foreground tap).
  // Uses push so the notification screen overlays the existing stack.
  void _navigateFromMessage(RemoteMessage message) {
    final router = _router;
    if (router == null) {
      return;
    }
    final target = resolveDeepLink(message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(router.push(target));
    });
  }

  static bool _isAllowedDeepLink(String path) {
    return path == '/home' ||
        path == '/seller/home' ||
        path == '/admin/home' ||
        path == '/search' ||
        path == '/notifications' ||
        path == '/messages' ||
        path.startsWith('/search/') ||
        path.startsWith('/notifications/') ||
        path.startsWith('/messages/') ||
        path.startsWith('/listing/') ||
        path.startsWith('/deals/') ||
        path.startsWith('/transactions/') ||
        path.startsWith('/seller/listings/') ||
        path.startsWith('/admin/verifications/') ||
        path.startsWith('/admin/reports/') ||
        path.startsWith('/admin/conversations/') ||
        path.startsWith('/admin/disputes/');
  }
}

class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  DevicePlatform? get currentPlatform => null;

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<RemoteMessage> get onMessage => const Stream<RemoteMessage>.empty();

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  Future<void> requestPermission() async {}

  @override
  void bindRouter(GoRouter router) {
    final _ = router;
  }

  @override
  void dispose() {}
}
