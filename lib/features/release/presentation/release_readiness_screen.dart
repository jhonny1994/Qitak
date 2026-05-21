import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/auth/providers/auth_session_provider.dart';
import 'package:qitak_app/features/release/presentation/release_blocker_sections.dart';
import 'package:qitak_app/features/release/presentation/release_readiness_summary_vm.dart';
import 'package:qitak_app/features/release/providers/release_readiness_providers.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ReleaseReadinessScreen extends ConsumerWidget {
  const ReleaseReadinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(releaseReadinessProvider);
    final summary = buildReleaseReadinessSummary(
      run: state.run,
      title: context.l10n.releaseReadinessTitle,
      readyLabel: context.l10n.releaseDecisionReady,
      notReadyLabel: context.l10n.releaseDecisionNotReady,
    );
    final profile = ref.watch(authSessionProvider).profile;
    if (profile == null) {
      return Padding(
        padding: qitakPagePadding,
        child: QitakStateMessage(
          title: context.l10n.authGateTitle,
          message: context.l10n.authGateBody,
        ),
      );
    }

    final initiatedBy = profile.id;
    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSectionHeader(
                eyebrow: context.l10n.releaseAreaOperations,
                title: summary.title,
                subtitle:
                    '${context.l10n.releaseDecisionLabel}: ${summary.decisionText}',
              ),
              const SizedBox(height: 12),
              QitakSignalStrip(
                label: context.l10n.releaseOpenBlockers,
                value: summary.blockerCount.toString(),
                status: summary.decisionText,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.releaseReadinessRuntimeWarning,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.running
                    ? null
                    : () {
                        unawaited(
                          ref
                              .read(releaseReadinessProvider.notifier)
                              .execute(initiatedBy: initiatedBy),
                        );
                      },
                child: Text(context.l10n.releaseRunReadiness),
              ),
              const SizedBox(height: 16),
              if (state.running) const LinearProgressIndicator(),
              if (state.run != null) ...[
                const SizedBox(height: 16),
                Text(
                  context.l10n.releaseGateResults,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final gate in state.run!.gates)
                  QitakQueueRow(
                    title: gate.gateName,
                    meta: gate.evidenceRef,
                    status: gate.status.name,
                  ),
                const SizedBox(height: 12),
                ReleaseBlockerSections(blockers: state.run!.blockers),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
