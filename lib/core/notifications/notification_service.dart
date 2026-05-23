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
  Future<void> handleInitialMessage();
  void dispose();
  DevicePlatform? get currentPlatform;
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return const NoopNotificationService();
});

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

  @override
  Future<void> handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    _navigateFromMessage(message);
  }

  @override
  void dispose() {
    unawaited(_openedAppSubscription?.cancel());
    _openedAppSubscription = null;
  }

  void _navigateFromMessage(RemoteMessage? message) {
    final router = _router;
    if (router == null) {
      return;
    }
    final deepLink = message?.data['deep_link'] as String?;
    final target = _resolveTarget(deepLink);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.go(target);
    });
  }

  String _resolveTarget(String? deepLink) {
    if (deepLink == null || deepLink.isEmpty) return '/notifications';
    return _isAllowedDeepLink(deepLink) ? deepLink : '/notifications';
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
  Future<void> handleInitialMessage() async {}

  @override
  void dispose() {}
}
