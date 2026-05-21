import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/notifications/data/notification_preferences_repository.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  NotificationPreferences? _draft;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(notificationPreferencesProvider);
    return preferences.when(
      data: (value) {
        _draft ??= value;
        final draft = _draft!;
        return ListView(
          padding: qitakPagePadding,
          children: [
            QitakPanel(
              child: QitakSectionHeader(
                eyebrow: context.l10n.notificationsTitle,
                title: context.l10n.notificationPreferencesTitle,
                subtitle: context.l10n.notificationPreferencesSubtitle,
              ),
            ),
            const SizedBox(height: 18),
            QitakPanel(
              child: Column(
                children: [
                  _toggleRow(
                    context,
                    title: context.l10n.notificationPreferenceMessages,
                    value: draft.pushMessagesEnabled,
                    onChanged: (next) => setState(
                      () => _draft = NotificationPreferences(
                        pushMessagesEnabled: next,
                        pushDealUpdatesEnabled: draft.pushDealUpdatesEnabled,
                        pushSavedListingUpdatesEnabled:
                            draft.pushSavedListingUpdatesEnabled,
                        emailAccountUpdatesEnabled:
                            draft.emailAccountUpdatesEnabled,
                        emailDealUpdatesEnabled: draft.emailDealUpdatesEnabled,
                        quietHoursStart: draft.quietHoursStart,
                        quietHoursEnd: draft.quietHoursEnd,
                      ),
                    ),
                  ),
                  _toggleRow(
                    context,
                    title: context.l10n.notificationPreferenceDealPush,
                    value: draft.pushDealUpdatesEnabled,
                    onChanged: (next) => setState(
                      () => _draft = NotificationPreferences(
                        pushMessagesEnabled: draft.pushMessagesEnabled,
                        pushDealUpdatesEnabled: next,
                        pushSavedListingUpdatesEnabled:
                            draft.pushSavedListingUpdatesEnabled,
                        emailAccountUpdatesEnabled:
                            draft.emailAccountUpdatesEnabled,
                        emailDealUpdatesEnabled: draft.emailDealUpdatesEnabled,
                        quietHoursStart: draft.quietHoursStart,
                        quietHoursEnd: draft.quietHoursEnd,
                      ),
                    ),
                  ),
                  _toggleRow(
                    context,
                    title: context.l10n.notificationPreferenceSavedListingPush,
                    value: draft.pushSavedListingUpdatesEnabled,
                    onChanged: (next) => setState(
                      () => _draft = NotificationPreferences(
                        pushMessagesEnabled: draft.pushMessagesEnabled,
                        pushDealUpdatesEnabled: draft.pushDealUpdatesEnabled,
                        pushSavedListingUpdatesEnabled: next,
                        emailAccountUpdatesEnabled:
                            draft.emailAccountUpdatesEnabled,
                        emailDealUpdatesEnabled: draft.emailDealUpdatesEnabled,
                        quietHoursStart: draft.quietHoursStart,
                        quietHoursEnd: draft.quietHoursEnd,
                      ),
                    ),
                  ),
                  _toggleRow(
                    context,
                    title: context.l10n.notificationPreferenceAccountEmail,
                    value: draft.emailAccountUpdatesEnabled,
                    onChanged: (next) => setState(
                      () => _draft = NotificationPreferences(
                        pushMessagesEnabled: draft.pushMessagesEnabled,
                        pushDealUpdatesEnabled: draft.pushDealUpdatesEnabled,
                        pushSavedListingUpdatesEnabled:
                            draft.pushSavedListingUpdatesEnabled,
                        emailAccountUpdatesEnabled: next,
                        emailDealUpdatesEnabled: draft.emailDealUpdatesEnabled,
                        quietHoursStart: draft.quietHoursStart,
                        quietHoursEnd: draft.quietHoursEnd,
                      ),
                    ),
                  ),
                  _toggleRow(
                    context,
                    title: context.l10n.notificationPreferenceDealEmail,
                    value: draft.emailDealUpdatesEnabled,
                    onChanged: (next) => setState(
                      () => _draft = NotificationPreferences(
                        pushMessagesEnabled: draft.pushMessagesEnabled,
                        pushDealUpdatesEnabled: draft.pushDealUpdatesEnabled,
                        pushSavedListingUpdatesEnabled:
                            draft.pushSavedListingUpdatesEnabled,
                        emailAccountUpdatesEnabled:
                            draft.emailAccountUpdatesEnabled,
                        emailDealUpdatesEnabled: next,
                        quietHoursStart: draft.quietHoursStart,
                        quietHoursEnd: draft.quietHoursEnd,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.accountSettingsSave),
            ),
          ],
        );
      },
      error: (error, stackTrace) => Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.errorStateTitle,
          message: context.l10n.notificationsErrorBody,
        ),
      ),
      loading: () => const Padding(
        padding: qitakPagePadding,
        child: Column(
          children: [
            QitakPanel(child: QitakSkeletonBox(height: 96)),
            SizedBox(height: 16),
            QitakPanel(child: QitakSkeletonBox(height: 220)),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(title),
    );
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(notificationPreferencesRepositoryProvider).save(draft);
      ref.invalidate(notificationPreferencesProvider);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.accountSettingsSaved)),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
