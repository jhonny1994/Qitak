import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/release/providers/observability_providers.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class ReleaseObservabilityScreen extends ConsumerWidget {
  const ReleaseObservabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(releaseObservabilityProvider);
    return ListView(
      padding: qitakPagePadding,
      children: [
        QitakPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QitakSectionHeader(
                eyebrow: context.l10n.releaseAreaOperations,
                title: context.l10n.releaseObservabilityTitle,
                subtitle: context.l10n.releaseObservabilityRefresh,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.read(releaseObservabilityProvider.notifier).refresh(),
                child: Text(context.l10n.releaseObservabilityRefresh),
              ),
              const SizedBox(height: 16),
              if (state.snapshot != null)
                QitakSignalStrip(
                  label: context.l10n.releaseObservabilitySignals,
                  value: state.snapshot!.signals.entries
                      .map(
                        (entry) =>
                            '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                      )
                      .join(', '),
                  status: context.l10n.releaseDecisionReady,
                ),
              const SizedBox(height: 12),
              QitakSignalStrip(
                label: context.l10n.releaseObservabilityAlerts,
                value: state.alerts.length.toString(),
                status: state.alerts.isEmpty
                    ? context.l10n.releaseDecisionReady
                    : context.l10n.releaseDecisionNotReady,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref
                    .read(releaseObservabilityProvider.notifier)
                    .acknowledgeFirstAlert(),
                child: Text(context.l10n.releaseObservabilityAcknowledge),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref
                    .read(releaseObservabilityProvider.notifier)
                    .exportStableReport(),
                child: Text(context.l10n.releaseObservabilityExportStable),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
