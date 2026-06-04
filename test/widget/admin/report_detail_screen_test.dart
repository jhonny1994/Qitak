import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../test_bootstrap.dart';

void main() {
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
}
