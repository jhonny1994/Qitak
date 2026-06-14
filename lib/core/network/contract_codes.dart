abstract final class DomainStatusCode {
  static const String active = 'active';
  static const String closed = 'closed';
  static const String draft = 'draft';
  static const String open = 'open';
  static const String paused = 'paused';
  static const String pendingReview = 'pending_review';
  static const String rejected = 'rejected';
  static const String underReview = 'under_review';

  static const Set<String> reviewQueue = <String>{
    open,
    underReview,
  };
}

abstract final class PolicyCode {
  static const String businessRegistration = 'business_registration';
  static const String documentUnreadable = 'document_unreadable';
  static const String governmentIdBack = 'government_id_back';
  static const String governmentIdFront = 'government_id_front';
  static const String identityMismatch = 'identity_mismatch';
  static const String missingBusinessRegistration =
      'missing_business_registration';
}

List<String> reviewQueueStatusesFrom(Iterable<String> statusCodes) {
  return statusCodes
      .where(DomainStatusCode.reviewQueue.contains)
      .toList(growable: false);
}
