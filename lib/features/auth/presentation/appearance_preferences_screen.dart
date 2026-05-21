import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/presentation/app_preferences_controller.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class AppearancePreferencesScreen extends ConsumerWidget {
  const AppearancePreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final selectedMode = preferences.themeMode;

    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: QitakSectionHeader(
            eyebrow: context.l10n.appearanceSettingsEyebrow,
            title: context.l10n.appearanceSettingsTitle,
            subtitle: context.l10n.appearanceSettingsSubtitle,
          ),
        ),
        const SizedBox(height: 18),
        for (final option in _appearanceOptions(context))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              key: Key('appearance-option-${option.mode.name}'),
              onTap: () async {
                await ref
                    .read(appPreferencesProvider.notifier)
                    .setThemeMode(option.mode);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.appearanceSettingsSaved),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: QitakPanel(
                backgroundColor: selectedMode == option.mode
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(option.subtitle),
                        ],
                      ),
                    ),
                    if (selectedMode == option.mode)
                      const Icon(Icons.check_circle_rounded),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AppearanceOption {
  const _AppearanceOption({
    required this.mode,
    required this.title,
    required this.subtitle,
  });

  final ThemeMode mode;
  final String title;
  final String subtitle;
}

List<_AppearanceOption> _appearanceOptions(BuildContext context) {
  return [
    _AppearanceOption(
      mode: ThemeMode.dark,
      title: context.l10n.appearanceModeDarkTitle,
      subtitle: context.l10n.appearanceModeDarkSubtitle,
    ),
    _AppearanceOption(
      mode: ThemeMode.light,
      title: context.l10n.appearanceModeLightTitle,
      subtitle: context.l10n.appearanceModeLightSubtitle,
    ),
    _AppearanceOption(
      mode: ThemeMode.system,
      title: context.l10n.appearanceModeSystemTitle,
      subtitle: context.l10n.appearanceModeSystemSubtitle,
    ),
  ];
}
