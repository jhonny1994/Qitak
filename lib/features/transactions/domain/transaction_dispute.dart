class DisputeEvidenceItem {
  const DisputeEvidenceItem({
    required this.id,
    required this.storagePath,
    required this.previewUrl,
  });

  final String id;
  final String storagePath;
  final String previewUrl;
}

class TransactionDispute {
  const TransactionDispute({
    required this.id,
    required this.transactionId,
    required this.createdByUserId,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    this.buyerName = '',
    this.sellerName = '',
    this.listingTitle = '',
    this.conversationId,
    this.evidence = const <DisputeEvidenceItem>[],
  });

  final String id;
  final String transactionId;
  final String createdByUserId;
  final String reason;
  final String description;
  final String status;
  final DateTime createdAt;
  final String buyerName;
  final String sellerName;
  final String listingTitle;
  final String? conversationId;
  final List<DisputeEvidenceItem> evidence;
}
