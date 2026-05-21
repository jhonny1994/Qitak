import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/presentation/seller_dashboard_screen.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/discovery/providers/discovery_filter_provider.dart';
import 'package:qitak_app/features/listings/presentation/listing_form_screen.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/features/seller/presentation/seller_application_status_screen.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

import '../../test/fixtures/discovery_filter_taxonomy_fixture.dart';
import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('seller listing form uses structured dependent selectors', (
    tester,
  ) async {
    final scope = await buildTestScope(
      const QitakApp(),
      seed: const <String, Object>{
        'qitak.local.session.email': 'seller@qitak.test',
        'qitak.ui.onboarding_seen': true,
      },
      overrides: [
        discoveryFilterTaxonomyProvider.overrideWith(
          (ref) => Future.value(testDiscoveryFilterTaxonomy),
        ),
      ],
    );

    await tester.pumpWidget(scope);
    await _approveSeller(tester);
    await tester.pumpAndSettle();
    await _enterSellerWorkspaceIfNeeded(tester);

    expect(find.byType(SellerDashboardScreen), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(ListingFormScreen), findsOneWidget);

    expect(_findDropdownField('listing-commune-field-'), findsOneWidget);

    await tester.tap(_findDropdownField('listing-wilaya-field-'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أدرار').last);
    await tester.pumpAndSettle();

    await tester.tap(_findDropdownField('listing-commune-field-1-'));
    await tester.pumpAndSettle();
    expect(find.text('أدرار').last, findsOneWidget);
    await tester.tap(find.text('أدرار').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(_findDropdownField('listing-make-field-'));
    await tester.tap(_findDropdownField('listing-make-field-'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Audi').last);
    await tester.pumpAndSettle();

    await tester.tap(_findDropdownField('listing-model-field-Audi-'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TT Coupe').last);
    await tester.pumpAndSettle();

    await tester.tap(_findDropdownField('listing-year-field-Audi-TT Coupe-'));
    await tester.pumpAndSettle();
    expect(find.text('2018').last, findsOneWidget);
  });
}

Finder _findDropdownField(String keyPrefix) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is QitakDropdownField &&
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith(keyPrefix),
    description: 'QitakDropdownField($keyPrefix)',
  );
}

Future<void> _enterSellerWorkspaceIfNeeded(WidgetTester tester) async {
  if (find.byType(SellerApplicationStatusScreen).evaluate().isNotEmpty) {
    final context = tester.element(find.byType(SellerApplicationStatusScreen));
    await tester.tap(find.text(context.l10n.sellerStatusBackToWorkspace));
    await tester.pumpAndSettle();
  }
}

Future<void> _approveSeller(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(QitakApp)),
  );
  await container.read(authSessionProvider.notifier).restore();
  final profile = container.read(authSessionProvider).profile;
  if (profile == null) {
    throw StateError('Expected seller profile in integration setup.');
  }
  final repository = container.read(sellerApplicationRepositoryProvider);
  final existing = await repository.fetchCurrentForUser(profile.id);
  final application =
      existing ??
      await repository.submitApplication(
        userId: profile.id,
        draft: const SellerApplicationDraft(
          sellerType: 'business',
          businessName: 'Samir Auto Parts',
          phone: '+213555000222',
          wilayaId: '1',
          communeId: '1001',
          bio: 'Approved seller integration fixture.',
          policiesAccepted: true,
        ),
      );
  if (!application.isApproved) {
    await repository.updateStatus(
      applicationId: application.id,
      status: 'approved',
    );
  }
}
