import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/release/domain/launch_operations_models.dart';
import 'package:qitak_app/features/release/presentation/launch_incident_section.dart';
import 'package:qitak_app/features/release/presentation/launch_snapshot_section.dart';
import 'package:qitak_app/features/release/presentation/risk_action_confirmation_dialog.dart';
import 'package:qitak_app/features/release/providers/launch_operations_providers.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class LaunchOperationsScreen extends ConsumerWidget {
  const LaunchOperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(launchOperationsProvider);
    final run = state.checklistRun;
    final decisionText = run == null
        ? context.l10n.launchDecisionPending
        : context.l10n.launchDecisionText(run.decision);
    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSectionHeader(
                eyebrow: context.l10n.releaseAreaOperations,
                title: context.l10n.launchOperationsTitle,
                subtitle: context.l10n.launchOperationsSubtitle,
              ),
              const SizedBox(height: 16),
              QitakSignalStrip(
                label: context.l10n.launchDecisionLabel,
                value: decisionText,
                status: state.running
                    ? context.l10n.launchChecklistRunning
                    : run == null
                    ? context.l10n.launchChecklistPendingStatus
                    : context.l10n.releaseDecisionReady,
              ),
              const SizedBox(height: 16),
              QitakPanel(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.launchChecklistCoverageTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.launchChecklistCoverageBody,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    for (final item in _checklistRows(context, run))
                      QitakQueueRow(
                        title: item.title,
                        meta: item.meta,
                        status: item.status,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.running
                    ? null
                    : () => ref
                          .read(launchOperationsProvider.notifier)
                          .executeChecklist(),
                child: Text(context.l10n.launchRunChecklist),
              ),
              const SizedBox(height: 16),
              LaunchSnapshotSection(snapshot: state.snapshot),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final rationale = await showRiskActionConfirmationDialog(
                    context,
                    actionLabel: context.l10n.launchRaiseCriticalIncident,
                  );
                  if (rationale == null || !context.mounted) return;
                  await ref
                      .read(launchOperationsProvider.notifier)
                      .raiseIncident(
                        severity: IncidentSeverity.critical,
                        owner: 'ops-oncall',
                        action: rationale,
                      );
                },
                child: Text(context.l10n.launchRaiseCriticalIncident),
              ),
              const SizedBox(height: 8),
              LaunchIncidentSection(incident: state.incident),
            ],
          ),
        ),
      ],
    );
  }

  List<_ChecklistRow> _checklistRows(
    BuildContext context,
    LaunchChecklistRun? run,
  ) {
    const names = <String>[
      'flutter_analyze',
      'flutter_test',
      'integration_test',
      'supabase_test_db',
    ];
    if (run == null) {
      return names
          .map(
            (name) => _ChecklistRow(
              title: context.l10n.launchChecklistTitle(name),
              meta: context.l10n.launchChecklistMeta(name),
              status: context.l10n.launchChecklistPendingStatus,
            ),
          )
          .toList(growable: false);
    }
    return run.prerequisites
        .map(
          (item) => _ChecklistRow(
            title: context.l10n.launchChecklistTitle(item.name),
            meta:
                '${context.l10n.launchChecklistMeta(item.name)} • ${item.evidenceRef}',
            status: context.l10n.launchSignalStatusText(item.status),
          ),
        )
        .toList(growable: false);
  }
}

class _ChecklistRow {
  const _ChecklistRow({
    required this.title,
    required this.meta,
    required this.status,
  });

  final String title;
  final String meta;
  final String status;
}
