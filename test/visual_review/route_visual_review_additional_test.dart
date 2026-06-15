@Tags(<String>['visual-review'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/admin/presentation/seller_verification_queue_screen.dart';
import 'package:qitak_app/features/auth/presentation/account_settings_screen.dart';
import 'package:qitak_app/features/auth/presentation/admin_dashboard_screen.dart';
import 'package:qitak_app/features/auth/presentation/guest_account_screen.dart';
import 'package:qitak_app/features/auth/presentation/onboarding_screen.dart';
import 'package:qitak_app/features/auth/presentation/seller_dashboard_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/listings/presentation/saved_listings_screen.dart';
import 'package:qitak_app/features/messaging/presentation/conversation_list_screen.dart';
import 'package:qitak_app/features/messaging/providers/messaging_provider.dart';
import 'package:qitak_app/features/ratings/presentation/rating_screen.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_lifecycle_screen.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';

import '../fixtures/seeded_discovery_repository.dart';
import '../test_bootstrap.dart';

const _runVisualReview = bool.fromEnvironment('RUN_VISUAL_REVIEW');

Future<void> _prepareViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _restoreSessionFor<T extends Widget>(WidgetTester tester) async {
  final container = ProviderScope.containerOf(tester.element(find.byType(T)));
  await container.read(authSessionProvider.notifier).restore();
  await tester.pumpAndSettle();
}

Future<void> _captureScaffold(
  WidgetTester tester,
  String goldenName,
) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));
  await expectLater(
    find.byType(Scaffold).first,
    matchesGoldenFile('goldens/$goldenName'),
  );
}

Future<void> _captureScaffoldInBothThemes(
  WidgetTester tester, {
  required String goldenBaseName,
  required Future<void> Function(ThemeMode mode) pumpForMode,
}) async {
  for (final mode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpForMode(mode);
    final suffix = mode == ThemeMode.light ? 'light' : 'dark';
    await _captureScaffold(tester, '$goldenBaseName-$suffix.png');
  }
}

class _VisualTransactionRepository implements TransactionRepository {
  _VisualTransactionRepository(this.record);

  TransactionRecord record;

  @override
  Future<bool> canSubmitRating({
    required String transactionId,
    required String fromUserId,
    required String toUserId,
  }) async => true;

  @override
  Future<TransactionRecord> createRequest({
    required String listingId,
    required String buyerUserId,
    required String sellerUserId,
    String dealType = 'buy',
    String? exchangeOffer,
  }) async => record;

  @override
  Future<TransactionRecord?> fetchById(String transactionId) async {
    return transactionId == record.id ? record : null;
  }

  @override
  Future<List<TransactionRecord>> listForUser(String userId) async => [record];

  @override
  Future<TransactionRecord> rejectPaymentProof({
    required String transactionId,
    required String actorUserId,
    String? reason,
  }) async {
    return record = record.copyWith(
      state: TransactionState.sellerConfirmed,
      updatedAt: DateTime(2026, 1, 2),
      clearPaymentProofPath: true,
      clearPaymentProofSubmittedAt: true,
      clearPaymentConfirmedAt: true,
      paymentProofRejectionReason: reason,
    );
  }

  @override
  Future<TransactionRecord> selectPaymentMethod({
    required String transactionId,
    required String actorUserId,
    required TransactionPaymentMethod paymentMethod,
  }) async {
    return record = record.copyWith(
      paymentMethod: paymentMethod,
      updatedAt: DateTime(2026, 1, 2),
    );
  }

  @override
  Future<TransactionRecord> submitPaymentProof({
    required String transactionId,
    required String actorUserId,
    required ListingMediaSelection proof,
  }) async {
    return record = record.copyWith(
      state: TransactionState.paymentProofSubmitted,
      paymentProofPath: proof.fileName,
      paymentProofSubmittedAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
    );
  }

  @override
  Future<TransactionRecord> transition({
    required String transactionId,
    required String actorUserId,
    required TransactionState nextState,
    String? note,
  }) async {
    return record = record.copyWith(
      state: nextState,
      updatedAt: DateTime(2026, 1, 2),
      cancellationReason: nextState == TransactionState.cancelled ? note : null,
      confirmedAt: nextState == TransactionState.sellerConfirmed
          ? DateTime(2026, 1, 2)
          : record.confirmedAt,
      paymentConfirmedAt: nextState == TransactionState.paymentConfirmed
          ? DateTime(2026, 1, 2)
          : record.paymentConfirmedAt,
      completedAt: nextState == TransactionState.completed
          ? DateTime(2026, 1, 3)
          : record.completedAt,
      cancelledAt: nextState == TransactionState.cancelled
          ? DateTime(2026, 1, 3)
          : record.cancelledAt,
    );
  }
}

void main() {
  if (!_runVisualReview) {
    test(
      'visual review suite is opt-in',
      () {},
      skip:
          'Set --dart-define=RUN_VISUAL_REVIEW=true to run golden screenshot checks.',
    );
    return;
  }

  testWidgets('captures onboarding screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'onboarding-screen-step-1',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: OnboardingScreen(step: 1)),
          ),
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures guest account screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'guest-account-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: GuestAccountScreen()),
          ),
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures account settings screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'account-settings-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: AccountSettingsScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<AccountSettingsScreen>(tester);
      },
    );
  });

  testWidgets('captures seller dashboard screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'seller-dashboard-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: SellerDashboardScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'seller@qitak.test',
          },
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<SellerDashboardScreen>(tester);
      },
    );
  });

  testWidgets('captures admin dashboard screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'admin-dashboard-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: AdminDashboardScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'superadmin@qitak.test',
          },
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<AdminDashboardScreen>(tester);
      },
    );
  });

  testWidgets('captures saved listings screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'saved-listings-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: SavedListingsScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
            'qitak.saved.listings.buyer-001': <String>['listing-1'],
          },
          overrides: [
            discoveryRepositoryProvider.overrideWithValue(
              seededDiscoveryRepository,
            ),
          ],
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<SavedListingsScreen>(tester);
      },
    );
  });

  testWidgets('captures conversation list screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'conversation-list-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: ConversationListScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<ConversationListScreen>(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ConversationListScreen)),
        );
        await container
            .read(messagingProvider.notifier)
            .sendMessage(
              threadId: 'thread-1',
              senderId: 'buyer-001',
              body: 'Is it still available?',
            );
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('captures seller verification queue screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'seller-verification-queue-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: SellerVerificationQueueScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'admin@qitak.test',
          },
        );

        await tester.pumpWidget(scope);
      },
    );
  });

  testWidgets('captures transaction lifecycle screen', (tester) async {
    await _prepareViewport(tester);

    final repository = _VisualTransactionRepository(
      TransactionRecord(
        id: 'tx-1',
        listingId: 'listing-1',
        buyerUserId: 'buyer-001',
        sellerUserId: 'seller-001',
        state: TransactionState.completed,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026, 1, 3),
        confirmedAt: DateTime(2026, 1, 2),
        completedAt: DateTime(2026, 1, 3),
      ),
    );

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'transaction-lifecycle-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: TransactionLifecycleScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
          overrides: [
            discoveryRepositoryProvider.overrideWithValue(
              seededDiscoveryRepository,
            ),
          ],
          transactionRepositoryOverride: repository,
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<TransactionLifecycleScreen>(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(TransactionLifecycleScreen)),
        );
        await container
            .read(transactionProvider.notifier)
            .refreshForUser('buyer-001');
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('captures transaction detail screen', (tester) async {
    await _prepareViewport(tester);

    final repository = _VisualTransactionRepository(
      TransactionRecord(
        id: 'tx-1',
        listingId: 'listing-1',
        buyerUserId: 'buyer-001',
        sellerUserId: 'seller-001',
        state: TransactionState.sellerConfirmed,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026, 1, 2),
        confirmedAt: DateTime(2026, 1, 2),
      ),
    );

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'transaction-detail-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: TransactionDetailScreen(transactionId: 'tx-1'),
            ),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
          overrides: [
            discoveryRepositoryProvider.overrideWithValue(
              seededDiscoveryRepository,
            ),
          ],
          transactionRepositoryOverride: repository,
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<TransactionDetailScreen>(tester);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('captures rating screen', (tester) async {
    await _prepareViewport(tester);

    final repository = _VisualTransactionRepository(
      TransactionRecord(
        id: 'tx-1',
        listingId: 'listing-1',
        buyerUserId: 'buyer-001',
        sellerUserId: 'seller-001',
        state: TransactionState.completed,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026, 1, 3),
        confirmedAt: DateTime(2026, 1, 2),
        completedAt: DateTime(2026, 1, 3),
      ),
    );

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'rating-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: RatingScreen(transactionId: 'tx-1')),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
          overrides: [
            discoveryRepositoryProvider.overrideWithValue(
              seededDiscoveryRepository,
            ),
          ],
          transactionRepositoryOverride: repository,
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<RatingScreen>(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(RatingScreen)),
        );
        await container
            .read(transactionProvider.notifier)
            .refreshForUser('buyer-001');
        await tester.pumpAndSettle();
      },
    );
  });
}
