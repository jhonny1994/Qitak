import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/errors/app_exception.dart';
import 'package:qitak_app/core/l10n/app_error_localization.dart';
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
            key: const Key('admin-team-invite'),
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
          QitakPanel(
            key: const Key('admin-team-members'),
            child: Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  _AdminMemberCard(
                    item: items[index],
                    onPreview: () => _showMemberDetail(context, items[index]),
                    onPrimaryAction: () => _apply(
                      items[index].id,
                      items[index].isActive ? 'suspend' : 'reactivate',
                    ),
                    onRoleAction: () => _apply(
                      items[index].id,
                      items[index].role == 'admin' ? 'promote' : 'demote',
                    ),
                  ),
                  if (index < items.length - 1) const SizedBox(height: 12),
                ],
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
    try {
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
    } on AppException catch (error) {
      _showMutationError(context, context.appExceptionMessage(error));
    } on Object catch (error) {
      _showMutationError(context, error.toString());
    }
  }

  Future<void> _apply(String userId, String action) async {
    try {
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
    } on AppException catch (error) {
      _showMutationError(context, context.appExceptionMessage(error));
    } on Object catch (error) {
      _showMutationError(context, error.toString());
    }
  }

  void _showMutationError(BuildContext context, String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

class _AdminMemberCard extends StatelessWidget {
  const _AdminMemberCard({
    required this.item,
    required this.onPreview,
    required this.onPrimaryAction,
    required this.onRoleAction,
  });

  final AdminTeamMember item;
  final VoidCallback onPreview;
  final VoidCallback onPrimaryAction;
  final VoidCallback onRoleAction;

  @override
  Widget build(BuildContext context) {
    return QitakSurface(
      role: QitakSurfaceRole.object,
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
          const SizedBox(height: 10),
          FilledButton.tonal(
            onPressed: onPreview,
            child: Text(context.l10n.sellerListingsPreviewAction),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              KeyedSubtree(
                key: const Key('admin-team-danger-actions'),
                child: OutlinedButton(
                  onPressed: onPrimaryAction,
                  child: Text(
                    item.isActive
                        ? context.l10n.adminTeamSuspendAction
                        : context.l10n.adminTeamReactivateAction,
                  ),
                ),
              ),
              FilledButton(
                onPressed: onRoleAction,
                child: Text(
                  item.role == 'admin'
                      ? context.l10n.adminTeamPromoteAction
                      : context.l10n.adminTeamDemoteAction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
