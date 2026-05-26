import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/app_contract_repository.dart';
import 'package:qitak_app/core/network/domain_key.dart';

final reportStatusCodesProvider = FutureProvider<List<String>>((ref) {
  return ref
      .read(appContractRepositoryProvider)
      .fetchDomainCodes(
        DomainKey.reportStatus,
      );
});

final disputeStatusCodesProvider = FutureProvider<List<String>>((ref) {
  return ref
      .read(appContractRepositoryProvider)
      .fetchDomainCodes(
        DomainKey.disputeStatus,
      );
});

final dealStatusCodesProvider = FutureProvider<List<String>>((ref) {
  return ref
      .read(appContractRepositoryProvider)
      .fetchDomainCodes(
        DomainKey.dealStatus,
      );
});

final listingStatusCodesProvider = FutureProvider<List<String>>((ref) {
  return ref
      .read(appContractRepositoryProvider)
      .fetchDomainCodes(
        DomainKey.listingStatus,
      );
});

final listingStatusContractsProvider = FutureProvider<List<AppDomainCode>>((
  ref,
) {
  return ref
      .read(appContractRepositoryProvider)
      .fetchDomainContract(
        DomainKey.listingStatus,
      );
});

final sellerVerificationStatusContractsProvider =
    FutureProvider<List<AppDomainCode>>((ref) {
      return ref
          .read(appContractRepositoryProvider)
          .fetchDomainContract(
            DomainKey.sellerVerificationStatus,
          );
    });

final sellerDocumentTypePolicyProvider = FutureProvider<List<AppPolicyOption>>((
  ref,
) {
  return ref
      .read(appContractRepositoryProvider)
      .fetchPolicyOptions(PolicyKey.sellerDocumentType);
});

final sellerVerificationReasonPolicyProvider =
    FutureProvider<List<AppPolicyOption>>((ref) {
      return ref
          .read(appContractRepositoryProvider)
          .fetchPolicyOptions(PolicyKey.sellerVerificationReasonCode);
    });

final reportResolutionDecisionPolicyProvider =
    FutureProvider<List<AppPolicyOption>>((ref) {
      return ref
          .read(appContractRepositoryProvider)
          .fetchPolicyOptions(PolicyKey.reportResolutionDecision);
    });

final reportResolutionReasonPolicyProvider =
    FutureProvider<List<AppPolicyOption>>((ref) {
      return ref
          .read(appContractRepositoryProvider)
          .fetchPolicyOptions(PolicyKey.reportResolutionReasonCode);
    });

final disputeResolutionDecisionPolicyProvider =
    FutureProvider<List<AppPolicyOption>>((ref) {
      return ref
          .read(appContractRepositoryProvider)
          .fetchPolicyOptions(PolicyKey.disputeResolutionDecision);
    });

final disputeResolutionOutcomeActionPolicyProvider =
    FutureProvider<List<AppPolicyOption>>((ref) {
      return ref
          .read(appContractRepositoryProvider)
          .fetchPolicyOptions(PolicyKey.disputeResolutionOutcomeAction);
    });

final disputeResolutionReasonPolicyProvider =
    FutureProvider<List<AppPolicyOption>>((ref) {
      return ref
          .read(appContractRepositoryProvider)
          .fetchPolicyOptions(PolicyKey.disputeResolutionReasonCode);
    });

final listingReportReasonPolicyProvider = FutureProvider<List<AppPolicyOption>>(
  (ref) {
    return ref
        .read(appContractRepositoryProvider)
        .fetchPolicyOptions(PolicyKey.listingReportReasonCode);
  },
);

final buyerDisputeReasonPolicyProvider = FutureProvider<List<AppPolicyOption>>((
  ref,
) {
  return ref
      .read(appContractRepositoryProvider)
      .fetchPolicyOptions(PolicyKey.buyerDisputeReasonCode);
});
