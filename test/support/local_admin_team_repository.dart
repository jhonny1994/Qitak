import 'package:qitak_app/core/constants/app_constants.dart';
import 'package:qitak_app/features/admin/data/admin_team_repository.dart';

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
