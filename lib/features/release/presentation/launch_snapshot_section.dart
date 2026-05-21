import 'package:flutter/material.dart';
import 'package:qitak_app/core/l10n/l10n.dart';
import 'package:qitak_app/features/release/domain/launch_operations_models.dart';
import 'package:qitak_app/shared/widgets/qitak_components.dart';

class LaunchSnapshotSection extends StatelessWidget {
  const LaunchSnapshotSection({required this.snapshot, super.key});

  final MonitoringSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot == null) return const SizedBox.shrink();
    return QitakPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.releaseSnapshotTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final entry in snapshot!.signals.entries)
            QitakQueueRow(
              title: context.l10n.launchSnapshotSignalTitle(entry.key),
              meta: context.l10n.releaseSnapshotSignalLabel,
              status: context.l10n.launchSignalStatusText(entry.value),
            ),
        ],
      ),
    );
  }
}
