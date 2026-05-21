import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/admin/data/admin_team_repository.dart';
import 'package:qitak_app/features/admin/presentation/admin_surface_scaffold.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class AdminTeamScreen extends ConsumerStatefulWidget {
  const AdminTeamScreen({super.key});

  @override
  ConsumerState<AdminTeamScreen> createState() => _AdminTeamScreenState();
}

class _AdminTeamScreenState extends ConsumerState<AdminTeamScreen> {
  final _inviteEmailController = TextEditingController();
  String _inviteRole = 'admin';

  @override
  void dispose() {
    _inviteEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(adminTeamMembersProvider);
    return AdminSurfaceScaffold(
      eyebrow: context.l10n.adminDashboardEyebrow,
      title: context.l10n.adminTeamTitle,
      subtitle: context.l10n.adminTeamSubtitle,
      children: members.when(
        data: (items) => [
          QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _inviteEmailController,
                  decoration: InputDecoration(
                    labelText: context.l10n.emailLabel,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: QitakDropdownField<String>(
                    value: _inviteRole,
                    items: [
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text(context.l10n.profileRoleAdmin),
                      ),
                      DropdownMenuItem(
                        value: 'super_admin',
                        child: Text(context.l10n.profileRoleSuperAdmin),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _inviteRole = value ?? 'admin'),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  key: const Key('admin-team-invite-button'),
                  onPressed: _invite,
                  child: Text(context.l10n.adminTeamInviteAction),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final item in items)
            QitakPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QitakQueueRow(
                    title: item.fullName,
                    meta:
                        '${item.email}${item.lastActiveAt == null ? '' : '\n${context.l10n.adminTeamLastActiveLabel}: ${item.lastActiveAt}'}',
                    status:
                        '${_roleLabel(context, item.role)} • ${item.isActive ? context.l10n.adminTeamStatusActive : context.l10n.adminTeamStatusSuspended}',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton(
                      onPressed: () => _showMemberDetail(context, item),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(context.l10n.sellerListingsPreviewAction),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.isActive)
                        OutlinedButton(
                          onPressed: () => _apply(item.id, 'suspend'),
                          child: Text(context.l10n.adminTeamSuspendAction),
                        )
                      else
                        OutlinedButton(
                          onPressed: () => _apply(item.id, 'reactivate'),
                          child: Text(context.l10n.adminTeamReactivateAction),
                        ),
                      if (item.role == 'admin')
                        FilledButton.tonal(
                          onPressed: () => _apply(item.id, 'promote'),
                          child: Text(context.l10n.adminTeamPromoteAction),
                        )
                      else
                        FilledButton.tonal(
                          onPressed: () => _apply(item.id, 'demote'),
                          child: Text(context.l10n.adminTeamDemoteAction),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
        error: (error, stackTrace) => [
          QitakStateMessage(
            title: context.l10n.errorStateTitle,
            message: context.l10n.discoveryErrorBody,
          ),
        ],
        loading: () => const [QitakPanel(child: QitakSkeletonBox(height: 120))],
      ),
    );
  }

  Future<void> _invite() async {
    final email = _inviteEmailController.text.trim();
    if (email.isEmpty) {
      return;
    }
    await ref
        .read(adminTeamRepositoryProvider)
        .invite(
          email: email,
          role: _inviteRole,
        );
    ref.invalidate(adminTeamMembersProvider);
    if (!mounted) {
      return;
    }
    _inviteEmailController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.adminTeamInviteSuccess)),
    );
  }

  Future<void> _apply(String userId, String action) async {
    await ref
        .read(adminTeamRepositoryProvider)
        .updateMember(
          userId: userId,
          action: action,
        );
    ref.invalidate(adminTeamMembersProvider);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.adminTeamMemberUpdated)),
    );
  }

  Future<void> _showMemberDetail(
    BuildContext context,
    AdminTeamMember item,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.fullName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.email),
            const SizedBox(height: 8),
            Text(_roleLabel(context, item.role)),
            const SizedBox(height: 8),
            Text(
              item.isActive
                  ? context.l10n.adminTeamStatusActive
                  : context.l10n.adminTeamStatusSuspended,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.riskCancel),
          ),
          if (item.isActive)
            OutlinedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _apply(item.id, 'suspend');
              },
              child: Text(context.l10n.adminTeamSuspendAction),
            )
          else
            OutlinedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _apply(item.id, 'reactivate');
              },
              child: Text(context.l10n.adminTeamReactivateAction),
            ),
        ],
      ),
    );
  }
}

String _roleLabel(BuildContext context, String role) {
  switch (role) {
    case 'super_admin':
      return context.l10n.profileRoleSuperAdmin;
    case 'admin':
    default:
      return context.l10n.profileRoleAdmin;
  }
}
