import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/network/supabase_error_classifier.dart';
import 'package:qitak_app/features/admin/data/local_admin_report_store.dart';
import 'package:qitak_app/features/admin/domain/admin_report.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/support/domain/support_ticket.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupportRepository {
  const SupportRepository();

  Future<SupportTicket> createTicket({
    required String reason,
    required String description,
  });

  Future<List<SupportTicket>> listTickets();
}

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for support tickets.');
  }
  return SupabaseSupportRepository(client);
});

class LocalSupportRepository implements SupportRepository {
  LocalSupportRepository(this._profile);

  final AccountProfile _profile;

  static void resetForTest() {
    LocalAdminReportStore.resetForTest();
  }

  @override
  Future<SupportTicket> createTicket({
    required String reason,
    required String description,
  }) async {
    final report = LocalAdminReportStore.createSupportTicket(
      reporterUserId: _profile.id,
      reporterName: _profile.fullName,
      reason: reason,
      description: description,
    );
    return _mapLocalReport(report);
  }

  @override
  Future<List<SupportTicket>> listTickets() async {
    return LocalAdminReportStore.listReportsForUser(
      reporterUserId: _profile.id,
      entityType: 'support',
    ).map(_mapLocalReport).toList(growable: false);
  }

  SupportTicket _mapLocalReport(AdminReport report) {
    return SupportTicket(
      id: report.id,
      userId: report.reporterUserId,
      reason: report.reason,
      description: report.description,
      status: report.status,
      createdAt: report.createdAt,
    );
  }
}

class SupabaseSupportRepository implements SupportRepository {
  const SupabaseSupportRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<SupportTicket> createTicket({
    required String reason,
    required String description,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw AppException.fromCode(AppErrorCode.sessionNotFound);
    }

    try {
      final row = await _client
          .from('reports')
          .insert(<String, dynamic>{
            'reporter_id': currentUser.id,
            'reported_entity_type': 'support',
            'reported_entity_id': currentUser.id,
            'report_type': reason,
            'description': description,
          })
          .select()
          .single();
      return _mapRow(row);
    } on PostgrestException catch (error) {
      throw AppException.fromCode(classifyPostgrestException(error));
    }
  }

  @override
  Future<List<SupportTicket>> listTickets() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw AppException.fromCode(AppErrorCode.sessionNotFound);
    }

    try {
      final rows = await _client
          .from('reports')
          .select()
          .eq('reporter_id', currentUser.id)
          .eq('reported_entity_type', 'support')
          .order('created_at', ascending: false);
      return rows
          .whereType<Map<String, dynamic>>()
          .map(_mapRow)
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw AppException.fromCode(classifyPostgrestException(error));
    }
  }

  SupportTicket _mapRow(Map<String, dynamic> row) {
    return SupportTicket(
      id: row['id'] as String? ?? '',
      userId: row['reporter_id'] as String? ?? '',
      reason: row['report_type'] as String? ?? '',
      description: row['description'] as String? ?? '',
      status: row['status'] as String? ?? 'open',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}
