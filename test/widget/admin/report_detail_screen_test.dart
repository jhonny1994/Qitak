import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/admin/data/local_admin_report_store.dart';
import 'package:qitak_app/features/admin/presentation/report_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../test_bootstrap.dart';

void main() {
  setUp(LocalAdminReportStore.resetForTest);

  Map<String, Object> contractSeed() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return <String, Object>{
      'contract_cache_support_report_resolution_decision': jsonEncode(
        <Map<String, Object>>[
          <String, Object>{
            'policy_type': 'support_report_resolution_decision',
            'code': 'resolve',
            'label_key': 'adminSupportDecisionResolve',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object>{
            'policy_type': 'support_report_resolution_decision',
            'code': 'close',
            'label_key': 'adminSupportDecisionClose',
            'is_active': true,
            'sort_order': 20,
          },
        ],
      ),
      'contract_cache_support_report_resolution_decision_ts': now,
      'contract_cache_support_report_resolution_reason_code': jsonEncode(
        <Map<String, Object>>[
          <String, Object>{
            'policy_type': 'support_report_resolution_reason_code',
            'code': 'verified_and_resolved',
            'label_key': 'adminSupportReasonVerifiedAndResolved',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object>{
            'policy_type': 'support_report_resolution_reason_code',
            'code': 'user_guided',
            'label_key': 'adminSupportReasonUserGuided',
            'is_active': true,
            'sort_order': 20,
          },
          <String, Object>{
            'policy_type': 'support_report_resolution_reason_code',
            'code': 'duplicate_ticket',
            'label_key': 'adminSupportReasonDuplicateTicket',
            'is_active': true,
            'sort_order': 30,
          },
          <String, Object>{
            'policy_type': 'support_report_resolution_reason_code',
            'code': 'out_of_scope',
            'label_key': 'adminSupportReasonOutOfScope',
            'is_active': true,
            'sort_order': 40,
          },
        ],
      ),
      'contract_cache_support_report_resolution_reason_code_ts': now,
    };
  }

  const moderationDecisionOptions = <AppPolicyOption>[
    AppPolicyOption(
      policyType: 'report_resolution_decision',
      code: 'warn_seller',
      labelKey: 'adminReportDecisionWarnSeller',
      active: true,
      sortOrder: 10,
    ),
    AppPolicyOption(
      policyType: 'report_resolution_decision',
      code: 'dismiss',
      labelKey: 'adminReportDecisionDismiss',
      active: true,
      sortOrder: 20,
    ),
  ];

  const moderationReasonOptions = <AppPolicyOption>[
    AppPolicyOption(
      policyType: 'report_resolution_reason_code',
      code: 'policy_violation',
      labelKey: 'adminReportReasonPolicyViolation',
      active: true,
      sortOrder: 10,
    ),
  ];

  const supportDecisionOptions = <AppPolicyOption>[
    AppPolicyOption(
      policyType: 'support_report_resolution_decision',
      code: 'resolve',
      labelKey: 'adminSupportDecisionResolve',
      active: true,
      sortOrder: 10,
    ),
    AppPolicyOption(
      policyType: 'support_report_resolution_decision',
      code: 'close',
      labelKey: 'adminSupportDecisionClose',
      active: true,
      sortOrder: 20,
    ),
  ];

  const supportReasonOptions = <AppPolicyOption>[
    AppPolicyOption(
      policyType: 'support_report_resolution_reason_code',
      code: 'verified_and_resolved',
      labelKey: 'adminSupportReasonVerifiedAndResolved',
      active: true,
      sortOrder: 10,
    ),
  ];

  testWidgets(
    'support report detail contracts expose support resolution policy keys',
    (tester) async {
      final scope = await buildTestScope(
        TestMaterialShell(
          child: Scaffold(
            body: Consumer(
              builder: (context, ref, child) {
                final decisionOptions = ref.watch(
                  supportReportResolutionDecisionPolicyProvider,
                );
                final reasonOptions = ref.watch(
                  supportReportResolutionReasonPolicyProvider,
                );
                final decisionData = decisionOptions.asData?.value;
                final reasonData = reasonOptions.asData?.value;
                if (decisionData == null || reasonData == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final option in decisionData)
                      Text('${option.code}:${option.labelKey}'),
                    for (final option in reasonData)
                      Text('${option.code}:${option.labelKey}'),
                  ],
                );
              },
            ),
          ),
        ),
        seed: contractSeed(),
        overrides: <Object>[
          appContractRepositoryProvider.overrideWith((ref) {
            return AppContractRepository(
              SupabaseClient(
                'http://127.0.0.1:9',
                'test-anon-key',
                authOptions: const AuthClientOptions(
                  autoRefreshToken: false,
                ),
              ),
              ref.watch(sharedPreferencesProvider),
            );
          }),
        ],
      );

      await tester.pumpWidget(scope);
      await tester.pumpAndSettle();

      expect(
        find.text('resolve:adminSupportDecisionResolve'),
        findsOneWidget,
      );
      expect(find.text('close:adminSupportDecisionClose'), findsOneWidget);
      expect(
        find.text(
          'verified_and_resolved:adminSupportReasonVerifiedAndResolved',
        ),
        findsOneWidget,
      );
      expect(
        find.text('user_guided:adminSupportReasonUserGuided'),
        findsOneWidget,
      );
      expect(
        find.text('duplicate_ticket:adminSupportReasonDuplicateTicket'),
        findsOneWidget,
      );
      expect(
        find.text('out_of_scope:adminSupportReasonOutOfScope'),
        findsOneWidget,
      );
    },
  );

  testWidgets('support reports show support decisions only', (tester) async {
    final initialReport = LocalAdminReportStore.createSupportTicket(
      reporterUserId: 'buyer-1',
      reporterName: 'Buyer One',
      reason: 'payment_issue',
      description:
          'Buyer uploaded a BaridiMob proof and still needs support review.',
    );
    final scope = await buildTestScope(
      TestMaterialShell(
        child: Scaffold(
          body: ReportDetailScreen(reportId: initialReport.id),
        ),
      ),
      overrides: <Object>[
        reportResolutionDecisionPolicyProvider.overrideWith((ref) async {
          return moderationDecisionOptions;
        }),
        reportResolutionReasonPolicyProvider.overrideWith((ref) async {
          return moderationReasonOptions;
        }),
        supportReportResolutionDecisionPolicyProvider.overrideWith((ref) async {
          return supportDecisionOptions;
        }),
        supportReportResolutionReasonPolicyProvider.overrideWith((ref) async {
          return supportReasonOptions;
        }),
      ],
    );
    LocalAdminReportStore.createSupportTicket(
      reporterUserId: 'buyer-1',
      reporterName: 'Buyer One',
      reason: 'payment_issue',
      description:
          'Buyer uploaded a BaridiMob proof and still needs support review.',
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('report-detail-decision-field')));
    await tester.pumpAndSettle();

    expect(find.text('Resolve'), findsWidgets);
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Warn seller'), findsNothing);
  });

  testWidgets('listing reports keep moderation decisions only', (tester) async {
    final initialReport = LocalAdminReportStore.createListingReport(
      reporterUserId: 'buyer-1',
      reporterName: 'Buyer One',
      listingId: 'listing-1',
      listingTitle: 'Brake pads',
      reason: 'spam',
      description: 'Listing contains repeated spam content and fake images.',
    );
    final scope = await buildTestScope(
      TestMaterialShell(
        child: Scaffold(
          body: ReportDetailScreen(reportId: initialReport.id),
        ),
      ),
      overrides: <Object>[
        reportResolutionDecisionPolicyProvider.overrideWith((ref) async {
          return moderationDecisionOptions;
        }),
        reportResolutionReasonPolicyProvider.overrideWith((ref) async {
          return moderationReasonOptions;
        }),
        supportReportResolutionDecisionPolicyProvider.overrideWith((ref) async {
          return supportDecisionOptions;
        }),
        supportReportResolutionReasonPolicyProvider.overrideWith((ref) async {
          return supportReasonOptions;
        }),
      ],
    );
    LocalAdminReportStore.createListingReport(
      reporterUserId: 'buyer-1',
      reporterName: 'Buyer One',
      listingId: 'listing-1',
      listingTitle: 'Brake pads',
      reason: 'spam',
      description: 'Listing contains repeated spam content and fake images.',
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('report-detail-decision-field')));
    await tester.pumpAndSettle();

    expect(find.text('Warn seller'), findsOneWidget);
    expect(find.text('Resolve'), findsNothing);
  });

  testWidgets('support reports show contract failure state', (tester) async {
    final initialReport = LocalAdminReportStore.createSupportTicket(
      reporterUserId: 'buyer-1',
      reporterName: 'Buyer One',
      reason: 'payment_issue',
      description:
          'Buyer uploaded a BaridiMob proof and still needs support review.',
    );
    final scope = await buildTestScope(
      TestMaterialShell(
        child: Scaffold(
          body: ReportDetailScreen(reportId: initialReport.id),
        ),
      ),
      overrides: <Object>[
        supportReportResolutionDecisionPolicyProvider.overrideWith((ref) async {
          throw StateError('broken support decision contract');
        }),
        supportReportResolutionReasonPolicyProvider.overrideWith((ref) async {
          throw StateError('broken support reason contract');
        }),
      ],
    );
    LocalAdminReportStore.createSupportTicket(
      reporterUserId: 'buyer-1',
      reporterName: 'Buyer One',
      reason: 'payment_issue',
      description:
          'Buyer uploaded a BaridiMob proof and still needs support review.',
    );

    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();

    expect(find.text('Resolution options unavailable'), findsOneWidget);
    expect(
      find.text(
        'Decision policies could not be loaded. Refresh contracts and try again before resolving this report.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('report-detail-decision-field')), findsNothing);

    final applyButton = tester.widget<FilledButton>(
      find.byKey(const Key('report-detail-apply-button')),
    );
    expect(applyButton.onPressed, isNull);
  });
}
