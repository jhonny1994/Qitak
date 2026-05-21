import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/constants/app_constants.dart';
import 'package:qitak_app/core/network/supabase_client_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminTeamMember {
  const AdminTeamMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    this.lastActiveAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? lastActiveAt;
}

abstract class AdminTeamRepository {
  const AdminTeamRepository();

  Future<List<AdminTeamMember>> listMembers();

  Future<void> invite({
    required String email,
    required String role,
  });

  Future<void> updateMember({
    required String userId,
    required String action,
  });
}

final adminTeamRepositoryProvider = Provider<AdminTeamRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is required for admin team operations.');
  }
  return SupabaseAdminTeamRepository(client);
});

final adminTeamMembersProvider = FutureProvider<List<AdminTeamMember>>((ref) {
  return ref.read(adminTeamRepositoryProvider).listMembers();
});

class SupabaseAdminTeamRepository implements AdminTeamRepository {
  const SupabaseAdminTeamRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> invite({
    required String email,
    required String role,
  }) async {
    await _client.rpc<dynamic>(
      'admin_create_invite',
      params: <String, dynamic>{'p_email': email, 'p_role': role},
    );
  }

  @override
  Future<List<AdminTeamMember>> listMembers() async {
    final rows = await _client
        .from('profiles')
        .select('id, full_name, email, role, is_active, updated_at')
        .inFilter('role', ['admin', 'super_admin'])
        .order('role')
        .order('full_name');
    return rows
        .whereType<Map<String, dynamic>>()
        .map((row) {
          return AdminTeamMember(
            id: row['id'] as String,
            fullName: row['full_name'] as String? ?? '',
            email: row['email'] as String? ?? '',
            role: row['role'] as String? ?? 'admin',
            isActive: row['is_active'] as bool? ?? true,
            lastActiveAt: DateTime.tryParse(
              row['updated_at'] as String? ?? '',
            )?.toLocal(),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> updateMember({
    required String userId,
    required String action,
  }) async {
    await _client.rpc<dynamic>(
      'admin_manage_account',
      params: <String, dynamic>{'p_target_user_id': userId, 'p_action': action},
    );
  }
}

class LocalAdminTeamRepository implements AdminTeamRepository {
  const LocalAdminTeamRepository();

  @override
  Future<void> invite({
    required String email,
    required String role,
  }) async {}

  @override
  Future<List<AdminTeamMember>> listMembers() async {
    return const [
      AdminTeamMember(
        id: 'admin-001',
        fullName: 'Amina Ops',
        email: 'admin@qitak.test',
        role: 'admin',
        isActive: true,
      ),
      AdminTeamMember(
        id: 'super-admin-001',
        fullName: kLocalOpsControlName,
        email: 'superadmin@qitak.test',
        role: 'super_admin',
        isActive: true,
      ),
    ];
  }

  @override
  Future<void> updateMember({
    required String userId,
    required String action,
  }) async {}
}
