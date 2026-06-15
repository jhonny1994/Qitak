import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/admin/data/admin_reports_repository.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/support/data/support_repository.dart';
import 'package:qitak_app/features/support/presentation/support_center_screen.dart';
import 'package:qitak_app/features/support/presentation/support_ticket_create_sheet.dart';
import 'package:qitak_app/generated/l10n.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

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
      await repository.createTicket(
        reason: 'payment_issue',
        description:
            'Buyer submitted CCP proof but the seller still cannot verify the transfer.',
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

  testWidgets('support ticket sheet opens with required fields', (
    tester,
  ) async {
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
    expect(find.byType(QitakPanel), findsNothing);
  });

  testWidgets('closed support tickets show a closed status label', (
    tester,
  ) async {
    final repository = LocalSupportRepository(buyerProfile);
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
    final ticket = await repository.createTicket(
      reason: 'payment_issue',
      description: 'Initial support ticket that will be dismissed by admin.',
    );
    await const LocalAdminReportsRepository().resolveReport(
      reportId: ticket.id,
      decision: 'close',
      reasonCode: 'duplicate_ticket',
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SupportCenterScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Closed'), findsOneWidget);
    expect(find.text('Open'), findsNothing);
  });

  testWidgets('resolved support tickets show a resolved status label', (
    tester,
  ) async {
    final repository = LocalSupportRepository(buyerProfile);
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
    final ticket = await repository.createTicket(
      reason: 'technical_issue',
      description:
          'Technical issue that support resolved after verifying logs.',
    );
    await const LocalAdminReportsRepository().resolveReport(
      reportId: ticket.id,
      decision: 'resolve',
      reasonCode: 'verified_and_resolved',
    );

    await tester.pumpWidget(scope);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SupportCenterScreen)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    expect(find.text('Resolved'), findsOneWidget);
    expect(find.text('Open'), findsNothing);
  });

  testWidgets('deal guidance routes buyers to live transactions', (
    tester,
  ) async {
    final repository = LocalSupportRepository(buyerProfile);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: SupportCenterScreen()),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const Scaffold(
            body: Text('transaction-lifecycle-screen'),
          ),
        ),
      ],
    );
    final scope = await buildTestScope(
      MaterialApp.router(
        locale: const Locale('en'),
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        routerConfig: router,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
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
      tester.element(find.byType(MaterialApp)),
    );
    await container.read(authSessionProvider.notifier).restore();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Deal-specific problems'));
    await tester.pumpAndSettle();

    expect(find.text('transaction-lifecycle-screen'), findsOneWidget);
  });
}
