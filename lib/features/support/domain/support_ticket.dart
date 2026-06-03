class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.userId,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String reason;
  final String description;
  final String status;
  final DateTime createdAt;
}
