import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/domain/post_auth_redirect_intent.dart';
import 'package:qitak_app/features/auth/presentation/app_preferences_controller.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class GuestAccountScreen extends ConsumerWidget {
  const GuestAccountScreen({
    super.key,
    this.redirectPath,
    this.redirectArguments,
    this.redirectType = IntentTargetType.route,
  });

  final String? redirectPath;
  final String? redirectArguments;
  final IntentTargetType redirectType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final authQuery = _authQuery();
    final authSuffix = authQuery.isEmpty ? '' : '?$authQuery';

    return QitakPageCanvas(
      child: ListView(
        padding: qitakPagePadding,
        children: [
          QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/brand/qitak-logo.png',
                    height: 42,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 18),
                QitakSectionHeader(
                  eyebrow: context.l10n.authChoiceEyebrow,
                  title: context.l10n.authChoiceTitle,
                  subtitle: context.l10n.accountUtilitiesGuestSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () => context.go('/auth/sign-in$authSuffix'),
                  child: Text(context.l10n.signIn),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.go('/auth/sign-up$authSuffix'),
                  child: Text(context.l10n.createAccount),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/auth/admin/sign-in'),
                  child: Text(context.l10n.adminAccess),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          QitakPanel(
            child: Column(
              children: [
                InkWell(
                  key: const Key('guest-account-language-button'),
                  onTap: () => context.go('/auth/language'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.languageSelectionTitle,
                    meta: context.l10n.languageSelectionSubtitle,
                    status: context.languageDisplayName(
                      preferences.guestLanguage,
                    ),
                    variant: QitakQueueRowVariant.value,
                  ),
                ),
                InkWell(
                  key: const Key('guest-account-appearance-button'),
                  onTap: () => context.go('/auth/appearance'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.appearanceSettingsTitle,
                    meta: context.l10n.appearanceSettingsSubtitle,
                    status: _themeModeLabel(context, preferences.themeMode),
                    variant: QitakQueueRowVariant.value,
                  ),
                ),
                InkWell(
                  key: const Key('guest-account-support-button'),
                  onTap: () => context.go('/auth/support'),
                  borderRadius: BorderRadius.circular(18),
                  child: QitakQueueRow(
                    title: context.l10n.supportHelpTitle,
                    meta: context.l10n.supportHelpSubtitle,
                    status: context.l10n.supportHelpStatusGuide,
                    variant: QitakQueueRowVariant.value,
                  ),
                ),
                InkWell(
                  key: const Key('guest-account-legal-button'),
                  onTap: () => context.go('/auth/legal'),
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
        ],
      ),
    );
  }

  String _authQuery() {
    final intent = PostAuthRedirectIntent.fromQueryParameters(
      redirectPath: redirectPath,
      redirectType: redirectType,
      encodedArguments: redirectArguments,
    );
    if (intent == null) {
      return '';
    }
    return Uri(queryParameters: intent.toQueryParameters()).query;
  }
}

String _themeModeLabel(BuildContext context, ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return context.l10n.appearanceModeLightTitle;
    case ThemeMode.system:
      return context.l10n.appearanceModeSystemTitle;
    case ThemeMode.dark:
      return context.l10n.appearanceModeDarkTitle;
  }
}
