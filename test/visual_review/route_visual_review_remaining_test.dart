@Tags(<String>['visual-review'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/features/admin/data/listing_moderation_repository.dart';
import 'package:qitak_app/features/admin/domain/listing_moderation_case.dart';
import 'package:qitak_app/features/admin/presentation/admin_queues_screen.dart';
import 'package:qitak_app/features/admin/presentation/disputes_queue_screen.dart';
import 'package:qitak_app/features/admin/presentation/listing_moderation_queue_screen.dart';
import 'package:qitak_app/features/admin/presentation/listing_review_detail_screen.dart';
import 'package:qitak_app/features/admin/presentation/reports_queue_screen.dart';
import 'package:qitak_app/features/admin/presentation/verification_detail_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/domain/marketplace_listing.dart';
import 'package:qitak_app/features/listings/data/seller_listings_repository.dart';
import 'package:qitak_app/features/listings/domain/listing_media_selection.dart';
import 'package:qitak_app/features/listings/presentation/seller_listings_screen.dart';
import 'package:qitak_app/features/notifications/data/notification_preferences_repository.dart';
import 'package:qitak_app/features/notifications/presentation/notification_preferences_screen.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/features/seller/presentation/seller_application_status_screen.dart';
import 'package:qitak_app/features/transactions/data/transaction_repository.dart';
import 'package:qitak_app/features/transactions/domain/transaction_record.dart';
import 'package:qitak_app/features/transactions/presentation/dispute_create_screen.dart';
import 'package:qitak_app/features/transactions/presentation/transaction_history_screen.dart';
import 'package:qitak_app/features/transactions/providers/transaction_provider.dart';

import '../fixtures/listing_media_fixture.dart';
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

class _VisualSellerListingsRepository implements SellerListingsRepository {
  const _VisualSellerListingsRepository(this.items);

  final List<SellerManagedListing> items;

  @override
  Future<void> applyAction({
    required String listingId,
    required String action,
  }) async {}

  @override
  Future<SellerManagedListing?> fetchById(String listingId) async {
    for (final item in items) {
      if (item.id == listingId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<SellerManagedListing>> listForSeller(String sellerUserId) async {
    return items;
  }
}

class _VisualTransactionRepository implements TransactionRepository {
  _VisualTransactionRepository(this._items);

  final List<TransactionRecord> _items;

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
  }) async => _items.first;

  @override
  Future<TransactionRecord?> fetchById(String transactionId) async {
    for (final item in _items) {
      if (item.id == transactionId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<TransactionRecord>> listForUser(String userId) async => _items;

  @override
  Future<TransactionRecord> rejectPaymentProof({
    required String transactionId,
    required String actorUserId,
    String? reason,
  }) async => _items.first;

  @override
  Future<TransactionRecord> selectPaymentMethod({
    required String transactionId,
    required String actorUserId,
    required TransactionPaymentMethod paymentMethod,
  }) async => _items.first;

  @override
  Future<TransactionRecord> submitPaymentProof({
    required String transactionId,
    required String actorUserId,
    required ListingMediaSelection proof,
  }) async => _items.first;

  @override
  Future<TransactionRecord> transition({
    required String transactionId,
    required String actorUserId,
    required TransactionState nextState,
    String? note,
  }) async => _items.first;
}

class _PolicyAwareSellerRepository implements SellerApplicationRepository {
  @override
  Future<SellerApplication?> fetchById(String applicationId) async {
    return SellerApplication(
      id: applicationId,
      userId: 'seller-001',
      sellerType: 'business',
      businessName: 'Samir Auto Parts',
      phone: '+213555000222',
      email: 'seller@qitak.test',
      wilayaId: '16',
      communeId: '1601',
      bio: 'Verified seller profile',
      verificationStatus: SellerVerificationStatus.submitted,
      reviewReasonCode: 'identity_mismatch',
      documents: <SellerDocument>[
        SellerDocument(
          id: 'doc-1',
          documentType: 'business_registration',
          storagePath: 'seller/docs/business-registration.png',
          uploadedAt: DateTime(2026, 5, 25),
        ),
      ],
    );
  }

  @override
  Future<List<AppPolicyOption>> fetchPolicyOptions(String policyType) async {
    if (policyType == 'seller_document_type') {
      return const <AppPolicyOption>[
        AppPolicyOption(
          policyType: 'seller_document_type',
          code: 'business_registration',
          labelKey: 'sellerDocumentBusinessRegistrationLabel',
          active: true,
          sortOrder: 10,
        ),
      ];
    }
    if (policyType == 'seller_verification_reason_code') {
      return const <AppPolicyOption>[
        AppPolicyOption(
          policyType: 'seller_verification_reason_code',
          code: 'identity_mismatch',
          labelKey: 'adminVerificationReasonIdentityMismatch',
          active: true,
          sortOrder: 10,
        ),
      ];
    }
    return const <AppPolicyOption>[];
  }

  @override
  Future<SellerApplication?> fetchCurrentForUser(String userId) async {
    return fetchById('seller-app-1');
  }

  @override
  Future<List<SellerApplication>> listPendingApplications() async {
    final item = await fetchById('seller-app-1');
    return item == null ? [] : [item];
  }

  @override
  Future<SellerApplication> submitApplication({
    required String userId,
    required SellerApplicationDraft draft,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SellerApplication> updateStatus({
    required String applicationId,
    required SellerVerificationStatus status,
    String? reasonCode,
    String? note,
  }) {
    throw UnimplementedError();
  }
}

class _LocalizedListingModerationRepository
    implements ListingModerationRepository {
  const _LocalizedListingModerationRepository();

  @override
  Future<int> countPendingReviewListings() async => 1;

  @override
  Future<int> countSellerListings(String sellerUserId) async => 1;

  @override
  Future<ListingModerationCase?> fetchListingCase(String listingId) async {
    return ListingModerationCase(
      listing: const MarketplaceListing(
        id: 'listing-1',
        sellerUserId: 'seller-1',
        title: 'Headlight',
        priceAmount: 12000,
        sellerLabelCode: 'seller_label_verified',
        rating: 0,
        threadId: '',
        transactionId: '',
        categoryId: 'lighting',
        categoryCode: 'lighting',
        conditionCode: 'used',
        description: 'Clean used headlight',
        wilayaCode: 'Algiers',
        communeCode: 'Bab Ezzouar',
        brand: 'Audi',
        model: 'A3',
        year: 2018,
        sellerName: 'Qitak Motors',
        primaryImageUrl: testListingMediaDataUri,
        mediaUrls: [testListingMediaDataUri],
        status: 'pending_review',
      ),
      submittedAt: DateTime(2026, 6, 2),
      riskLevel: 'yellow',
      sellerVerificationStatus: SellerVerificationStatus.needsMoreInfo,
      sellerOpenReportCount: 1,
      photoCount: 2,
    );
  }

  @override
  Future<List<ListingModerationQueueItem>> listPendingReviewListings() async =>
      [
        ListingModerationQueueItem(
          listingId: 'listing-1',
          title: 'Headlight',
          categoryCode: 'lighting',
          sellerName: 'Qitak Motors',
          submittedAt: DateTime(2026, 6, 2),
          riskLevel: 'yellow',
        ),
      ];

  @override
  Future<void> reviewListing({
    required String listingId,
    required bool approved,
    String? note,
  }) async {}
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

  testWidgets('captures seller listings screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'seller-listings-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: SellerListingsScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'seller@qitak.test',
          },
          overrides: [
            listingStatusContractsProvider.overrideWith(
              (ref) async => const [
                AppDomainCode(
                  domainKey: 'listing_status',
                  code: 'active',
                  active: true,
                  sortOrder: 1,
                  labelKey: 'listingStatusActive',
                ),
                AppDomainCode(
                  domainKey: 'listing_status',
                  code: 'draft',
                  active: true,
                  sortOrder: 2,
                  labelKey: 'listingStatusDraft',
                ),
              ],
            ),
            sellerListingsRepositoryProvider.overrideWithValue(
              const _VisualSellerListingsRepository(<SellerManagedListing>[
                SellerManagedListing(
                  id: 'listing-owned',
                  title: 'Headlight assembly',
                  status: 'active',
                  price: 18500,
                  categoryId: 'lighting',
                  condition: 'Like new',
                  primaryImageUrl: testListingMediaDataUri,
                  brand: 'Peugeot',
                  model: '308',
                  year: 2018,
                  communeId: '1601',
                  wilayaId: '16',
                ),
              ]),
            ),
          ],
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<SellerListingsScreen>(tester);
      },
    );
  });

  testWidgets('captures seller application status screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'seller-application-status-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: SellerApplicationStatusScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'seller@qitak.test',
          },
          sellerApplicationRepositoryOverride: _PolicyAwareSellerRepository(),
          overrides: [
            currentSellerApplicationProvider.overrideWith(
              (ref) async => SellerApplication(
                id: 'seller-app-1',
                userId: 'seller-001',
                sellerType: 'business',
                businessName: 'Samir Auto Parts',
                phone: '+213555000222',
                email: 'seller@qitak.test',
                wilayaId: '16',
                communeId: '1601',
                bio: 'Verified seller profile',
                verificationStatus: SellerVerificationStatus.submitted,
                reviewReasonCode: 'identity_mismatch',
                documents: <SellerDocument>[
                  SellerDocument(
                    id: 'doc-1',
                    documentType: 'business_registration',
                    storagePath: 'seller/docs/business-registration.png',
                    uploadedAt: DateTime(2026, 5, 25),
                  ),
                ],
              ),
            ),
            sellerVerificationReasonOptionsProvider.overrideWith(
              (ref) async => const [
                (
                  code: 'identity_mismatch',
                  labelKey: 'adminVerificationReasonIdentityMismatch',
                ),
              ],
            ),
            sellerStatusDocumentOptionsProvider.overrideWith(
              (ref) async => const [
                (
                  code: 'business_registration',
                  labelKey: 'sellerDocumentBusinessRegistrationLabel',
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<SellerApplicationStatusScreen>(tester);
      },
    );
  });

  testWidgets('captures notification preferences screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'notification-preferences-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: NotificationPreferencesScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
          overrides: [
            notificationPreferencesProvider.overrideWith(
              (ref) async => const NotificationPreferences(
                pushMessagesEnabled: true,
                pushDealUpdatesEnabled: true,
                pushSavedListingUpdatesEnabled: false,
                emailAccountUpdatesEnabled: true,
                emailDealUpdatesEnabled: false,
              ),
            ),
          ],
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<NotificationPreferencesScreen>(tester);
      },
    );
  });

  testWidgets('captures transaction history screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'transaction-history-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: TransactionHistoryScreen()),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
          transactionRepositoryOverride: _VisualTransactionRepository([
            TransactionRecord(
              id: 'tx-1',
              listingId: 'listing-1',
              buyerUserId: 'buyer-001',
              sellerUserId: 'seller-001',
              state: TransactionState.completed,
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026, 1, 3),
            ),
          ]),
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<TransactionHistoryScreen>(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(TransactionHistoryScreen)),
        );
        await container
            .read(transactionProvider.notifier)
            .refreshForUser('buyer-001');
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('captures dispute create screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'dispute-create-screen',
      pumpForMode: (mode) async {
        final scope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: DisputeCreateScreen(transactionId: 'tx-1'),
            ),
          ),
          seed: const <String, Object>{
            'qitak.local.session.email': 'buyer@qitak.test',
          },
          overrides: [
            buyerDisputeReasonOptionsProvider.overrideWith(
              (ref) async => const [
                AppPolicyOption(
                  policyType: 'buyer_dispute_reason_code',
                  code: 'wrong_part',
                  labelKey: 'disputeReasonWrongPart',
                  active: true,
                  sortOrder: 10,
                ),
                AppPolicyOption(
                  policyType: 'buyer_dispute_reason_code',
                  code: 'condition',
                  labelKey: 'disputeReasonCondition',
                  active: true,
                  sortOrder: 20,
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(scope);
        await _restoreSessionFor<DisputeCreateScreen>(tester);
      },
    );
  });

  testWidgets('captures admin queues screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'admin-queues-screen',
      pumpForMode: (mode) async {
        final adminQueuesScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: AdminQueuesScreen()),
          ),
        );
        await tester.pumpWidget(adminQueuesScope);
      },
    );
  });

  testWidgets('captures listing moderation queue screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'listing-moderation-queue-screen',
      pumpForMode: (mode) async {
        final listingQueueScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: ListingModerationQueueScreen()),
          ),
          listingModerationRepositoryOverride:
              const _LocalizedListingModerationRepository(),
        );
        await tester.pumpWidget(listingQueueScope);
      },
    );
  });

  testWidgets('captures disputes queue screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'disputes-queue-screen',
      pumpForMode: (mode) async {
        final disputesQueueScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: DisputesQueueScreen()),
          ),
        );
        await tester.pumpWidget(disputesQueueScope);
      },
    );
  });

  testWidgets('captures reports queue screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'reports-queue-screen',
      pumpForMode: (mode) async {
        final reportsQueueScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(body: ReportsQueueScreen()),
          ),
        );
        await tester.pumpWidget(reportsQueueScope);
      },
    );
  });

  testWidgets('captures verification detail screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'verification-detail-screen',
      pumpForMode: (mode) async {
        final verificationScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: VerificationDetailScreen(verificationId: 'app-1'),
            ),
          ),
          sellerApplicationRepositoryOverride: _PolicyAwareSellerRepository(),
        );
        await tester.pumpWidget(verificationScope);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('captures listing review detail screen', (tester) async {
    await _prepareViewport(tester);

    await _captureScaffoldInBothThemes(
      tester,
      goldenBaseName: 'listing-review-detail-screen',
      pumpForMode: (mode) async {
        final listingReviewScope = await buildTestScope(
          TestMaterialShell(
            themeMode: mode,
            child: const Scaffold(
              body: ListingReviewDetailScreen(listingId: 'listing-1'),
            ),
          ),
          listingModerationRepositoryOverride:
              const _LocalizedListingModerationRepository(),
        );
        await tester.pumpWidget(listingReviewScope);
        await tester.pumpAndSettle();
      },
    );
  });
}
