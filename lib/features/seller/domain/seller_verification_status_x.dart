import 'package:qitak_app/features/seller/domain/seller_application.dart';
import 'package:qitak_app/generated/l10n.dart';

extension SellerVerificationStatusL10n on SellerVerificationStatus {
  String label(S l10n) {
    switch (this) {
      case SellerVerificationStatus.notStarted:
        return l10n.sellerStatusNotStarted;
      case SellerVerificationStatus.draft:
        return l10n.sellerStatusNotStarted;
      case SellerVerificationStatus.submitted:
        return l10n.sellerStatusSubmitted;
      case SellerVerificationStatus.needsMoreInfo:
        return l10n.sellerStatusNeedsInfo;
      case SellerVerificationStatus.approved:
        return l10n.sellerStatusApproved;
      case SellerVerificationStatus.rejected:
        return l10n.sellerStatusRejected;
      case SellerVerificationStatus.suspended:
        return l10n.sellerStatusSuspended;
    }
  }

  String subtitle(S l10n) {
    switch (this) {
      case SellerVerificationStatus.notStarted:
      case SellerVerificationStatus.draft:
        return l10n.sellerStatusVerificationDraftBody;
      case SellerVerificationStatus.submitted:
        return l10n.sellerStatusVerificationSubmittedBody;
      case SellerVerificationStatus.needsMoreInfo:
        return l10n.sellerStatusVerificationNeedsInfoBody;
      case SellerVerificationStatus.approved:
        return l10n.sellerStatusVerificationApprovedBody;
      case SellerVerificationStatus.rejected:
        return l10n.sellerStatusVerificationRejectedBody;
      case SellerVerificationStatus.suspended:
        return l10n.sellerStatusSuspended;
    }
  }
}
