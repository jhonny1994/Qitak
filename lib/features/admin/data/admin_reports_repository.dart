import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/features/admin/domain/admin_report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AdminReportsRepository {
  const AdminReportsRepository();

  Future<List<AdminReport>> listOpenReports();

  Future<AdminReport?> fetchReport(String reportId);

  Future<void> resolveReport({
    required String reportId,
    required String decision,
    required String reasonCode,
    String? note,
  });
}

final adminReportsRepositoryProvider = Provider<AdminReportsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for admin reports.');
  }
  return SupabaseAdminReportsRepository(client);
});

class SupabaseAdminReportsRepository implements AdminReportsRepository {
  const SupabaseAdminReportsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AdminReport?> fetchReport(String reportId) async {
    final row = await _client
        .from('reports')
        .select()
        .eq('id', reportId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return _mapDetailedRow(row);
  }

  @override
  Future<List<AdminReport>> listOpenReports() async {
    final rows = await _client
        .from('reports')
        .select()
        .inFilter('status', ['open', 'under_review'])
        .order('created_at', ascending: false);
    return rows
        .whereType<Map<String, dynamic>>()
        .map(_mapRow)
        .toList(growable: false);
  }

  @override
  Future<void> resolveReport({
    required String reportId,
    required String decision,
    required String reasonCode,
    String? note,
  }) async {
    await _client.rpc<dynamic>(
      'admin_resolve_report',
      params: <String, dynamic>{
        'p_report_id': reportId,
        'p_decision': decision,
        'p_reason_code': reasonCode,
        'p_note': note,
      },
    );
  }

  AdminReport _mapRow(Map<String, dynamic> row) {
    final entityType = row['reported_entity_type'] as String? ?? '';
    return AdminReport(
      id: row['id'] as String,
      reporterUserId: row['reporter_id'] as String? ?? '',
      reporterName: row['reporter_name'] as String? ?? '',
      entityType: entityType,
      entityId: row['reported_entity_id']?.toString() ?? '',
      entityPreview:
          row['entity_preview'] as String? ??
          _fallbackEntityPreview(
            entityType,
            row['reported_entity_id']?.toString() ?? '',
          ),
      reason: row['report_type'] as String? ?? '',
      description: row['description'] as String? ?? '',
      status: row['status'] as String? ?? 'open',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }

  Future<AdminReport> _mapDetailedRow(Map<String, dynamic> row) async {
    final reporterId = row['reporter_id'] as String? ?? '';
    final entityId = row['reported_entity_id']?.toString() ?? '';
    final entityType = row['reported_entity_type'] as String? ?? '';
    final reporterFuture = reporterId.isEmpty
        ? Future<Map<String, dynamic>?>.value()
        : _client
              .from('profiles')
              .select('full_name')
              .eq('id', reporterId)
              .maybeSingle();
    final reporterHistoryFuture = reporterId.isEmpty
        ? Future<int>.value(0)
        : _countRows(
            table: 'reports',
            column: 'reporter_id',
            value: reporterId,
          );
    final entityHistoryFuture = entityId.isEmpty
        ? Future<int>.value(0)
        : _countRows(
            table: 'reports',
            column: 'reported_entity_id',
            value: entityId,
          );
    final entityPreviewFuture = _loadEntityPreview(
      entityType: entityType,
      entityId: entityId,
    );
    final reporter = await reporterFuture;
    return AdminReport(
      id: row['id'] as String,
      reporterUserId: reporterId,
      reporterName: reporter?['full_name'] as String? ?? reporterId,
      entityType: entityType,
      entityId: entityId,
      entityPreview: await entityPreviewFuture,
      reason: row['report_type'] as String? ?? '',
      description: row['description'] as String? ?? '',
      status: row['status'] as String? ?? 'open',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      reporterHistoryCount: await reporterHistoryFuture,
      entityHistoryCount: await entityHistoryFuture,
    );
  }

  Future<int> _countRows({
    required String table,
    required String column,
    required String value,
  }) async {
    final rows = await _client.from(table).select('id').eq(column, value);
    return rows.length;
  }

  Future<String> _loadEntityPreview({
    required String entityType,
    required String entityId,
  }) async {
    if (entityId.isEmpty) {
      return '-';
    }
    switch (entityType) {
      case 'listing':
        final listing = await _client
            .from('listings')
            .select('title')
            .eq('id', entityId)
            .maybeSingle();
        return listing?['title'] as String? ?? entityId;
      case 'message':
        final message = await _client
            .from('messages')
            .select('content')
            .eq('id', entityId)
            .maybeSingle();
        return message?['content'] as String? ?? entityId;
      case 'seller':
        final seller = await _client
            .from('sellers')
            .select('business_name')
            .eq('id', entityId)
            .maybeSingle();
        return seller?['business_name'] as String? ?? entityId;
      default:
        return entityId;
    }
  }

  String _fallbackEntityPreview(String entityType, String entityId) {
    if (entityType.isEmpty) {
      return entityId;
    }
    return '$entityType • $entityId';
  }
}

class LocalAdminReportsRepository implements AdminReportsRepository {
  const LocalAdminReportsRepository();

  @override
  Future<AdminReport?> fetchReport(String reportId) async {
    for (final item in await listOpenReports()) {
      if (item.id == reportId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<AdminReport>> listOpenReports() async {
    return const <AdminReport>[];
  }

  @override
  Future<void> resolveReport({
    required String reportId,
    required String decision,
    required String reasonCode,
    String? note,
  }) async {}
}

final FutureProvider<List<AdminReport>> adminReportsProvider =
    FutureProvider<List<AdminReport>>((ref) {
      return ref.read(adminReportsRepositoryProvider).listOpenReports();
    });

// Riverpod family provider aliases are version-specific in this repo; keep
// inference here so the provider remains strongly typed without pinning to an
// unavailable concrete family class name.
// ignore: specify_nonobvious_property_types
final adminReportProvider = FutureProvider.family<AdminReport?, String>((
  ref,
  reportId,
) {
  return ref.read(adminReportsRepositoryProvider).fetchReport(reportId);
});
