enum TransactionState {
  intentCreated,
  pendingSellerResponse,
  sellerConfirmed,
  expired,
  cancelled,
  completed,
  disputeOpened,
  disputeResolved,
}

extension TransactionStateX on TransactionState {
  String get value => name;

  bool get isClosed =>
      this == TransactionState.expired ||
      this == TransactionState.completed ||
      this == TransactionState.cancelled ||
      this == TransactionState.disputeResolved;

  static TransactionState fromValue(String raw) {
    return TransactionState.values.firstWhere(
      (item) => item.name == raw,
      orElse: () => TransactionState.intentCreated,
    );
  }
}

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.listingId,
    required this.buyerUserId,
    required this.sellerUserId,
    required this.state,
    this.dealType = 'buy',
    this.exchangeOffer,
    this.expiresAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String listingId;
  final String buyerUserId;
  final String sellerUserId;
  final TransactionState state;
  final String dealType;
  final String? exchangeOffer;
  final DateTime? expiresAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isExchange => dealType == 'exchange';
}
