// T042 — Marketplace-completeness smoke tests
//
// T042a  FCM tap navigation  — replicates FirebaseNotificationService
//        ._navigateFromMessage by calling router.go(deepLink) and asserting
//        the target screen appears.
//
// T042b  Offline banner show/hide — overrides isOnlineProvider via
//        StreamController; asserts the banner widget appears/disappears.
//
// T042c  Realtime message delivery without PTR — directly sets
//        conversationMessagesProvider state (identical to what the Supabase
//        Realtime onMessage callback does) and asserts the UI updates without
//        any gesture.
//
// T042d  Unread badge on Messages tab — overrides unreadCountsProvider to
//        return a fixed count of 2; asserts the badge renders in the nav bar.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/app/router.dart';
import 'package:qitak_app/core/connectivity/connectivity_service.dart';
import 'package:qitak_app/features/messaging/data/messaging_repository.dart';
import 'package:qitak_app/features/messaging/domain/conversation_message.dart';
import 'package:qitak_app/features/messaging/providers/messaging_provider.dart';
import 'package:qitak_app/features/notifications/presentation/notification_center_screen.dart';
import 'package:qitak_app/shared/providers/unread_counts_provider.dart';

import '../../test/test_bootstrap.dart';

// ─── Shared seed ─────────────────────────────────────────────────────────────

const _buyerSeed = <String, Object>{
  'qitak.local.session.email': 'buyer@qitak.test',
};

// ─── T042d helper ────────────────────────────────────────────────────────────

/// Notifier that immediately resolves to 2 unread messages.
class _FixedUnreadCountsNotifier extends UnreadCountsNotifier {
  @override
  Future<UnreadCounts> build() async => const (messages: 2, notifications: 0);
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── T042a ─────────────────────────────────────────────────────────────────
  testWidgets(
    'T042a — FCM deep_link navigation routes to the correct screen',
    (tester) async {
      LocalMessagingRepository.resetForTest();

      final scope = await buildTestScope(
        const QitakApp(),
        seed: _buyerSeed,
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );

      // Replicate FirebaseNotificationService._navigateFromMessage:
      //   router.go(deepLink);  where deepLink = '/notifications'
      container.read(goRouterProvider).go('/notifications');

      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.byType(NotificationCenterScreen),
        findsOneWidget,
        reason:
            'T042a — deep_link /notifications must render NotificationCenterScreen',
      );
    },
  );

  // ── T042b ─────────────────────────────────────────────────────────────────
  testWidgets(
    'T042b — Offline banner appears when network lost, disappears when restored',
    (tester) async {
      LocalMessagingRepository.resetForTest();

      final connectivityController = StreamController<bool>();

      final scope = await buildTestScope(
        const QitakApp(),
        seed: _buyerSeed,
        overrides: [
          isOnlineProvider.overrideWith(
            (ref) => connectivityController.stream,
          ),
        ],
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      // ── Go offline ──
      connectivityController.add(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250)); // AnimatedContainer

      // Assert locale-independently using the exact Arabic banner label
      // (buyer profile has language='ar'). This is precise — the offline
      // banner Text is the only widget in the tree with this string.
      expect(
        find.text('أنت غير متصل'),
        findsOneWidget,
        reason:
            'T042b — offline banner Text must be visible when isOnline=false',
      );

      // ── Restore connection ──
      connectivityController.add(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(
        find.text('أنت غير متصل'),
        findsNothing,
        reason: 'T042b — offline banner Text must vanish when isOnline=true',
      );

      await connectivityController.close();
    },
  );

  // ── T042c ─────────────────────────────────────────────────────────────────
  testWidgets(
    'T042c — Incoming realtime message appears without pull-to-refresh',
    (tester) async {
      LocalMessagingRepository.resetForTest();

      final scope = await buildTestScope(
        const QitakApp(),
        seed: _buyerSeed,
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );

      container.read(goRouterProvider).go('/messages/thread/thread-smoke-tc');
      await tester.pumpAndSettle();

      // Set provider state directly — this is exactly what the Supabase
      // Realtime onMessage callback does inside ConversationMessagesNotifier.
      // No gesture is performed; the UI must react to the state change alone.
      container
          .read(conversationMessagesProvider('thread-smoke-tc').notifier)
          .state = AsyncData([
        ConversationMessage(
          id: 'rt-msg-001',
          threadId: 'thread-smoke-tc',
          body: 'Realtime delivery confirmed',
          senderId: 'seller-001',
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pump();

      expect(
        find.text('Realtime delivery confirmed'),
        findsOneWidget,
        reason:
            'T042c — message injected via provider state must appear without PTR',
      );
    },
  );

  // ── T042d ─────────────────────────────────────────────────────────────────
  testWidgets(
    'T042d — Unread badge visible on Messages tab before opening thread',
    (tester) async {
      LocalMessagingRepository.resetForTest();

      final scope = await buildTestScope(
        const QitakApp(),
        seed: _buyerSeed,
        overrides: [
          unreadCountsProvider.overrideWith(_FixedUnreadCountsNotifier.new),
        ],
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      // The nav bar renders Text('2') inside the Messages NavigationDestination
      // when messageBadgeCount = 2 (QitakNavigationShell._badgeIcon).
      expect(
        find.text('2'),
        findsOneWidget,
        reason:
            'T042d — Messages tab must show unread badge (2) before opening a thread',
      );
    },
  );
}
