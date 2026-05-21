import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/domain/account_profile.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/auth/providers/redirect_intent_provider.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class SupportHelpScreen extends ConsumerWidget {
  const SupportHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final profile = session.profile;
    final accountRoot = switch (profile?.role) {
      AccountRole.seller => '/seller/profile',
      AccountRole.admin || AccountRole.superAdmin => '/admin/profile',
      AccountRole.buyer => '/profile',
      _ => '/guest/account',
    };
    final supportActionPath = session.isAuthenticated
        ? '$accountRoot/settings'
        : '/auth/sign-up';
    final legalPath = session.isAuthenticated
        ? '$accountRoot/legal'
        : '/auth/legal';
    final notificationIntent = PostAuthRedirectIntent.route('/notifications');
    final notificationQuery = Uri(
      queryParameters: notificationIntent.toQueryParameters(),
    ).query;

    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: QitakSectionHeader(
            eyebrow: context.l10n.supportHelpEyebrow,
            title: context.l10n.supportHelpTitle,
            subtitle: context.l10n.supportHelpSubtitle,
          ),
        ),
        const SizedBox(height: 18),
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakQueueRow(
                title: context.l10n.supportHelpAccountTitle,
                meta: context.l10n.supportHelpAccountBody,
                status: context.l10n.supportHelpStatusGuide,
              ),
              QitakQueueRow(
                title: context.l10n.supportHelpSafetyTitle,
                meta: context.l10n.supportHelpSafetyBody,
                status: context.l10n.supportHelpStatusTrust,
              ),
              QitakQueueRow(
                title: context.l10n.supportHelpNotificationTitle,
                meta: context.l10n.supportHelpNotificationBody,
                status: context.l10n.supportHelpStatusAlerts,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.supportHelpNeedActionTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.supportHelpNeedActionBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      if (session.isAuthenticated) {
                        context.go('/notifications');
                        return;
                      }
                      ref
                              .read(redirectIntentProvider.notifier)
                              .rememberedIntent =
                          notificationIntent;
                      context.go('/guest/account?$notificationQuery');
                    },
                    child: Text(context.l10n.notificationsTitle),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.go(supportActionPath),
                    child: Text(
                      session.isAuthenticated
                          ? context.l10n.accountSettingsTitle
                          : context.l10n.createAccount,
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.go(legalPath),
                    child: Text(context.l10n.legalInformationTitle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
