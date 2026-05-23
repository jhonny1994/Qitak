import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/presentation/app_preferences_controller.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/generated/l10n.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final profile = ref.watch(authSessionProvider).profile;
    final activeLanguage = profile?.language ?? preferences.guestLanguage;

    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: QitakSectionHeader(
            eyebrow: context.l10n.languageSelectionEyebrow,
            title: context.l10n.languageSelectionTitle,
            subtitle: context.l10n.languageSelectionSubtitle,
          ),
        ),
        const SizedBox(height: 18),
        for (final option in _languageOptions(context))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              key: Key('language-option-${option.code}'),
              onTap: () => _selectLanguage(context, ref, option.code),
              borderRadius: BorderRadius.circular(24),
              child: QitakPanel(
                backgroundColor: activeLanguage == option.code
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.nativeLabel,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(option.secondaryLabel),
                        ],
                      ),
                    ),
                    if (activeLanguage == option.code)
                      const Icon(Icons.check_circle_rounded),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectLanguage(
    BuildContext context,
    WidgetRef ref,
    String language,
  ) async {
    final profile = ref.read(authSessionProvider).profile;
    if (profile == null) {
      await ref
          .read(appPreferencesProvider.notifier)
          .setGuestLanguage(language);
    } else {
      await ref.read(authSessionProvider.notifier).updateLanguage(language);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.languageSelectionSaved)),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.code,
    required this.nativeLabel,
    required this.secondaryLabel,
  });

  final String code;
  final String nativeLabel;
  final String secondaryLabel;
}

List<_LanguageOption> _languageOptions(BuildContext context) {
  // Build label map once; new ARB locales are included automatically as long
  // as their native/secondary labels are added here.
  final labelsByCode = <String, _LanguageOption>{
    'ar': _LanguageOption(
      code: 'ar',
      nativeLabel: context.l10n.languageNativeArabic,
      secondaryLabel: context.l10n.languageNameArabic,
    ),
    'en': _LanguageOption(
      code: 'en',
      nativeLabel: context.l10n.languageNativeEnglish,
      secondaryLabel: context.l10n.languageNameEnglish,
    ),
    'fr': _LanguageOption(
      code: 'fr',
      nativeLabel: context.l10n.languageNativeFrench,
      secondaryLabel: context.l10n.languageNameFrench,
    ),
  };

  return S.delegate.supportedLocales
      .map((locale) => labelsByCode[locale.languageCode])
      .whereType<_LanguageOption>()
      .toList();
}
