@Tags(<String>['visual-review'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/features/discovery/data/discovery_repository.dart';
import 'package:qitak_app/features/discovery/presentation/home_screen.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/listings/presentation/listing_form_screen.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';

import '../fixtures/discovery_filter_taxonomy_fixture.dart';
import '../fixtures/seeded_discovery_repository.dart';
import '../test_bootstrap.dart';

const _runVisualReview = bool.fromEnvironment('RUN_VISUAL_REVIEW');

const _approvedApplication = SellerApplication(
  id: 'seller-app-seller-001',
  userId: 'seller-001',
  sellerType: 'business',
  businessName: 'Samir Auto Parts',
  phone: '+213555000222',
  email: 'seller@qitak.test',
  wilayaId: '1',
  communeId: '1001',
  bio: 'Verified seller profile',
  verificationStatus: SellerVerificationStatus.approved,
);

Future<void> prepareViewport(
  WidgetTester tester, {
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
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

  for (final mode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
    testWidgets('home renders at 360 width in $mode', (tester) async {
      await prepareViewport(tester, size: const Size(360, 800));
      final scope = await buildTestScope(
        TestMaterialShell(
          themeMode: mode,
          child: const Scaffold(body: HomeScreen()),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'buyer@qitak.test',
        },
        overrides: [
          discoveryRepositoryProvider.overrideWithValue(
            seededDiscoveryRepository,
          ),
        ],
      );
      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('listing form remains usable at large text', (tester) async {
    await prepareViewport(tester, size: const Size(430, 932));
    final scope = await buildTestScope(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: TestMaterialShell(
          child: Scaffold(body: ListingFormScreen()),
        ),
      ),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
      },
      overrides: [
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
        currentSellerApplicationProvider.overrideWith(
          (ref) async => _approvedApplication,
        ),
      ],
    );
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
