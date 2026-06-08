import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/features/seller/presentation/seller_onboarding_screen.dart';

import '../../test_bootstrap.dart';

void main() {
  testWidgets('seller onboarding exposes persistent five-step progress', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerOnboardingScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        discoveryFilterTaxonomyProvider.overrideWith((ref) async {
          return const DiscoveryFilterTaxonomy(
            categories: <DiscoveryCategoryOption>[],
            wilayas: <WilayaOption>[],
            makes: <CarMakeOption>[],
          );
        }),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerOnboardingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('seller-onboarding-progress')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('seller-onboarding-progress')),
        matching: find.text('1/5'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows the full seller verification path up front', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerOnboardingScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        discoveryFilterTaxonomyProvider.overrideWith((ref) async {
          return const DiscoveryFilterTaxonomy(
            categories: <DiscoveryCategoryOption>[],
            wilayas: <WilayaOption>[],
            makes: <CarMakeOption>[],
          );
        }),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerOnboardingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Account type'), findsOneWidget);
    expect(find.text('Business profile'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Policies'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
  });

  testWidgets('moves from seller type to account-backed profile step', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerOnboardingScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        discoveryFilterTaxonomyProvider.overrideWith((ref) async {
          return const DiscoveryFilterTaxonomy(
            categories: <DiscoveryCategoryOption>[],
            wilayas: <WilayaOption>[
              WilayaOption(
                id: '16',
                name: 'Alger',
                arabicName: 'الجزائر',
                communes: <CommuneOption>[
                  CommuneOption(
                    id: '1601',
                    name: 'Bab Ezzouar',
                    arabicName: 'باب الزوار',
                  ),
                ],
              ),
            ],
            makes: <CarMakeOption>[],
          );
        }),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerOnboardingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
      if (find
          .byKey(const Key('seller-onboarding-next'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    await tester.ensureVisible(find.byKey(const Key('seller-onboarding-next')));
    await tester.tap(find.byKey(const Key('seller-onboarding-next')));
    await tester.pumpAndSettle();

    expect(find.text('Samir Auto Parts'), findsOneWidget);
    expect(find.text('+213555000222'), findsOneWidget);
    expect(find.text('Description'), findsNothing);
    expect(find.text('Government ID (back)'), findsNothing);
  });

  testWidgets('prefills seller onboarding identity from signed up profile', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerOnboardingScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        discoveryFilterTaxonomyProvider.overrideWith((ref) async {
          return const DiscoveryFilterTaxonomy(
            categories: <DiscoveryCategoryOption>[],
            wilayas: <WilayaOption>[],
            makes: <CarMakeOption>[],
          );
        }),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerOnboardingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('seller-onboarding-next')));
    await tester.tap(find.byKey(const Key('seller-onboarding-next')));
    await tester.pumpAndSettle();

    expect(find.text('Samir Auto Parts'), findsOneWidget);
    expect(find.text('+213555000222'), findsOneWidget);
    expect(find.text('Description'), findsNothing);
    expect(find.text('Government ID (back)'), findsNothing);
  });

  testWidgets('existing verification documents satisfy continue flow', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerOnboardingScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: [
        discoveryFilterTaxonomyProvider.overrideWith((ref) async {
          return const DiscoveryFilterTaxonomy(
            categories: <DiscoveryCategoryOption>[],
            wilayas: <WilayaOption>[
              WilayaOption(
                id: '16',
                name: 'Alger',
                arabicName: 'الجزائر',
                communes: <CommuneOption>[
                  CommuneOption(
                    id: '1601',
                    name: 'Bab Ezzouar',
                    arabicName: 'باب الزوار',
                  ),
                ],
              ),
            ],
            makes: <CarMakeOption>[],
          );
        }),
        currentSellerApplicationProvider.overrideWith((ref) async {
          return SellerApplication(
            id: 'seller-app-1',
            userId: 'buyer-001',
            sellerType: 'business',
            businessName: 'Samir Auto Parts',
            phone: '+213555000111',
            email: 'buyer@qitak.test',
            wilayaId: '16',
            communeId: '1601',
            bio: 'Existing application',
            verificationStatus: SellerVerificationStatus.needsMoreInfo,
            documents: <SellerDocument>[
              SellerDocument(
                id: 'doc-1',
                documentType: 'government_id_front',
                storagePath: 'buyer-001/front.jpg',
                uploadedAt: DateTime(2026, 5, 18),
              ),
              SellerDocument(
                id: 'doc-2',
                documentType: 'government_id_back',
                storagePath: 'buyer-001/back.jpg',
                uploadedAt: DateTime(2026, 5, 18),
              ),
              SellerDocument(
                id: 'doc-3',
                documentType: 'business_registration',
                storagePath: 'buyer-001/reg.jpg',
                uploadedAt: DateTime(2026, 5, 18),
              ),
            ],
          );
        }),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerOnboardingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    for (var i = 0; i < 2; i++) {
      await tester.ensureVisible(
        find.byKey(const Key('seller-onboarding-next')),
      );
      await tester.tap(find.byKey(const Key('seller-onboarding-next')));
      await tester.pumpAndSettle();
    }

    expect(find.text('front.jpg'), findsOneWidget);
    expect(find.text('back.jpg'), findsNothing);
    expect(find.text('reg.jpg'), findsOneWidget);

    await tester.tap(find.byKey(const Key('seller-onboarding-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('seller-onboarding-submit')),
    );
    await tester.tap(find.byKey(const Key('seller-onboarding-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('Required verification documents are missing.'),
      findsNothing,
    );
  });

  testWidgets('onboarding document step follows contract policy options', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerOnboardingScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      sellerApplicationRepositoryOverride: _FrontIdOnlyPolicyRepository(),
      overrides: [
        currentSellerApplicationProvider.overrideWith((ref) async {
          return const SellerApplication(
            id: 'seller-app-2',
            userId: 'seller-002',
            sellerType: 'business',
            businessName: 'Seller Co',
            phone: '+213555999999',
            email: 'seller@qitak.test',
            wilayaId: '16',
            communeId: '1601',
            bio: '',
            verificationStatus: SellerVerificationStatus.draft,
          );
        }),
        discoveryFilterTaxonomyProvider.overrideWith((ref) async {
          return const DiscoveryFilterTaxonomy(
            categories: <DiscoveryCategoryOption>[],
            wilayas: <WilayaOption>[
              WilayaOption(
                id: '16',
                name: 'Alger',
                arabicName: 'الجزائر',
                communes: <CommuneOption>[
                  CommuneOption(
                    id: '1601',
                    name: 'Bab Ezzouar',
                    arabicName: 'باب الزوار',
                  ),
                ],
              ),
            ],
            makes: <CarMakeOption>[],
          );
        }),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerOnboardingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Business'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('seller-onboarding-next')));
    await tester.tap(find.byKey(const Key('seller-onboarding-next')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('seller-onboarding-next')));
    await tester.tap(find.byKey(const Key('seller-onboarding-next')));
    await tester.pumpAndSettle();

    expect(find.text('Government ID (front)'), findsWidgets);
    expect(find.text('Business registration'), findsNothing);
  });

  testWidgets('document step blocks Next when required documents are missing', (
    tester,
  ) async {
    // Application with no documents — step 2 must reject Next.
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerOnboardingScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: [
        currentSellerApplicationProvider.overrideWith((ref) async {
          return const SellerApplication(
            id: 'seller-app-docs',
            userId: 'buyer-001',
            sellerType: 'individual',
            businessName: 'Test Seller',
            phone: '+213555000111',
            email: 'buyer@qitak.test',
            wilayaId: '16',
            communeId: '1601',
            bio: '',
            verificationStatus: SellerVerificationStatus.draft,
          );
        }),
        discoveryFilterTaxonomyProvider.overrideWith((ref) async {
          return const DiscoveryFilterTaxonomy(
            categories: <DiscoveryCategoryOption>[],
            wilayas: <WilayaOption>[
              WilayaOption(
                id: '16',
                name: 'Alger',
                arabicName: 'الجزائر',
                communes: <CommuneOption>[
                  CommuneOption(
                    id: '1601',
                    name: 'Bab Ezzouar',
                    arabicName: 'باب الزوار',
                  ),
                ],
              ),
            ],
            makes: <CarMakeOption>[],
          );
        }),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerOnboardingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    // Advance step 0 → 1 → 2
    for (var i = 0; i < 2; i++) {
      await tester.ensureVisible(
        find.byKey(const Key('seller-onboarding-next')),
      );
      await tester.tap(find.byKey(const Key('seller-onboarding-next')));
      await tester.pumpAndSettle();
    }

    // On step 2 — tap Next without any documents
    await tester.ensureVisible(
      find.byKey(const Key('seller-onboarding-next')),
    );
    await tester.tap(find.byKey(const Key('seller-onboarding-next')));
    await tester.pumpAndSettle();

    // Must stay on step 2 and show the error
    expect(
      find.text(
        'Attach the required verification documents before submitting.',
      ),
      findsOneWidget,
    );
    // Step 3 content must NOT be visible
    expect(find.byKey(const Key('seller-onboarding-submit')), findsNothing);
  });

  testWidgets('submitted application shows read-only status view', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const TestMaterialShell(
        child: Scaffold(body: SellerOnboardingScreen()),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        currentSellerApplicationProvider.overrideWith((ref) async {
          return const SellerApplication(
            id: 'seller-app-submitted',
            userId: 'seller-001',
            sellerType: 'individual',
            businessName: 'Test Seller',
            phone: '+213555000111',
            email: 'seller@qitak.test',
            wilayaId: '16',
            communeId: '1601',
            bio: '',
            verificationStatus: SellerVerificationStatus.submitted,
          );
        }),
        discoveryFilterTaxonomyProvider.overrideWith((ref) async {
          return const DiscoveryFilterTaxonomy(
            categories: <DiscoveryCategoryOption>[],
            wilayas: <WilayaOption>[],
            makes: <CarMakeOption>[],
          );
        }),
      ],
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SellerOnboardingScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    // The form must NOT be shown; the read-only status view must be shown
    expect(find.byKey(const Key('seller-onboarding-next')), findsNothing);
    expect(find.text('View verification status'), findsOneWidget);
  });
}

class _FrontIdOnlyPolicyRepository extends _NoopSellerRepository {
  @override
  Future<List<AppPolicyOption>> fetchPolicyOptions(String policyType) async {
    if (policyType == 'seller_document_type') {
      return const <AppPolicyOption>[
        AppPolicyOption(
          policyType: 'seller_document_type',
          code: 'government_id_front',
          labelKey: 'sellerDocumentIdFrontLabel',
          active: true,
          sortOrder: 10,
        ),
      ];
    }
    return const <AppPolicyOption>[];
  }
}

class _NoopSellerRepository implements SellerApplicationRepository {
  @override
  Future<SellerApplication?> fetchById(String applicationId) async => null;

  @override
  Future<SellerApplication?> fetchCurrentForUser(String userId) async => null;

  @override
  Future<List<SellerApplication>> listPendingApplications() async =>
      const <SellerApplication>[];

  @override
  Future<List<AppPolicyOption>> fetchPolicyOptions(String policyType) async =>
      const <AppPolicyOption>[];

  @override
  Future<SellerApplication> submitApplication({
    required String userId,
    required SellerApplicationDraft draft,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<SellerApplication> updateStatus({
    required String applicationId,
    required SellerVerificationStatus status,
    String? reasonCode,
    String? note,
  }) async {
    throw UnimplementedError();
  }
}
