class AdminReport {
  const AdminReport({
    required this.id,
    required this.reporterUserId,
    required this.reporterName,
    required this.entityType,
    required this.entityId,
    required this.entityPreview,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    this.reporterHistoryCount = 0,
    this.entityHistoryCount = 0,
  });

  final String id;
  final String reporterUserId;
  final String reporterName;
  final String entityType;
  final String entityId;
  final String entityPreview;
  final String reason;
  final String description;
  final String status;
  final DateTime createdAt;
  final int reporterHistoryCount;
  final int entityHistoryCount;
}
