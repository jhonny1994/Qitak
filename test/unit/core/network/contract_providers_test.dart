import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/contract_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _DomainCodesCase {
  const _DomainCodesCase({
    required this.description,
    required this.cacheKey,
    required this.provider,
    required this.rows,
    required this.expectedCodes,
  });

  final String description;
  final String cacheKey;
  final FutureProvider<List<String>> provider;
  final List<Map<String, Object?>> rows;
  final List<String> expectedCodes;
}

class _DomainContractsCase {
  const _DomainContractsCase({
    required this.description,
    required this.cacheKey,
    required this.provider,
    required this.rows,
    required this.expectedCodes,
    required this.expectedLabelKeys,
  });

  final String description;
  final String cacheKey;
  final FutureProvider<List<AppDomainCode>> provider;
  final List<Map<String, Object?>> rows;
  final List<String> expectedCodes;
  final List<String?> expectedLabelKeys;
}

class _PolicyOptionsCase {
  const _PolicyOptionsCase({
    required this.description,
    required this.cacheKey,
    required this.provider,
    required this.rows,
    required this.expectedCodes,
    required this.expectedLabelKeys,
  });

  final String description;
  final String cacheKey;
  final FutureProvider<List<AppPolicyOption>> provider;
  final List<Map<String, Object?>> rows;
  final List<String> expectedCodes;
  final List<String> expectedLabelKeys;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> buildContainer(Map<String, Object> seed) async {
    SharedPreferences.setMockInitialValues(seed);
    final prefs = await SharedPreferences.getInstance();
    AppContractRepository.clearCachesForTest();
    final repository = AppContractRepository(
      SupabaseClient(
        'http://127.0.0.1:9',
        'test-anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      ),
      prefs,
    );

    final container = ProviderContainer(
      overrides: [
        appContractRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('contract providers cached runtime coverage', () {
    final domainCodeCases = <_DomainCodesCase>[
      _DomainCodesCase(
        description:
            'reportStatusCodesProvider reads cached report lifecycle states',
        cacheKey: 'report_status',
        provider: reportStatusCodesProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'domain_key': 'report_status',
            'code': 'open',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'domain_key': 'report_status',
            'code': 'actioned',
            'is_active': true,
            'sort_order': 20,
          },
        ],
        expectedCodes: <String>['open', 'actioned'],
      ),
      _DomainCodesCase(
        description:
            'disputeStatusCodesProvider reads cached dispute lifecycle states',
        cacheKey: 'dispute_status',
        provider: disputeStatusCodesProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'domain_key': 'dispute_status',
            'code': 'open',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'domain_key': 'dispute_status',
            'code': 'resolved',
            'is_active': true,
            'sort_order': 20,
          },
        ],
        expectedCodes: <String>['open', 'resolved'],
      ),
      _DomainCodesCase(
        description:
            'dealStatusCodesProvider reads cached offline payment states',
        cacheKey: 'deal_status',
        provider: dealStatusCodesProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'domain_key': 'deal_status',
            'code': 'pending_seller_response',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'domain_key': 'deal_status',
            'code': 'payment_proof_submitted',
            'is_active': true,
            'sort_order': 30,
          },
          <String, Object?>{
            'domain_key': 'deal_status',
            'code': 'payment_confirmed',
            'is_active': true,
            'sort_order': 40,
          },
        ],
        expectedCodes: <String>[
          'pending_seller_response',
          'payment_proof_submitted',
          'payment_confirmed',
        ],
      ),
    ];

    for (final testCase in domainCodeCases) {
      test(testCase.description, () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final container = await buildContainer(<String, Object>{
          'contract_cache_${testCase.cacheKey}': jsonEncode(testCase.rows),
          'contract_cache_${testCase.cacheKey}_ts': now,
        });

        final codes = await container.read(testCase.provider.future);

        expect(codes, testCase.expectedCodes);
      });
    }

    final domainContractsCases = <_DomainContractsCase>[
      _DomainContractsCase(
        description:
            'listingStatusContractsProvider reads cached listing contracts',
        cacheKey: 'listing_status',
        provider: listingStatusContractsProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'domain_key': 'listing_status',
            'code': 'draft',
            'label_key': 'listingStatusDraft',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'domain_key': 'listing_status',
            'code': 'active',
            'label_key': 'listingStatusActive',
            'is_active': true,
            'sort_order': 20,
          },
        ],
        expectedCodes: <String>['draft', 'active'],
        expectedLabelKeys: <String?>[
          'listingStatusDraft',
          'listingStatusActive',
        ],
      ),
      _DomainContractsCase(
        description:
            'sellerVerificationStatusContractsProvider reads cached verification states',
        cacheKey: 'seller_verification_status',
        provider: sellerVerificationStatusContractsProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'domain_key': 'seller_verification_status',
            'code': 'pending',
            'label_key': 'sellerVerificationStatusPending',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'domain_key': 'seller_verification_status',
            'code': 'approved',
            'label_key': 'sellerVerificationStatusApproved',
            'is_active': true,
            'sort_order': 20,
          },
        ],
        expectedCodes: <String>['pending', 'approved'],
        expectedLabelKeys: <String?>[
          'sellerVerificationStatusPending',
          'sellerVerificationStatusApproved',
        ],
      ),
    ];

    for (final testCase in domainContractsCases) {
      test(testCase.description, () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final container = await buildContainer(<String, Object>{
          'contract_cache_${testCase.cacheKey}': jsonEncode(testCase.rows),
          'contract_cache_${testCase.cacheKey}_ts': now,
        });

        final contracts = await container.read(testCase.provider.future);

        expect(
          contracts.map((item) => item.code).toList(),
          testCase.expectedCodes,
        );
        expect(
          contracts.map((item) => item.labelKey).toList(),
          testCase.expectedLabelKeys,
        );
      });
    }

    test(
      'listingStatusCodesProvider reads cached marketplace listing states',
      () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final container = await buildContainer(<String, Object>{
          'contract_cache_listing_status': jsonEncode(<Map<String, Object?>>[
            <String, Object?>{
              'domain_key': 'listing_status',
              'code': 'draft',
              'label_key': 'listingStatusDraft',
              'is_active': true,
              'sort_order': 10,
            },
            <String, Object?>{
              'domain_key': 'listing_status',
              'code': 'active',
              'label_key': 'listingStatusActive',
              'is_active': true,
              'sort_order': 20,
            },
            <String, Object?>{
              'domain_key': 'listing_status',
              'code': 'closed',
              'label_key': 'listingStatusClosed',
              'is_active': true,
              'sort_order': 30,
            },
          ]),
          'contract_cache_listing_status_ts': now,
        });

        final codes = await container.read(listingStatusCodesProvider.future);

        expect(codes, <String>['draft', 'active', 'closed']);
      },
    );

    final policyOptionsCases = <_PolicyOptionsCase>[
      _PolicyOptionsCase(
        description:
            'sellerDocumentTypePolicyProvider reads cached document options',
        cacheKey: 'seller_document_type',
        provider: sellerDocumentTypePolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'seller_document_type',
            'code': 'government_id_front',
            'label_key': 'sellerDocumentIdFrontLabel',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'seller_document_type',
            'code': 'business_registration',
            'label_key': 'sellerDocumentBusinessRegistrationLabel',
            'is_active': true,
            'sort_order': 30,
          },
        ],
        expectedCodes: <String>[
          'government_id_front',
          'business_registration',
        ],
        expectedLabelKeys: <String>[
          'sellerDocumentIdFrontLabel',
          'sellerDocumentBusinessRegistrationLabel',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'sellerVerificationReasonPolicyProvider reads cached review reasons',
        cacheKey: 'seller_verification_reason_code',
        provider: sellerVerificationReasonPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'seller_verification_reason_code',
            'code': 'document_unreadable',
            'label_key': 'adminVerificationReasonUnreadable',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'seller_verification_reason_code',
            'code': 'missing_business_registration',
            'label_key': 'adminVerificationReasonMissingBusinessDocument',
            'is_active': true,
            'sort_order': 30,
          },
        ],
        expectedCodes: <String>[
          'document_unreadable',
          'missing_business_registration',
        ],
        expectedLabelKeys: <String>[
          'adminVerificationReasonUnreadable',
          'adminVerificationReasonMissingBusinessDocument',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'reportResolutionDecisionPolicyProvider reads cached moderation decisions',
        cacheKey: 'report_resolution_decision',
        provider: reportResolutionDecisionPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'report_resolution_decision',
            'code': 'dismiss',
            'label_key': 'adminReportDecisionDismiss',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'report_resolution_decision',
            'code': 'remove_listing',
            'label_key': 'adminReportDecisionRemoveListing',
            'is_active': true,
            'sort_order': 30,
          },
        ],
        expectedCodes: <String>['dismiss', 'remove_listing'],
        expectedLabelKeys: <String>[
          'adminReportDecisionDismiss',
          'adminReportDecisionRemoveListing',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'reportResolutionReasonPolicyProvider reads cached moderation reasons',
        cacheKey: 'report_resolution_reason_code',
        provider: reportResolutionReasonPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'report_resolution_reason_code',
            'code': 'spam',
            'label_key': 'adminReportReasonSpam',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'report_resolution_reason_code',
            'code': 'policy_violation',
            'label_key': 'adminReportReasonPolicyViolation',
            'is_active': true,
            'sort_order': 20,
          },
        ],
        expectedCodes: <String>['spam', 'policy_violation'],
        expectedLabelKeys: <String>[
          'adminReportReasonSpam',
          'adminReportReasonPolicyViolation',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'supportReportResolutionDecisionPolicyProvider reads cached support decisions',
        cacheKey: 'support_report_resolution_decision',
        provider: supportReportResolutionDecisionPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'support_report_resolution_decision',
            'code': 'resolve',
            'label_key': 'adminSupportDecisionResolve',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'support_report_resolution_decision',
            'code': 'close',
            'label_key': 'adminSupportDecisionClose',
            'is_active': true,
            'sort_order': 20,
          },
        ],
        expectedCodes: <String>['resolve', 'close'],
        expectedLabelKeys: <String>[
          'adminSupportDecisionResolve',
          'adminSupportDecisionClose',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'supportReportResolutionReasonPolicyProvider reads cached support reasons',
        cacheKey: 'support_report_resolution_reason_code',
        provider: supportReportResolutionReasonPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'support_report_resolution_reason_code',
            'code': 'verified_and_resolved',
            'label_key': 'adminSupportReasonVerifiedAndResolved',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'support_report_resolution_reason_code',
            'code': 'out_of_scope',
            'label_key': 'adminSupportReasonOutOfScope',
            'is_active': true,
            'sort_order': 40,
          },
        ],
        expectedCodes: <String>['verified_and_resolved', 'out_of_scope'],
        expectedLabelKeys: <String>[
          'adminSupportReasonVerifiedAndResolved',
          'adminSupportReasonOutOfScope',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'disputeResolutionDecisionPolicyProvider reads cached dispute decisions',
        cacheKey: 'dispute_resolution_decision',
        provider: disputeResolutionDecisionPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'dispute_resolution_decision',
            'code': 'buyer',
            'label_key': 'adminDisputeDecisionBuyer',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'dispute_resolution_decision',
            'code': 'dismiss',
            'label_key': 'adminDisputeDecisionDismiss',
            'is_active': true,
            'sort_order': 30,
          },
        ],
        expectedCodes: <String>['buyer', 'dismiss'],
        expectedLabelKeys: <String>[
          'adminDisputeDecisionBuyer',
          'adminDisputeDecisionDismiss',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'disputeResolutionOutcomeActionPolicyProvider reads cached outcome actions',
        cacheKey: 'dispute_resolution_outcome_action',
        provider: disputeResolutionOutcomeActionPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'dispute_resolution_outcome_action',
            'code': 'no_action',
            'label_key': 'adminDisputeOutcomeNoAction',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'dispute_resolution_outcome_action',
            'code': 'remove_listing',
            'label_key': 'adminDisputeOutcomeRemoveListing',
            'is_active': true,
            'sort_order': 40,
          },
        ],
        expectedCodes: <String>['no_action', 'remove_listing'],
        expectedLabelKeys: <String>[
          'adminDisputeOutcomeNoAction',
          'adminDisputeOutcomeRemoveListing',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'disputeResolutionReasonPolicyProvider reads cached dispute reasons',
        cacheKey: 'dispute_resolution_reason_code',
        provider: disputeResolutionReasonPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'dispute_resolution_reason_code',
            'code': 'damaged_part',
            'label_key': 'adminDisputeReasonDamagedPart',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'dispute_resolution_reason_code',
            'code': 'insufficient_evidence',
            'label_key': 'adminDisputeReasonInsufficientEvidence',
            'is_active': true,
            'sort_order': 30,
          },
        ],
        expectedCodes: <String>[
          'damaged_part',
          'insufficient_evidence',
        ],
        expectedLabelKeys: <String>[
          'adminDisputeReasonDamagedPart',
          'adminDisputeReasonInsufficientEvidence',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'listingReportReasonPolicyProvider reads cached listing report reasons',
        cacheKey: 'listing_report_reason_code',
        provider: listingReportReasonPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'listing_report_reason_code',
            'code': 'spam',
            'label_key': 'reportListingReasonSpam',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'listing_report_reason_code',
            'code': 'other',
            'label_key': 'reportListingReasonOther',
            'is_active': true,
            'sort_order': 40,
          },
        ],
        expectedCodes: <String>['spam', 'other'],
        expectedLabelKeys: <String>[
          'reportListingReasonSpam',
          'reportListingReasonOther',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'buyerDisputeReasonPolicyProvider reads cached buyer dispute reasons',
        cacheKey: 'buyer_dispute_reason_code',
        provider: buyerDisputeReasonPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'buyer_dispute_reason_code',
            'code': 'wrong_part',
            'label_key': 'disputeReasonWrongPart',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'buyer_dispute_reason_code',
            'code': 'other',
            'label_key': 'disputeReasonOther',
            'is_active': true,
            'sort_order': 50,
          },
        ],
        expectedCodes: <String>['wrong_part', 'other'],
        expectedLabelKeys: <String>[
          'disputeReasonWrongPart',
          'disputeReasonOther',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'buyerPaymentMethodPolicyProvider reads cached payment method options',
        cacheKey: 'buyer_payment_method',
        provider: buyerPaymentMethodPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'buyer_payment_method',
            'code': 'ccp',
            'label_key': 'transactionPaymentMethodCcp',
            'is_active': true,
            'sort_order': 10,
          },
          <String, Object?>{
            'policy_type': 'buyer_payment_method',
            'code': 'baridimob',
            'label_key': 'transactionPaymentMethodBaridiMob',
            'is_active': true,
            'sort_order': 20,
          },
        ],
        expectedCodes: <String>['ccp', 'baridimob'],
        expectedLabelKeys: <String>[
          'transactionPaymentMethodCcp',
          'transactionPaymentMethodBaridiMob',
        ],
      ),
      _PolicyOptionsCase(
        description:
            'supportReasonPolicyProvider reads cached support reason options',
        cacheKey: 'support_reason_code',
        provider: supportReasonPolicyProvider,
        rows: <Map<String, Object?>>[
          <String, Object?>{
            'policy_type': 'support_reason_code',
            'code': 'payment_issue',
            'label_key': 'supportReasonPaymentIssue',
            'is_active': true,
            'sort_order': 20,
          },
          <String, Object?>{
            'policy_type': 'support_reason_code',
            'code': 'technical_issue',
            'label_key': 'supportReasonTechnicalIssue',
            'is_active': true,
            'sort_order': 40,
          },
        ],
        expectedCodes: <String>['payment_issue', 'technical_issue'],
        expectedLabelKeys: <String>[
          'supportReasonPaymentIssue',
          'supportReasonTechnicalIssue',
        ],
      ),
    ];

    for (final testCase in policyOptionsCases) {
      test(testCase.description, () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final container = await buildContainer(<String, Object>{
          'contract_cache_${testCase.cacheKey}': jsonEncode(testCase.rows),
          'contract_cache_${testCase.cacheKey}_ts': now,
        });

        final options = await container.read(testCase.provider.future);

        expect(
          options.map((item) => item.code).toList(),
          testCase.expectedCodes,
        );
        expect(
          options.map((item) => item.labelKey).toList(),
          testCase.expectedLabelKeys,
        );
      });
    }
  });
}
