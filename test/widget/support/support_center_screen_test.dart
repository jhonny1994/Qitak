import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/support/data/support_repository.dart';
import 'package:qitak_app/features/support/presentation/support_center_screen.dart';
import 'package:qitak_app/features/support/presentation/support_ticket_create_sheet.dart';

import '../../test_bootstrap.dart';

void main() {
  setUp(LocalSupportRepository.resetForTest);

  const buyerProfile = AccountProfile(
    id: 'buyer-1',
    email: 'buyer@qitak.test',
    fullName: 'Karim Benali',
    phone: '+213555444333',
    role: AccountRole.buyer,
    language: 'en',
    isActive: true,
  );

  Map<String, Object> contractSeed() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return <String, Object>{
      'contract_cache_support_reason_code': jsonEncode(<Map<String, Object>>[
        <String, Object>{
          'policy_type': 'support_reason_code',
          'code': 'payment_issue',
          'label_key': 'supportReasonPaymentIssue',
          'is_active': true,
          'sort_order': 10,
        },
        <String, Object>{
          'policy_type': 'support_reason_code',
          'code': 'technical_issue',
          'label_key': 'supportReasonTechnicalIssue',
          'is_active': true,
          'sort_order': 20,
        },
      ]),
      'contract_cache_support_reason_code_ts': now,
    };
  }

  const supportReasonOptions = <AppPolicyOption>[
    AppPolicyOption(
      policyType: 'support_reason_code',
      code: 'payment_issue',
      labelKey: 'supportReasonPaymentIssue',
      active: true,
      sortOrder: 10,
    ),
    AppPolicyOption(
      policyType: 'support_reason_code',
      code: 'technical_issue',
      labelKey: 'supportReasonTechnicalIssue',
      active: true,
      sortOrder: 20,
    ),
  ];

  testWidgets(
    'authenticated support screen shows ticket list and create action',
    (tester) async {
      final repository = LocalSupportRepository(buyerProfile);
      await repository.createTicket(
        reason: 'payment_issue',
        description:
            'Buyer submitted CCP proof but the seller still cannot verify the transfer.',
      );

      final scope = await buildTestScope(
        const TestMaterialShell(
          child: Scaffold(body: SupportCenterScreen()),
        ),
        seed: <String, Object>{
          ...contractSeed(),
          'qitak.local.session.email': 'buyer@qitak.test',
        },
        overrides: <Object>[
          supportRepositoryProvider.overrideWithValue(repository),
          supportReasonOptionsProvider.overrideWith((ref) async {
            return supportReasonOptions;
          }),
        ],
      );

      await tester.pumpWidget(scope);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SupportCenterScreen)),
      );
      await container.read(authSessionProvider.notifier).restore();
      await tester.pumpAndSettle();

      expect(find.text('Your tickets'), findsOneWidget);
      expect(
        find.byKey(const Key('support-create-ticket-button')),
        findsOneWidget,
      );
      expect(find.text('Payment issue'), findsOneWidget);
    },
  );

  testWidgets('support ticket sheet opens with required fields', (tester) async {
    final repository = LocalSupportRepository(buyerProfile);
    final scope = await buildTestScope(
      TestMaterialShell(
        child: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showSupportTicketCreateSheet(context),
                child: const Text('Open support sheet'),
              ),
            ),
          ),
        ),
      ),
      seed: <String, Object>{
        ...contractSeed(),
        'qitak.local.session.email': 'buyer@qitak.test',
      },
      overrides: <Object>[
        supportRepositoryProvider.overrideWithValue(repository),
        supportReasonOptionsProvider.overrideWith((ref) async {
          return supportReasonOptions;
        }),
      ],
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open support sheet'));
    await tester.pumpAndSettle();

    expect(find.text('New support ticket'), findsOneWidget);
    expect(find.byKey(const Key('support-reason-field')), findsOneWidget);
    expect(find.byKey(const Key('support-description-field')), findsOneWidget);
  });
}
