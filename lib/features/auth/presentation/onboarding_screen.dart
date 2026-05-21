import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/core/theme/app_theme.dart';
import 'package:qitak_app/features/auth/presentation/app_preferences_controller.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({
    required this.step,
    super.key,
  });

  final int step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = _OnboardingContent.fromStep(context, step);

    Future<void> finish() async {
      await ref.read(appPreferencesProvider.notifier).markOnboardingSeen();
      if (context.mounted) {
        context.go('/guest/account');
      }
    }

    return SingleChildScrollView(
      padding: qitakPagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QitakPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QitakSectionHeader(
                  eyebrow: context.l10n.onboardingEyebrow,
                  title: model.title,
                  subtitle: model.body,
                  trailing: QitakChip(
                    label: '$step/3',
                    selected: true,
                  ),
                ),
                const SizedBox(height: 24),
                _OnboardingScene(model: model),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    QitakChip(
                      label: model.primaryTag,
                      leading: Icon(model.icon),
                      selected: true,
                    ),
                    QitakChip(
                      label: model.secondaryTag,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                QitakSignalStrip(
                  label: context.l10n.brandWordmark,
                  value: model.signalTitle,
                  status: model.signalBody,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isActive = index + 1 == step;
                    return Container(
                      width: isActive ? 22 : 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await finish();
                        },
                        child: Text(context.l10n.onboardingSkip),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          if (step >= 3) {
                            await finish();
                            return;
                          }
                          context.go('/intro/${step + 1}');
                        },
                        child: Text(
                          step >= 3
                              ? context.l10n.onboardingGetStarted
                              : context.l10n.onboardingNext,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.title,
    required this.body,
    required this.icon,
    required this.primaryTag,
    required this.secondaryTag,
    required this.signalTitle,
    required this.signalBody,
  });

  factory _OnboardingContent.fromStep(BuildContext context, int step) {
    switch (step) {
      case 1:
        return _OnboardingContent(
          title: context.l10n.onboardingTitleOne,
          body: context.l10n.onboardingBodyOne,
          icon: Icons.search_rounded,
          primaryTag: context.l10n.onboardingPanelBrowse,
          secondaryTag: context.l10n.onboardingPanelGuest,
          signalTitle: context.l10n.onboardingPanelBrowse,
          signalBody: context.l10n.onboardingPanelGuest,
        );
      case 2:
        return _OnboardingContent(
          title: context.l10n.onboardingTitleTwo,
          body: context.l10n.onboardingBodyTwo,
          icon: Icons.tune_rounded,
          primaryTag: context.l10n.onboardingPanelFilters,
          secondaryTag: context.l10n.onboardingPanelSearch,
          signalTitle: context.l10n.onboardingPanelFilters,
          signalBody: context.l10n.onboardingPanelSearch,
        );
      case 3:
      default:
        return _OnboardingContent(
          title: context.l10n.onboardingTitleThree,
          body: context.l10n.onboardingBodyThree,
          icon: Icons.chat_bubble_outline_rounded,
          primaryTag: context.l10n.onboardingPanelActions,
          secondaryTag: context.l10n.onboardingPanelSignInWhenReady,
          signalTitle: context.l10n.onboardingPanelActions,
          signalBody: context.l10n.onboardingPanelSignInWhenReady,
        );
    }
  }

  final String title;
  final String body;
  final IconData icon;
  final String primaryTag;
  final String secondaryTag;
  final String signalTitle;
  final String signalBody;
}

class _OnboardingScene extends StatelessWidget {
  const _OnboardingScene({required this.model});

  final _OnboardingContent model;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.qitakTokens;
    final isCompactViewport = MediaQuery.sizeOf(context).width < 380;

    return Container(
      height: isCompactViewport ? 296 : 272,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: tokens.stroke),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.55),
            colorScheme.surface,
            colorScheme.secondaryContainer.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            right: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: tokens.stroke),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Icon(
                  model.icon,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: switch (model.icon) {
              Icons.search_rounded => _BrowseScene(model: model),
              Icons.tune_rounded => _FilterScene(model: model),
              _ => _ActionScene(model: model),
            },
          ),
        ],
      ),
    );
  }
}

class _BrowseScene extends StatelessWidget {
  const _BrowseScene({required this.model});

  final _OnboardingContent model;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SceneSearchBar(label: model.primaryTag),
        const SizedBox(height: 14),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _SceneCard(
                  title: context.l10n.onboardingListingOne,
                  subtitle: '',
                  accent: colorScheme.primary,
                  compact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SceneCard(
                  title: context.l10n.onboardingListingTwo,
                  subtitle: '',
                  accent: colorScheme.secondary,
                  compact: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ScenePill(label: model.secondaryTag),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ScenePill(label: context.l10n.onboardingPanelCompare),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterScene extends StatelessWidget {
  const _FilterScene({required this.model});

  final _OnboardingContent model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ScenePill(label: context.l10n.onboardingFilterCategory),
            _ScenePill(label: context.l10n.onboardingFilterLocation),
            _ScenePill(label: context.l10n.onboardingFilterFitment),
            _ScenePill(label: context.l10n.onboardingFilterMake),
            _ScenePill(label: context.l10n.onboardingFilterModel),
            _ScenePill(label: context.l10n.onboardingFilterYear),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _SceneCard(
                  title: model.primaryTag,
                  subtitle: model.secondaryTag,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: _SceneMetric(
                        title: '6',
                        subtitle: context.l10n.onboardingPanelFilters,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _SceneMetric(
                        title: '1',
                        subtitle: context.l10n.onboardingPanelSearch,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionScene extends StatelessWidget {
  const _ActionScene({required this.model});

  final _OnboardingContent model;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _SceneCard(
                  title: context.l10n.onboardingActionSaved,
                  subtitle: model.primaryTag,
                  accent: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SceneCard(
                  title: context.l10n.onboardingActionMessages,
                  subtitle: context.l10n.onboardingPanelSignInWhenReady,
                  accent: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _SceneCard(
            title: context.l10n.authGateTitle,
            subtitle: context.l10n.onboardingBodyThree,
            accent: colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

class _SceneSearchBar extends StatelessWidget {
  const _SceneSearchBar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.qitakTokens;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.stroke),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: colorScheme.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  const _SceneCard({
    required this.title,
    required this.subtitle,
    this.accent,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final Color? accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.qitakTokens;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight =
            constraints.maxHeight < 108 || constraints.maxWidth < 92;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: tokens.stroke),
          ),
          child: Padding(
            padding: EdgeInsets.all((compact || isTight) ? 10 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 6,
                  decoration: BoxDecoration(
                    color: (accent ?? colorScheme.primary).withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                if (!isTight) const Spacer() else const SizedBox(height: 10),
                Text(
                  title,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: compact
                            ? (isTight ? 13 : 15)
                            : (isTight ? 14 : null),
                        height: compact ? 1.1 : 1.2,
                      ),
                  maxLines: isTight ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!compact && subtitle.isNotEmpty) ...[
                  SizedBox(height: isTight ? 4 : 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.2,
                    ),
                    maxLines: isTight ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SceneMetric extends StatelessWidget {
  const _SceneMetric({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.qitakTokens;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxHeight < 96 || constraints.maxWidth < 88;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: tokens.stroke),
          ),
          child: Padding(
            padding: EdgeInsets.all(isTight ? 10 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: isTight ? 24 : null,
                    height: 1,
                  ),
                ),
                if (!isTight) const Spacer() else const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                  maxLines: isTight ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScenePill extends StatelessWidget {
  const _ScenePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.qitakTokens;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(tokens.chipRadius),
        border: Border.all(color: tokens.stroke),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
