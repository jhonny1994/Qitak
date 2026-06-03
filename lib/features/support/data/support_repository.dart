import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/network/app_error_code.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:qitak_app/core/network/supabase_error_classifier.dart';
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

  static final List<SupportTicket> _tickets = <SupportTicket>[];

  static void resetForTest() {
    _tickets.clear();
  }

  @override
  Future<SupportTicket> createTicket({
    required String reason,
    required String description,
  }) async {
    final now = DateTime.now();
    final ticket = SupportTicket(
      id: 'support-${_tickets.length + 1}',
      userId: _profile.id,
      reason: reason,
      description: description,
      status: 'open',
      createdAt: now,
    );
    _tickets
      ..removeWhere((item) => item.id == ticket.id)
      ..insert(0, ticket);
    return ticket;
  }

  @override
  Future<List<SupportTicket>> listTickets() async {
    return _tickets
        .where((ticket) => ticket.userId == _profile.id)
        .toList(growable: false);
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
