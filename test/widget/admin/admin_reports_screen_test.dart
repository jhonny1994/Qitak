import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/features/admin/presentation/reports_queue_screen.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/support/data/support_repository.dart';

import '../../test_bootstrap.dart';

void main() {
  const buyerProfile = AccountProfile(
    id: 'buyer-1',
    email: 'buyer@qitak.test',
    fullName: 'Karim Benali',
    phone: '+213555444333',
    role: AccountRole.buyer,
    language: 'en',
    isActive: true,
  );

  setUp(LocalSupportRepository.resetForTest);

  const supportReasonOptions = <AppPolicyOption>[
    AppPolicyOption(
      policyType: 'support_reason_code',
      code: 'payment_issue',
      labelKey: 'supportReasonPaymentIssue',
      active: true,
      sortOrder: 10,
    ),
  ];

  testWidgets(
    'reports queue copy and items cover support tickets with readable reasons',
    (tester) async {
      final repository = LocalSupportRepository(buyerProfile);
      final scope = await buildTestScope(
        const TestMaterialShell(
          child: Scaffold(body: ReportsQueueScreen()),
        ),
        seed: const <String, Object>{
          'qitak.local.session.email': 'admin@qitak.test',
        },
        overrides: <Object>[
          supportReasonPolicyProvider.overrideWith((ref) async {
            return supportReasonOptions;
          }),
        ],
      );
      await repository.createTicket(
        reason: 'payment_issue',
        description:
            'Buyer submitted CCP proof but still needs manual support review.',
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Track listing, seller, message, and support tickets from one review surface.',
        ),
        findsOneWidget,
      );
      expect(find.text('Payment issue'), findsOneWidget);
      expect(find.text('payment_issue'), findsNothing);
    },
  );
}
