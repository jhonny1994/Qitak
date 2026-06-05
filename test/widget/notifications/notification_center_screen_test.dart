import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/notifications/data/notification_repository.dart';
import 'package:qitak_app/features/notifications/domain/app_notification.dart';
import 'package:qitak_app/features/notifications/presentation/notification_center_screen.dart';
import 'package:qitak_app/generated/l10n.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets(
    'renders repository-backed notifications and marks all as read',
    (tester) async {
      final repository = _RecordingNotificationRepository();
      final scope = await buildTestScope(
        MaterialApp(
          locale: const Locale('en'),
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const Scaffold(body: NotificationCenterScreen()),
        ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      notificationRepositoryOverride: repository,
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(find.text('Seller sent a new photo'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      expect(repository.markAllReadCalls, 1);
    },
  );
}

class _RecordingNotificationRepository extends NotificationRepository {
  _RecordingNotificationRepository() : super(client: null, currentUserId: null);

  int markAllReadCalls = 0;

  @override
  Future<int> countUnreadNotifications() async => 1;

  @override
  Future<List<AppNotification>> listNotifications() async => <AppNotification>[
    AppNotification(
      id: 'notif-1',
      type: 'message_received',
      deepLink: '/messages/thread/thread-1',
      body: 'Seller sent a new photo',
      data: const <String, dynamic>{
        'listing_title': 'Alternator listing',
      },
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isUnread: true,
    ),
  ];

  @override
  Future<void> markAllRead() async {
    markAllReadCalls += 1;
  }
}
