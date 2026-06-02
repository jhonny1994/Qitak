import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qitak_app/app/app.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/features/seller/domain/seller_application.dart';

import '../../test/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'seller can resubmit application without duplicate-key error',
    (tester) async {
      final scope = await buildTestScope(
        const QitakApp(),
        seed: const <String, Object>{
          'qitak.local.session.email': 'seller@qitak.test',
          'qitak.ui.onboarding_seen': true,
        },
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(QitakApp)),
      );
      await container.read(authSessionProvider.notifier).restore();
      final profile = container.read(authSessionProvider).profile;
      expect(profile, isNotNull);

      final repository = container.read(sellerApplicationRepositoryProvider);

      // First submission — creates the record.
      final first = await repository.submitApplication(
        userId: profile!.id,
        draft: const SellerApplicationDraft(
          sellerType: 'individual',
          businessName: 'Karim Auto',
          phone: '+213555000222',
          wilayaId: '16',
          communeId: '1601',
          bio: 'First submission.',
          policiesAccepted: true,
        ),
      );
      expect(first.id, isNotEmpty);
      expect(first.verificationStatus, SellerVerificationStatus.submitted);

      // Second submission — must UPDATE the existing row, not throw.
      final second = await repository.submitApplication(
        userId: profile.id,
        draft: const SellerApplicationDraft(
          sellerType: 'individual',
          businessName: 'Karim Auto (updated)',
          phone: '+213555000222',
          wilayaId: '16',
          communeId: '1601',
          bio: 'Resubmission with corrected business name.',
          policiesAccepted: true,
        ),
      );
      expect(second.id, equals(first.id));
      expect(second.businessName, 'Karim Auto (updated)');
      expect(second.verificationStatus, SellerVerificationStatus.submitted);

      // Sanity: only one application record exists for the user.
      final fetched = await repository.fetchCurrentForUser(profile.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, equals(first.id));
    },
  );
}
