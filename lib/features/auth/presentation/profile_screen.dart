import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/presentation/app_preferences_controller.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/seller/data/seller_application_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final preferences = ref.watch(appPreferencesProvider);
    final profile = session.profile;
    if (session.status == AuthResolutionStatus.loading) {
      return const _ProfileLoadingState();
    }
    if (profile == null) {
      return const SizedBox.shrink();
    }
    final displayName = _displayName(profile.fullName, profile.email);
    final avatarInitial = _avatarInitialForName(displayName);
    final profileRoot = _profileRootForRole(profile.role);
    final sellerApplication = profile.role == AccountRole.seller
        ? ref.watch(currentSellerApplicationProvider)
        : null;

    return QitakPullToRefresh(
      onRefresh: () async {
        await ref.read(authSessionProvider.notifier).restore();
        if (profile.role == AccountRole.seller) {
          ref.invalidate(currentSellerApplicationProvider);
        }
      },
      slivers: [
        SliverPadding(
          padding: qitakPagePadding,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              QitakPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          child: Text(avatarInitial),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              Text(profile.email),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (profile.role == AccountRole.seller &&
                  sellerApplication != null)
                sellerApplication.when(
                  data: (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QitakPanel(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () =>
                                context.go('/seller/onboarding/status'),
                            borderRadius: BorderRadius.circular(18),
                            child: QitakQueueRow(
                              title: context.l10n.sellerStatusTitle,
                              meta: context.l10n.sellerStatusSubtitle,
                              status: _sellerVerificationStatusLabel(
                                context,
                                item?.verificationStatus,
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                            ),
                          ),
                          if (item?.isApproved == true)
                            InkWell(
                              onTap: () => context.go('/seller/home'),
                              borderRadius: BorderRadius.circular(18),
                              child: QitakQueueRow(
                                title: context.l10n.sellerStatusWorkspace,
                                meta: context
                                    .l10n
                                    .sellerStatusWorkspaceApprovedBody,
                                status: context.l10n.sellerStatusApproved,
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                ),
              QitakPanel(
                child: Column(
                  children: [
                    InkWell(
                      key: const Key('profile-settings-button'),
                      onTap: () => context.go('$profileRoot/settings'),
                      borderRadius: BorderRadius.circular(18),
                      child: QitakQueueRow(
                        title: context.l10n.accountSettingsTitle,
                        meta: context.l10n.accountSettingsSubtitle,
                        status: context.l10n.accountRoleLabel(profile.role),
                        variant: QitakQueueRowVariant.value,
                      ),
                    ),
                    InkWell(
                      key: const Key('profile-language-button'),
                      onTap: () => context.go('$profileRoot/language'),
                      borderRadius: BorderRadius.circular(18),
                      child: QitakQueueRow(
                        title: context.l10n.languageSelectionTitle,
                        meta: context.l10n.languageSelectionSubtitle,
                        status: context.languageDisplayName(profile.language),
                        variant: QitakQueueRowVariant.value,
                      ),
                    ),
                    InkWell(
                      key: const Key('profile-appearance-button'),
                      onTap: () => context.go('$profileRoot/appearance'),
                      borderRadius: BorderRadius.circular(18),
                      child: QitakQueueRow(
                        title: context.l10n.appearanceSettingsTitle,
                        meta: context.l10n.appearanceSettingsSubtitle,
                        status: _themeModeStatus(
                          context,
                          preferences.themeMode,
                        ),
                        variant: QitakQueueRowVariant.value,
                      ),
                    ),
                    InkWell(
                      key: const Key('profile-notifications-button'),
                      onTap: () => context.go('$profileRoot/notifications'),
                      borderRadius: BorderRadius.circular(18),
                      child: QitakQueueRow(
                        title: context.l10n.notificationPreferencesTitle,
                        meta: context.l10n.notificationPreferencesSubtitle,
                        status: context.l10n.notificationsEyebrow,
                        variant: QitakQueueRowVariant.value,
                      ),
                    ),
                    InkWell(
                      key: const Key('profile-support-button'),
                      onTap: () => context.go('$profileRoot/support'),
                      borderRadius: BorderRadius.circular(18),
                      child: QitakQueueRow(
                        title: context.l10n.supportHelpTitle,
                        meta: context.l10n.supportHelpSubtitle,
                        status: context.l10n.supportHelpStatusGuide,
                        variant: QitakQueueRowVariant.value,
                      ),
                    ),
                    InkWell(
                      key: const Key('profile-legal-button'),
                      onTap: () => context.go('$profileRoot/legal'),
                      borderRadius: BorderRadius.circular(18),
                      child: QitakQueueRow(
                        title: context.l10n.legalInformationTitle,
                        meta: context.l10n.legalInformationSubtitle,
                        status: context.l10n.legalInformationStatus,
                        variant: QitakQueueRowVariant.value,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 24),
              FilledButton.tonal(
                key: const Key('profile-sign-out'),
                onPressed: () async {
                  await ref.read(authSessionProvider.notifier).signOut();
                  await ref
                      .read(appPreferencesProvider.notifier)
                      .setGuestBrowsingEnabled(enabled: true);
                  if (context.mounted) {
                    context.go('/home');
                  }
                },
                child: Text(context.l10n.signOutAction),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: qitakPagePadding,
      children: const [
        QitakPanel(
          child: Row(
            children: [
              QitakSkeletonBox(
                height: 56,
                width: 56,
                radius: 28,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QitakSkeletonBox(height: 24, width: 180),
                    SizedBox(height: 10),
                    QitakSkeletonBox(height: 16, width: 220),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        QitakPanel(
          child: Column(
            children: [
              QitakSkeletonBox(height: 56),
              SizedBox(height: 12),
              QitakSkeletonBox(height: 56),
              SizedBox(height: 12),
              QitakSkeletonBox(height: 56),
            ],
          ),
        ),
      ],
    );
  }
}

String _avatarInitialForName(String fullName) {
  final normalized = fullName.trim();
  if (normalized.isEmpty) {
    return '?';
  }
  return normalized.characters.first.toUpperCase();
}

String _displayName(String fullName, String email) {
  final normalized = fullName.trim();
  if (normalized.isNotEmpty) {
    return normalized;
  }
  final localPart = email.split('@').first.trim();
  if (localPart.isEmpty) {
    return 'Buyer';
  }
  return localPart[0].toUpperCase() +
      (localPart.length > 1 ? localPart.substring(1) : '');
}

String _profileRootForRole(AccountRole role) {
  switch (role) {
    case AccountRole.seller:
      return '/seller/profile';
    case AccountRole.admin:
    case AccountRole.superAdmin:
      return '/admin/profile';
    case AccountRole.buyer:
    case AccountRole.anonymous:
      return '/profile';
  }
}

String _themeModeStatus(BuildContext context, ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return context.l10n.appearanceModeLightTitle;
    case ThemeMode.system:
      return context.l10n.appearanceModeSystemTitle;
    case ThemeMode.dark:
      return context.l10n.appearanceModeDarkTitle;
  }
}

String _sellerVerificationStatusLabel(BuildContext context, String? status) {
  switch (status) {
    case 'approved':
      return context.l10n.sellerStatusApproved;
    case 'submitted':
      return context.l10n.sellerStatusSubmitted;
    case 'needs_more_info':
      return context.l10n.sellerStatusNeedsInfo;
    case 'rejected':
      return context.l10n.sellerStatusRejected;
    case 'draft':
    case 'not_started':
    default:
      return context.l10n.sellerStatusNotStarted;
  }
}
