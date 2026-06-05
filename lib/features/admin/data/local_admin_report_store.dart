import 'package:qitak_app/features/admin/domain/admin_report.dart';

class LocalAdminReportStore {
  LocalAdminReportStore._();

  static final List<_LocalAdminReportRecord> _reports =
      <_LocalAdminReportRecord>[];

  static void resetForTest() {
    _reports.clear();
  }

  static AdminReport createSupportTicket({
    required String reporterUserId,
    required String reporterName,
    required String reason,
    required String description,
  }) {
    return _create(
      entityType: 'support',
      entityId: reporterUserId,
      entityPreview: 'support ticket',
      reporterUserId: reporterUserId,
      reporterName: reporterName,
      reason: reason,
      description: description,
    );
  }

  static AdminReport createListingReport({
    required String reporterUserId,
    required String reporterName,
    required String listingId,
    required String listingTitle,
    required String reason,
    String description = '',
  }) {
    return _create(
      entityType: 'listing',
      entityId: listingId,
      entityPreview: listingTitle.isEmpty ? listingId : listingTitle,
      reporterUserId: reporterUserId,
      reporterName: reporterName,
      reason: reason,
      description: description,
    );
  }

  static bool hasOpenListingReport({
    required String reporterUserId,
    required String listingId,
  }) {
    return _reports.any(
      (item) =>
          item.reporterUserId == reporterUserId &&
          item.entityType == 'listing' &&
          item.entityId == listingId &&
          _isOpenStatus(item.status),
    );
  }

  static List<AdminReport> listOpenReports() {
    return _reports
        .where((item) => _isOpenStatus(item.status))
        .map(_toAdminReport)
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static AdminReport? fetchReport(String reportId) {
    final match = _reports.where((item) => item.id == reportId).firstOrNull;
    return match == null ? null : _toAdminReport(match);
  }

  static List<AdminReport> listReportsForUser({
    required String reporterUserId,
    required String entityType,
  }) {
    return _reports
        .where(
          (item) =>
              item.reporterUserId == reporterUserId &&
              item.entityType == entityType,
        )
        .map(_toAdminReport)
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static void resolveReport({
    required String reportId,
    required String decision,
  }) {
    final index = _reports.indexWhere((item) => item.id == reportId);
    if (index == -1) {
      return;
    }
    final current = _reports[index];
    final nextStatus = switch (decision) {
      'dismiss' || 'close' => 'dismissed',
      'resolve' ||
      'warn_seller' ||
      'remove_listing' ||
      'suspend_seller' => 'actioned',
      _ => throw ArgumentError.value(
        decision,
        'decision',
        'Unsupported local report decision.',
      ),
    };
    _reports[index] = current.copyWith(
      status: nextStatus,
    );
  }

  static AdminReport _create({
    required String entityType,
    required String entityId,
    required String entityPreview,
    required String reporterUserId,
    required String reporterName,
    required String reason,
    required String description,
  }) {
    final now = DateTime.now();
    final nextSequence =
        _reports.where((item) => item.entityType == entityType).length + 1;
    final record = _LocalAdminReportRecord(
      id: '$entityType-report-$nextSequence',
      reporterUserId: reporterUserId,
      reporterName: reporterName,
      entityType: entityType,
      entityId: entityId,
      entityPreview: entityPreview,
      reason: reason,
      description: description,
      status: 'open',
      createdAt: now,
    );
    _reports
      ..removeWhere((item) => item.id == record.id)
      ..insert(0, record);
    return _toAdminReport(record);
  }

  static AdminReport _toAdminReport(_LocalAdminReportRecord record) {
    return AdminReport(
      id: record.id,
      reporterUserId: record.reporterUserId,
      reporterName: record.reporterName,
      entityType: record.entityType,
      entityId: record.entityId,
      entityPreview: record.entityPreview,
      reason: record.reason,
      description: record.description,
      status: record.status,
      createdAt: record.createdAt,
      reporterHistoryCount: _reports
          .where((item) => item.reporterUserId == record.reporterUserId)
          .length,
      entityHistoryCount: _reports
          .where(
            (item) =>
                item.entityType == record.entityType &&
                item.entityId == record.entityId,
          )
          .length,
    );
  }

  static bool _isOpenStatus(String status) {
    return status == 'open' || status == 'under_review';
  }
}

class _LocalAdminReportRecord {
  const _LocalAdminReportRecord({
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

  _LocalAdminReportRecord copyWith({
    String? status,
  }) {
    return _LocalAdminReportRecord(
      id: id,
      reporterUserId: reporterUserId,
      reporterName: reporterName,
      entityType: entityType,
      entityId: entityId,
      entityPreview: entityPreview,
      reason: reason,
      description: description,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
