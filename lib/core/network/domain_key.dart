abstract final class DomainKey {
  static const String disputeStatus = 'dispute_status';
  static const String reportStatus = 'report_status';
  static const String dealStatus = 'deal_status';
  static const String listingStatus = 'listing_status';
  static const String sellerVerificationStatus = 'seller_verification_status';

  static const List<String> all = <String>[
    disputeStatus,
    reportStatus,
    dealStatus,
    listingStatus,
    sellerVerificationStatus,
  ];
}

abstract final class PolicyKey {
  static const String sellerDocumentType = 'seller_document_type';
  static const String sellerVerificationReasonCode =
      'seller_verification_reason_code';
  static const String reportResolutionDecision = 'report_resolution_decision';
  static const String reportResolutionReasonCode =
      'report_resolution_reason_code';
  static const String disputeResolutionDecision = 'dispute_resolution_decision';
  static const String disputeResolutionOutcomeAction =
      'dispute_resolution_outcome_action';
  static const String disputeResolutionReasonCode =
      'dispute_resolution_reason_code';
  static const String listingReportReasonCode = 'listing_report_reason_code';
  static const String buyerDisputeReasonCode = 'buyer_dispute_reason_code';
}
