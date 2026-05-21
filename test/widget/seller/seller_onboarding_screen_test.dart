import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/domain/discovery_filter_taxonomy.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/features/seller/presentation/seller_onboarding_screen.dart';

import '../../test_bootstrap.dart';

void main() {
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
            verificationStatus: 'needs_more_info',
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
}
